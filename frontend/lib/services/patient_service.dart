import '../models/patient_model.dart';
import '../repositories/firestore_repository.dart';

class PatientService {
  PatientService({FirestoreRepository? firestoreRepository})
    : _firestoreRepository = firestoreRepository ?? FirestoreRepository();

  final FirestoreRepository _firestoreRepository;

  Future<void> addPatient(String doctorId, PatientModel patient) {
    return _firestoreRepository.addPatient(doctorId, patient);
  }

  Future<void> updatePatient(PatientModel patient) {
    return _firestoreRepository.updatePatient(patient);
  }

  Future<void> deletePatient(String id) {
    return _firestoreRepository.deletePatient(id);
  }

  Stream<List<PatientModel>> watchAllPatients() {
    return _firestoreRepository.watchAllPatients();
  }
}
