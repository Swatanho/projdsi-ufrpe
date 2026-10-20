import 'dart:async';

import '../models/doctor_model.dart';
import '../repositories/firebase_auth_repository.dart';
import '../repositories/firestore_repository.dart';

export '../models/doctor_model.dart' show DoctorModel, DoctorProfile;

class AuthService {
  AuthService({
    FirebaseAuthRepository? authRepository,
    FirestoreRepository? firestoreRepository,
  }) : _authRepository = authRepository ?? FirebaseAuthRepository(),
       _firestoreRepository = firestoreRepository ?? FirestoreRepository();

  static final AuthService instance = AuthService();

  final FirebaseAuthRepository _authRepository;
  final FirestoreRepository _firestoreRepository;

  static const String _emailDomain = 'hearthealth.app';

  String? get currentUserId => _authRepository.currentUserId;

  Stream<bool> get isAuthenticated =>
      _authRepository.authStateChanges.map((user) => user != null).distinct();

  static String normalizeCrm(String crm) =>
      crm.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  String crmToEmail(String crm) => '${normalizeCrm(crm)}@$_emailDomain';

  Stream<DoctorModel> doctorProfileStream() {
    final uid = currentUserId;
    if (uid == null) return const Stream.empty();
    return _firestoreRepository.doctorProfileStream(uid);
  }

  Future<void> signUp({
    required String name,
    required String crm,
    required String password,
    String? email,
  }) async {
    final realEmail = email?.trim() ?? '';
    if (realEmail.isNotEmpty && !realEmail.contains('@')) {
      throw const AuthException('Informe um e-mail válido para continuar.');
    }

    // Quando um e-mail real é informado ele passa a ser a identidade da
    // conta no Firebase Auth (necessário para o envio do e-mail de
    // recuperação de senha); sem e-mail, mantém o e-mail sintético legado
    // derivado do CRM.
    final authEmail = realEmail.isNotEmpty ? realEmail : crmToEmail(crm);

    final uid = await _createAccount(email: authEmail, password: password);
    if (uid == null) {
      throw const AuthException(
        'Não foi possível criar a conta. Tente novamente.',
      );
    }

    final doctor = DoctorModel(
      uid: uid,
      name: name.trim(),
      crm: normalizeCrm(crm).toUpperCase(),
      email: realEmail.isNotEmpty ? realEmail : crmToEmail(crm),
    );

    try {
      await _firestoreRepository.saveDoctor(doctor);
    } on FirestoreRepositoryException catch (error) {
      throw AuthException('Erro ao salvar o perfil: ${error.message}');
    }
  }

  Future<String?> _createAccount({
    required String email,
    required String password,
  }) async {
    try {
      return await _authRepository.createAccount(
        email: email,
        password: password,
      );
    } on AuthRepositoryException catch (error) {
      throw AuthException(_messageFor(error.code));
    }
  }

  /// Autentica com CRM ou e-mail real e senha.
  ///
  /// No login por CRM, tenta primeiro o e-mail real do perfil no Firestore
  /// (contas criadas com e-mail) e depois o e-mail sintético legado
  /// (`{crm}@hearthealth.app`), garantindo compatibilidade com as duas
  /// gerações de contas.
  Future<void> signIn({
    String? crm,
    String? email,
    required String password,
  }) async {
    final normalizedEmail = (email ?? '').trim();
    final normalizedCrm = (crm ?? '').trim();

    final candidates = <String>[
      if (normalizedEmail.contains('@')) normalizedEmail,
      if (normalizedCrm.isNotEmpty)
        ...await _authEmailCandidatesForCrm(normalizedCrm),
    ];

    if (candidates.isEmpty) {
      throw const AuthException('Informe um CRM ou e-mail válido.');
    }

    AuthRepositoryException? lastError;
    for (final candidate in candidates) {
      try {
        await _authRepository.signIn(email: candidate, password: password);
        return;
      } on AuthRepositoryException catch (error) {
        lastError = error;
        // Erros de credencial permitem tentar o próximo e-mail candidato;
        // os demais (rede, limite de tentativas etc.) abortam imediatamente.
        if (!_isCredentialError(error.code)) rethrow;
      }
    }

    throw AuthException(_messageFor(lastError!.code));
  }

  /// Resolve o e-mail usado como identidade de autenticação para um CRM.
  ///
  /// Considera primeiro o e-mail real do perfil no Firestore e, como
  /// legado, o e-mail sintético derivado do CRM.
  Future<String> resolveAuthEmailForCrm(String crm) async {
    final profileEmail = await _firestoreRepository.doctorEmailForCrm(crm);
    return profileEmail ?? crmToEmail(crm);
  }

  /// Envia o e-mail de redefinição de senha para o endereço informado ou
  /// para o e-mail resolvido a partir do CRM.
  Future<void> resetPassword({String? crm, String? email}) async {
    final targetEmail = (email ?? '').trim();
    final resolvedEmail = targetEmail.contains('@')
        ? targetEmail
        : crm != null && crm.trim().isNotEmpty
        ? await resolveAuthEmailForCrm(crm)
        : '';

    if (resolvedEmail.isEmpty || !resolvedEmail.contains('@')) {
      throw const AuthException(
        'Informe um e-mail válido para redefinir a senha.',
      );
    }

    try {
      await _authRepository.sendPasswordResetEmail(email: resolvedEmail);
    } on AuthRepositoryException catch (error) {
      throw AuthException(_messageFor(error.code));
    }
  }

  Future<List<String>> _authEmailCandidatesForCrm(String crm) async {
    final profileEmail = await _firestoreRepository.doctorEmailForCrm(crm);
    return [
      if (profileEmail != null) profileEmail,
      crmToEmail(crm),
    ];
  }

  bool _isCredentialError(String code) =>
      code == 'invalid-credential' ||
      code == 'wrong-password' ||
      code == 'user-not-found' ||
      code == 'invalid-email';

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
    } on AuthRepositoryException catch (error) {
      throw AuthException(_messageFor(error.code));
    }
  }

  String _messageFor(String code) {
    switch (code) {
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
        return 'Ocorreu um erro ao autenticar ($code). Tente novamente.';
    }
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
