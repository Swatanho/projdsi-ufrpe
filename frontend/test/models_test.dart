import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/appointment_model.dart';
import 'package:frontend/models/doctor_model.dart';
import 'package:frontend/models/patient_model.dart';
import 'package:frontend/models/prediction_model.dart';

void main() {
  test('AppointmentModel serializes its scheduling data', () {
    final appointment = AppointmentModel(
      doctorId: 'doctor-1',
      patientId: 'patient-1',
      scheduledAt: DateTime.utc(2026, 10, 12, 14, 30),
      notes: 'Reavaliação',
    );

    final parsed = AppointmentModel.fromMap(
      appointment.toMap(),
      id: 'appointment-1',
    );

    expect(parsed.id, 'appointment-1');
    expect(parsed.scheduledAt, appointment.scheduledAt);
    expect(parsed.notes, 'Reavaliação');
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
      'message': 'Risco detectado',
    });

    expect(prediction.prediction, 1);
    expect(prediction.message, 'Risco detectado');
  });
}
