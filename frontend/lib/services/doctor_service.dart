import 'auth_service.dart';

export 'auth_service.dart' show AuthException;

class DoctorService {
  DoctorService({AuthService? authService})
    : _authService = authService ?? AuthService.instance;

  static final DoctorService instance = DoctorService();

  final AuthService _authService;

  Future<void> register({
    required String name,
    required String crm,
    required String password,
    String? email,
  }) {
    return _authService.signUp(
      name: name,
      crm: crm,
      password: password,
      email: email,
    );
  }

  Stream<DoctorModel> profileStream() => _authService.doctorProfileStream();
}
