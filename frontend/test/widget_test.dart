// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/home/presentation/screens/doctor_register_screen.dart';
import 'package:frontend/features/home/presentation/screens/home_screen.dart';
import 'package:frontend/features/home/presentation/screens/login_screen.dart';
import 'package:frontend/features/onboarding/presentation/screens/intro_flow_screen.dart';
import 'package:frontend/models/doctor_model.dart';
import 'package:frontend/models/patient_model.dart';

void main() {
  testWidgets('login screen renders main elements', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('HeartHealth'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Cadastre-se'), findsOneWidget);
    expect(find.text('CRM'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
  });

  testWidgets('doctor registration returns to login', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.tap(find.text('Cadastre-se'));
    await tester.pumpAndSettle();
    expect(find.byType(DoctorRegisterScreen), findsOneWidget);

    await tester.tap(find.text('Voltar para login'));
    await tester.pumpAndSettle();
    expect(find.text('Entrar'), findsOneWidget);
  });

  testWidgets('home lists patients from different doctors', (tester) async {
    PatientModel patient({
      required String id,
      required String doctorId,
      required String name,
    }) {
      return PatientModel(
        id: id,
        doctorId: doctorId,
        name: name,
        age: 40,
        gender: 'Feminino',
        bmi: 23.5,
        highBp: false,
        highChol: false,
        smoker: false,
        physActivity: true,
        stroke: false,
        createdAt: DateTime.utc(2026, 10, 12),
      );
    }

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          patientsStream: Stream.value([
            patient(id: 'patient-1', doctorId: 'doctor-1', name: 'Ana Silva'),
            patient(
              id: 'patient-2',
              doctorId: 'doctor-2',
              name: 'Carlos Mendes',
            ),
          ]),
          doctorProfileStream: Stream.value(
            const DoctorModel(
              uid: 'doctor-1',
              name: 'Dra. Teste',
              crm: 'CRM123456',
              email: 'doctor@example.com',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ana Silva'), findsOneWidget);
    expect(find.text('Carlos Mendes'), findsOneWidget);
    expect(find.text('2 pacientes'), findsOneWidget);
  });

  testWidgets('intro flow presents splash, onboarding and completes', (
    tester,
  ) async {
    var completed = false;
    await tester.pumpWidget(
      MaterialApp(home: IntroFlowScreen(onCompleted: () => completed = true)),
    );

    expect(find.text('Avaliação de risco cardíaco'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();

    expect(find.text('Cadastre seus Pacientes'), findsOneWidget);
    await tester.tap(find.text('Próximo'));
    await tester.pumpAndSettle();
    expect(find.text('Predição de Risco Cardíaco'), findsOneWidget);

    await tester.tap(find.text('Próximo'));
    await tester.pumpAndSettle();
    expect(find.text('Agende Consultas'), findsOneWidget);

    await tester.tap(find.text('Começar'));
    expect(completed, isTrue);
  });

  testWidgets('skipping onboarding completes without showing the last page', (
    tester,
  ) async {
    var completed = false;
    await tester.pumpWidget(
      MaterialApp(home: IntroFlowScreen(onCompleted: () => completed = true)),
    );
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pular'));
    await tester.pumpAndSettle();

    expect(completed, isTrue);
    expect(find.text('Cadastre seus Pacientes'), findsOneWidget);
    expect(find.text('Agende Consultas'), findsNothing);
  });
}
