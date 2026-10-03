// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/home/presentation/screens/login_screen.dart';
import 'package:frontend/features/onboarding/presentation/screens/intro_flow_screen.dart';

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
}
