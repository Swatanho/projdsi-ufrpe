import '../models/risk_assessment_model.dart';
import '../repositories/firestore_repository.dart';

class RiskAssessmentService {
  RiskAssessmentService({FirestoreRepository? firestoreRepository})
    : _firestoreRepository = firestoreRepository ?? FirestoreRepository();

  final FirestoreRepository _firestoreRepository;

  Future<void> addAssessment(
    String patientId,
    RiskAssessmentModel assessment,
  ) {
    return _firestoreRepository.addRiskAssessment(patientId, assessment);
  }

  Stream<List<RiskAssessmentModel>> watchAssessments(String patientId) {
    return _firestoreRepository.watchRiskAssessments(patientId);
  }
}
