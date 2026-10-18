import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/doctor_model.dart';
import '../models/patient_model.dart';

class FirestoreRepository {
  FirestoreRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const _doctorsCollection = 'doctors';
  static const _patientsCollection = 'patients';

  Stream<DoctorModel> doctorProfileStream(String uid) {
    return _firestore
        .collection(_doctorsCollection)
        .doc(uid)
        .snapshots()
        .map(
          (snapshot) => DoctorModel.fromMap(
            snapshot.id,
            snapshot.data() ?? const <String, dynamic>{},
          ),
        );
  }

  Future<void> saveDoctor(DoctorModel doctor) async {
    try {
      await _firestore.collection(_doctorsCollection).doc(doctor.uid).set({
        ...doctor.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (error) {
      throw FirestoreRepositoryException(error.message ?? error.code);
    }
  }

  Future<void> addPatient(String doctorId, PatientModel patient) async {
    try {
      await _firestore.collection(_patientsCollection).add({
        ...patient.toMap(),
        'doctorId': doctorId,
      });
    } on FirebaseException catch (error) {
      throw FirestoreRepositoryException(error.message ?? error.code);
    }
  }

  Stream<List<PatientModel>> watchAllPatients() {
    return _firestore.collectionGroup(_patientsCollection).snapshots().map((
      snapshot,
    ) {
      final patients = snapshot.docs.map((document) {
        return PatientModel.fromMap(
          document.data(),
          id: document.id,
            doctorId:
              document.data()['doctorId'] as String? ??
              document.reference.parent.parent?.id,
        );
      }).toList();
      patients.sort(
        (first, second) => second.createdAt.compareTo(first.createdAt),
      );
      return patients;
    });
  }

  /// Atualiza os dados de um paciente cadastrado pelo médico dono.
  ///
  /// `doctorId` é intencionalmente ignorado: as regras de segurança do
  /// Firestore impedem a transferência de propriedade do paciente.
  Future<void> updatePatient(PatientModel patient) async {
    final id = patient.id;
    if (id == null || id.isEmpty) {
      throw const FirestoreRepositoryException(
        'Não é possível atualizar um paciente sem id.',
      );
    }

    try {
      await _firestore.collection(_patientsCollection).doc(id).update(
        patient.toMap(),
      );
    } on FirebaseException catch (error) {
      throw FirestoreRepositoryException(error.message ?? error.code);
    }
  }

  /// Remove permanentemente o cadastro de um paciente.
  Future<void> deletePatient(String id) async {
    try {
      await _firestore.collection(_patientsCollection).doc(id).delete();
    } on FirebaseException catch (error) {
      throw FirestoreRepositoryException(error.message ?? error.code);
    }
  }
}

class FirestoreRepositoryException implements Exception {
  const FirestoreRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
