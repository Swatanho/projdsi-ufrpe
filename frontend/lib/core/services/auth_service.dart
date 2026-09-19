import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Perfil do médico armazenado no Firestore (coleção `doctors/{uid}`).
class DoctorProfile {
  const DoctorProfile({
    required this.uid,
    required this.name,
    required this.crm,
    required this.email,
  });

  final String uid;
  final String name;
  final String crm;
  final String email;

  factory DoctorProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return DoctorProfile(
      uid: doc.id,
      name: (data['name'] as String?) ?? '',
      crm: (data['crm'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
    );
  }
}

/// Erro de autenticação com mensagem pronta para exibição ao usuário.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Serviço de autenticação com Firebase Auth + Firestore.
///
/// A tela de login trabalha com CRM, mas o Firebase Auth usa e-mail/senha.
/// Para manter o design atual, o CRM é convertido internamente em um
/// e-mail sintético (ex.: `CRM-123456` -> `crm123456@hearthealth.app`).
/// Como o e-mail é único no Firebase Auth, isso também garante que
/// cada CRM só possa ser cadastrado uma vez.
///
/// O e-mail real informado no cadastro é guardado no perfil do Firestore.
class AuthService {
  AuthService._()
      : _auth = FirebaseAuth.instance,
        _firestore = FirebaseFirestore.instance;

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static const String _doctorsCollection = 'doctors';
  static const String _emailDomain = 'hearthealth.app';

  /// Usuário logado (null se ninguém estiver autenticado).
  User? get currentUser => _auth.currentUser;

  /// Stream que emite a cada mudança de sessão (login/logout).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Normaliza o CRM (minúsculo, apenas letras e números).
  ///
  /// `CRM-123456`, `crm 123456` e `crm123456` viram `crm123456`.
  static String normalizeCrm(String crm) =>
      crm.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  /// Converte o CRM em e-mail sintético usado no Firebase Auth.
  String crmToEmail(String crm) => '${normalizeCrm(crm)}@$_emailDomain';

  /// Stream do perfil do médico logado (documento `doctors/{uid}`).
  Stream<DoctorProfile> doctorProfileStream() {
    final user = currentUser;
    if (user == null) return const Stream.empty();
    return _firestore
        .collection(_doctorsCollection)
        .doc(user.uid)
        .snapshots()
        .map(DoctorProfile.fromFirestore);
  }

  /// Cria a conta (Firebase Auth) e o perfil do médico (Firestore).
  ///
  /// [email] é o e-mail real informado na tela de cadastro, guardado no
  /// perfil; a autenticação em si usa o e-mail sintético derivado do CRM.
  Future<void> signUp({
    required String name,
    required String crm,
    required String password,
    String? email,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: crmToEmail(crm),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException(
          'Não foi possível criar a conta. Tente novamente.',
        );
      }

      await _firestore.collection(_doctorsCollection).doc(user.uid).set({
        'name': name.trim(),
        'crm': normalizeCrm(crm).toUpperCase(),
        'email': email?.trim().isNotEmpty == true ? email!.trim() : user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    } on FirebaseException catch (e) {
      throw AuthException('Erro ao salvar o perfil: ${e.message}');
    }
  }

  /// Autentica com CRM + senha.
  Future<void> signIn({required String crm, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: crmToEmail(crm),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    }
  }

  /// Encerra a sessão atual.
  Future<void> signOut() => _auth.signOut();

  /// Traduz os códigos do Firebase Auth para mensagens amigáveis.
  String _messageFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'CRM ou senha incorretos.';
      case 'invalid-email':
        return 'CRM inválido.';
      case 'user-disabled':
        return 'Esta conta foi desativada. Contate o suporte.';
      case 'email-already-in-use':
        return 'Já existe uma conta cadastrada com este CRM.';
      case 'weak-password':
        return 'A senha deve ter pelo menos 6 caracteres.';
      case 'network-request-failed':
        return 'Sem conexão com a internet. Verifique sua rede.';
      case 'too-many-requests':
        return 'Muitas tentativas incorretas. Tente novamente em alguns minutos.';
      default:
        return 'Ocorreu um erro ao autenticar (${e.code}). Tente novamente.';
    }
  }
}