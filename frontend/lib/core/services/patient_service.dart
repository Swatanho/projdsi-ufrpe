import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/patients/models/patient_model.dart';

class PatientService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addPatient(String doctorId, PatientModel patient) async {
    await _firestore
        .collection('doctors')
        .doc(doctorId)
        .collection('patients')
        .add(patient.toMap());
  }
}