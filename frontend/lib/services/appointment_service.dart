import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  final FirebaseFirestore _firestore;

  AppointmentService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('appointments');

Stream<List<AppointmentModel>> getAppointmentsByDoctor(String doctorId) {
  return _collection
      .where('doctorId', isEqualTo: doctorId)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return AppointmentModel.fromMap(
        doc.data(),
        id: doc.id,
      );
    }).toList();
  });
}

  /// Adiciona uma nova consulta
  Future<void> addAppointment(String doctorId, AppointmentModel model) async {
    await _collection.add(model.toMap());
  }

  /// Atualiza uma consulta existente
  Future<void> updateAppointment(AppointmentModel model) async {
    if (model.id == null || model.id!.isEmpty) return;
    await _collection.doc(model.id).update(model.toMap());
  }

  /// Remove uma consulta pelo ID
  Future<void> deleteAppointment(String id) async {
    if (id.isEmpty) return;
    await _collection.doc(id).delete();
  }
}