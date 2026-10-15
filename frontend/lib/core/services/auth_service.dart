import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// perfil do médico salvo no firestore
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

/// erro de autenticação com mensagem pronta para o usuário
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// serviço de autenticação com firebase auth e firestore
class AuthService {
  AuthService._()
      : _auth = FirebaseAuth.instance,
        _firestore = FirebaseFirestore.instance;

  AuthService.testable({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore;

  static AuthService instance = AuthService._();

  @visibleForTesting
  static void overrideInstance(AuthService service) {
    instance = service;
  }

  final FirebaseAuth _auth;
  final FirebaseFirestore? _firestore;

  static const String _doctorsCollection = 'doctors';
  static const String _emailDomain = 'hearthealth.app';

  /// usuário autenticado, ou nulo quando não houver sessão
  User? get currentUser => _auth.currentUser;

  /// resolve o email do auth para um crm
  Future<String> resolveAuthEmailForCrm(String crm) async {
    final firestore = _firestore;
    final sessionEmail = _auth.currentUser?.email?.trim();
    if (sessionEmail != null && sessionEmail.contains('@')) {
      return sessionEmail;
    }

    if (firestore != null) {
      try {
        final snapshot = await firestore.collection(_doctorsCollection).get();

        for (final doc in snapshot.docs) {
          final data = doc.data();
          final storedCrm = (data['crm'] as String? ?? '').trim();
          if (normalizeCrm(storedCrm) != normalizeCrm(crm)) continue;

          final email = (data['email'] as String? ?? '').trim();
          if (email.contains('@')) {
            return email;
          }
        }
      } catch (_) {
        // fallback para o email legado quando a leitura falha
      }
    }

    return crmToEmail(crm);
  }

  /// stream de mudanças de sessão
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// normaliza o crm para o formato usado na aplicação
  static String normalizeCrm(String crm) =>
      crm.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  /// converte o crm em um email sintético legado
  String crmToEmail(String crm) => '${normalizeCrm(crm)}@$_emailDomain';

  /// stream do perfil do médico logado
  Stream<DoctorProfile> doctorProfileStream() {
    final user = currentUser;
    final firestore = _firestore;
    if (user == null || firestore == null) return const Stream.empty();
    return firestore
        .collection(_doctorsCollection)
        .doc(user.uid)
        .snapshots()
        .map(DoctorProfile.fromFirestore);
  }

  /// cria a conta e salva o perfil do médico
  Future<void> signUp({
    required String name,
    required String crm,
    required String password,
    String? email,
  }) async {
    final firestore = _firestore;
    if (firestore == null) {
      throw const AuthException('Firebase Firestore indisponível no momento.');
    }

    final realEmail = email?.trim() ?? '';
    if (!realEmail.contains('@')) {
      throw const AuthException('Informe um e-mail válido para continuar.');
    }

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: realEmail,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException(
          'Não foi possível criar a conta. Tente novamente.',
        );
      }

      await firestore.collection(_doctorsCollection).doc(user.uid).set({
        'name': name.trim(),
        'crm': normalizeCrm(crm).toUpperCase(),
        'email': realEmail,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    } on FirebaseException catch (e) {
      throw AuthException('Erro ao salvar o perfil: ${e.message}');
    }
  }

  /// autentica com crm ou email e senha
  Future<void> signIn({String? crm, String? email, required String password}) async {
    final normalizedEmail = (email ?? '').trim();
    final normalizedCrm = (crm ?? '').trim();

    try {
      final authEmail = normalizedEmail.isNotEmpty && normalizedEmail.contains('@')
          ? normalizedEmail
          : await resolveAuthEmailForCrm(normalizedCrm);

      await _auth.signInWithEmailAndPassword(
        email: authEmail,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    }
  }

  /// envia o email de recuperação de senha
  Future<void> resetPassword({String? crm, String? email}) async {
    final targetEmail = (email ?? '').trim();
    final resolvedEmail = targetEmail.isNotEmpty
        ? targetEmail
        : crm != null
            ? await resolveAuthEmailForCrm(crm)
            : '';

    if (resolvedEmail.isEmpty || !resolvedEmail.contains('@')) {
      throw const AuthException('Informe um e-mail válido para redefinir a senha.');
    }

    try {
      await _auth.sendPasswordResetEmail(email: resolvedEmail);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    }
  }

  /// encerra a sessão atual
  Future<void> signOut() => _auth.signOut();

  /// converte erros do firebase em mensagens amigáveis
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
