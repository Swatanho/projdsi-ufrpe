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
    final uid = await _createAccount(crm: crm, password: password);
    if (uid == null) {
      throw const AuthException(
        'Não foi possível criar a conta. Tente novamente.',
      );
    }

    final doctor = DoctorModel(
      uid: uid,
      name: name.trim(),
      crm: normalizeCrm(crm).toUpperCase(),
      email: email?.trim().isNotEmpty == true ? email!.trim() : crmToEmail(crm),
    );

    try {
      await _firestoreRepository.saveDoctor(doctor);
    } on FirestoreRepositoryException catch (error) {
      throw AuthException('Erro ao salvar o perfil: ${error.message}');
    }
  }

  Future<String?> _createAccount({
    required String crm,
    required String password,
  }) async {
    try {
      return await _authRepository.createAccount(
        email: crmToEmail(crm),
        password: password,
      );
    } on AuthRepositoryException catch (error) {
      throw AuthException(_messageFor(error.code));
    }
  }

  Future<void> signIn({required String crm, required String password}) async {
    try {
      await _authRepository.signIn(email: crmToEmail(crm), password: password);
    } on AuthRepositoryException catch (error) {
      throw AuthException(_messageFor(error.code));
    }
  }

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
