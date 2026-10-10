import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/patients/models/patient_model.dart';

class PatientService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _patientsCollection = 'patients';

  /// Cadastra o paciente na coleção raiz `patients`.
  ///
  /// O documento carrega o `doctorId` do médico que o registrou, o que
  /// permite listar os pacientes de todos os médicos e, na UI, liberar
  /// edição/exclusão apenas para o proprietário do cadastro.
  Future<void> addPatient(String doctorId, PatientModel patient) async {
    await _firestore
        .collection(_patientsCollection)
        .add(patient.toMap());
  }

  /// Stream reativo com os pacientes cadastrados por **todos** os médicos.
  ///
  /// Qualquer médico logado pode visualizar todos os pacientes; a edição e
  /// exclusão são restritas ao dono (verificado na UI e nas regras do
  /// Firestore).
  Stream<List<PatientModel>> getAllPatientsStream() {
    return _firestore
        .collection(_patientsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PatientModel.fromMap(doc.id, doc.data()))
            .toList());
  }
}