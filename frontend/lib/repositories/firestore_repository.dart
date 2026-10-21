import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/appointment_model.dart';
import '../models/doctor_model.dart';
import '../models/patient_model.dart';
import '../models/risk_assessment_model.dart';

class FirestoreRepository {
  FirestoreRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const _doctorsCollection = 'doctors';
  static const _patientsCollection = 'patients';
  static const _appointmentsCollection = 'appointments';

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
      await _firestore
          .collection(_patientsCollection)
          .doc(id)
          .update(patient.toMap());
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

  Future<void> addRiskAssessment(
    String patientId,
    RiskAssessmentModel assessment,
  ) async {
    try {
      await _firestore
          .collection(_patientsCollection)
          .doc(patientId)
          .collection('risk_assessments')
          .add({
            ...assessment.toMap(),
            'createdAt': FieldValue.serverTimestamp(),
          });
    } on FirebaseException catch (error) {
      throw FirestoreRepositoryException(error.message ?? error.code);
    }
  }

  Future<void> addAppointment(String doctorId, AppointmentModel appointment) async {
    if (appointment.doctorId.isEmpty || appointment.doctorId != doctorId) {
      throw const FirestoreRepositoryException(
        'A consulta precisa estar vinculada ao médico autenticado.',
      );
    }

    try {
      final payload = <String, dynamic>{
        ...appointment.toMap(),
        'doctorId': doctorId,
      };
      await _firestore.collection(_appointmentsCollection).add(payload);
    } on FirebaseException catch (error) {
      throw FirestoreRepositoryException(
        '${error.code}: ${error.message ?? 'Falha ao gravar a consulta.'}',
      );
    }
  }

  Future<void> updateAppointment(AppointmentModel appointment) async {
    final id = appointment.id;
    if (id == null || id.isEmpty) {
      throw const FirestoreRepositoryException(
        'Não é possível atualizar uma consulta sem id.',
      );
    }

    if (appointment.doctorId.isEmpty) {
      throw const FirestoreRepositoryException(
        'Não foi possível identificar o médico da consulta.',
      );
    }

    try {
      final payload = appointment.toMap();
      await _firestore
          .collection(_appointmentsCollection)
          .doc(id)
          .update(payload);
    } on FirebaseException catch (error) {
      throw FirestoreRepositoryException(
        '${error.code}: ${error.message ?? 'Falha ao atualizar a consulta.'}',
      );
    }
  }

  Future<void> deleteAppointment(String id) async {
    try {
      await _firestore.collection(_appointmentsCollection).doc(id).delete();
    } on FirebaseException catch (error) {
      throw FirestoreRepositoryException(error.message ?? error.code);
    }
  }

  Stream<List<AppointmentModel>> watchAppointmentsForDoctor(String doctorId) {
    return _firestore
        .collection(_appointmentsCollection)
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .map((snapshot) {
          final appointments = snapshot.docs
              .map(
                (document) => AppointmentModel.fromMap(
                  document.data(),
                  id: document.id,
                ),
              )
              .toList();
          return AppointmentModel.sortByScheduledAt(appointments);
        });
  }

  Stream<List<RiskAssessmentModel>> watchRiskAssessments(String patientId) {
    return _firestore
        .collection(_patientsCollection)
        .doc(patientId)
        .collection('risk_assessments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) => RiskAssessmentModel.fromMap(
                  document.data(),
                  id: document.id,
                ),
              )
              .toList(),
        );
  }

  /// Retorna o e-mail real cadastrado no perfil do médico com o CRM
  /// informado, ou `null` quando não encontrado.
  ///
  /// A comparação ignora formatação: "CRM-123456" e "crm123456" são
  /// equivalentes. Quando a leitura falha, retorna `null` para que o
  /// `AuthService` aplique o fallback para o e-mail sintético do CRM.
  Future<String?> doctorEmailForCrm(String crm) async {
    final normalized = _normalizeCrm(crm);
    if (normalized.isEmpty) return null;

    try {
      final snapshot = await _firestore.collection(_doctorsCollection).get();
      for (final document in snapshot.docs) {
        final data = document.data();
        final storedCrm = _normalizeCrm((data['crm'] as String?) ?? '');
        if (storedCrm != normalized) continue;

        final email = ((data['email'] as String?) ?? '').trim();
        if (email.contains('@')) return email;
      }
    } on FirebaseException {
      // mantém o fallback para o e-mail sintético do CRM no AuthService
    }
    return null;
  }

  static String _normalizeCrm(String crm) =>
      crm.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
}

class FirestoreRepositoryException implements Exception {
  const FirestoreRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
