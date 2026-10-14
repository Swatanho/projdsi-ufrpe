import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Atualizar nome e CRM do médico
  Future<void> updateDoctorProfile({required String name, required String crm}) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('doctors').doc(user.uid).update({
        'name': name,
        'crm': crm,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Excluir conta do médico por completo (Firestore + Auth)
  Future<void> deleteDoctorAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      // 1. Apaga o documento do Firestore
      await _firestore.collection('doctors').doc(user.uid).delete();
      
      // 2. Apaga a conta no Firebase Authentication
      await user.delete();
    }
  }
}