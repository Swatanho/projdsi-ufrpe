import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/appointment_model.dart';
import 'package:frontend/models/doctor_model.dart';
import 'package:frontend/models/patient_model.dart';
import 'package:frontend/models/prediction_model.dart';
import 'package:frontend/models/risk_assessment_model.dart';

void main() {
  test('AppointmentModel serializes its scheduling data', () {
    final appointment = AppointmentModel(
      doctorId: 'doctor-1',
      patientId: 'patient-1',
      patientName: 'Ana Silva',
      scheduledAt: DateTime(2026, 10, 12, 14, 30),
      notes: 'Reavaliação',
      description: 'Retorno de cardiologia.',
    );

    final serialized = appointment.toMap();
    final parsed = AppointmentModel.fromMap(
      serialized,
      id: 'appointment-1',
    );

    expect(serialized['scheduledAt'], isA<Timestamp>());
    expect(parsed.id, 'appointment-1');
    expect(parsed.scheduledAt, appointment.scheduledAt);
    expect(parsed.patientName, 'Ana Silva');
    expect(parsed.description, 'Retorno de cardiologia.');
    expect(parsed.notes, 'Reavaliação');
  });

  test('AppointmentModel sorts appointments by schedule time', () {
    final appointments = [
      AppointmentModel(
        doctorId: 'doctor-1',
        patientId: 'patient-1',
        patientName: 'Paciente B',
        scheduledAt: DateTime(2026, 10, 12, 16, 0),
      ),
      AppointmentModel(
        doctorId: 'doctor-1',
        patientId: 'patient-2',
        patientName: 'Paciente A',
        scheduledAt: DateTime(2026, 10, 12, 9, 30),
      ),
    ];

    final sorted = AppointmentModel.sortByScheduledAt(appointments);

    expect(sorted.map((item) => item.patientName).toList(), ['Paciente A', 'Paciente B']);
  });

  test('DoctorModel reads and writes profile data', () {
    final doctor = DoctorModel.fromMap('doctor-1', {
      'name': 'Ana Silva',
      'crm': 'CRM123456',
      'email': 'ana@example.com',
    });

    expect(doctor.uid, 'doctor-1');
    expect(doctor.toMap()['crm'], 'CRM123456');
  });

  test('PatientModel preserves the current Firestore schema', () {
    final createdAt = DateTime.utc(2026, 10, 12);
    final patient = PatientModel(
      name: 'Carlos Mendes',
      age: 58,
      gender: 'Masculino',
      bmi: 24.5,
      highBp: true,
      highChol: false,
      smoker: false,
      physActivity: true,
      stroke: false,
      createdAt: createdAt,
    );

    final parsed = PatientModel.fromMap(
      patient.toMap(),
      id: 'patient-1',
      doctorId: 'doctor-1',
    );

    expect(parsed.id, 'patient-1');
    expect(parsed.doctorId, 'doctor-1');
    expect(parsed.name, 'Carlos Mendes');
    expect(parsed.createdAt, createdAt);
    expect(
      patient.toMap().keys,
      containsAll([
        'name',
        'age',
        'gender',
        'bmi',
        'highBp',
        'highChol',
        'smoker',
        'physActivity',
        'stroke',
        'createdAt',
      ]),
    );
  });

  test('PatientModel copyWith only overrides the informed fields', () {
    final patient = PatientModel(
      id: 'patient-1',
      doctorId: 'doctor-1',
      name: 'Carlos Mendes',
      age: 58,
      gender: 'Masculino',
      bmi: 24.5,
      highBp: true,
      highChol: false,
      smoker: false,
      physActivity: true,
      stroke: false,
      createdAt: DateTime.utc(2026, 10, 12),
    );

    final updated = patient.copyWith(name: 'Carlos M. Souza', bmi: 26.2);

    expect(updated.id, 'patient-1');
    expect(updated.doctorId, 'doctor-1');
    expect(updated.name, 'Carlos M. Souza');
    expect(updated.bmi, 26.2);
    expect(updated.age, 58);
    expect(updated.gender, 'Masculino');
    expect(updated.highBp, isTrue);
    expect(updated.highChol, isFalse);
    expect(updated.smoker, isFalse);
    expect(updated.physActivity, isTrue);
    expect(updated.stroke, isFalse);
    expect(updated.createdAt, patient.createdAt);
  });

  test('PredictionModel parses the API response', () {
    final prediction = PredictionModel.fromJson({
      'prediction': 1,
      'risk_percentage': 76.4,
      'model_name': 'logistic_regression',
      'message': 'Risco detectado',
    });

    expect(prediction.prediction, 1);
    expect(prediction.riskPercentage, 76.4);
    expect(prediction.modelName, 'logistic_regression');
    expect(prediction.message, 'Risco detectado');
  });

  test('RiskAssessmentModel reads stored evaluation data', () {
    final createdAt = DateTime.utc(2026, 10, 20, 18);
    final assessment = RiskAssessmentModel.fromMap({
      'prediction': 1,
      'riskPercentage': 76.4,
      'modelName': 'xgboost',
      'message': 'Risco detectado',
      'createdAt': createdAt,
    }, id: 'assessment-1');

    expect(assessment.id, 'assessment-1');
    expect(assessment.prediction, 1);
    expect(assessment.riskPercentage, 76.4);
    expect(assessment.modelName, 'xgboost');
    expect(assessment.message, 'Risco detectado');
    expect(assessment.createdAt, createdAt);
  });

  test('PredictionAlgorithm parses model-specific feature importances', () {
    final algorithm = PredictionAlgorithm.fromJson({
      'id': 'xgboost',
      'label': 'XGBoost',
      'feature_importances': [
        {'feature': 'Age', 'importance': 0.32},
      ],
    });

    expect(algorithm.id, 'xgboost');
    expect(algorithm.label, 'XGBoost');
    expect(algorithm.featureImportances.single.feature, 'Age');
    expect(algorithm.featureImportances.single.importance, 0.32);
  });
}
