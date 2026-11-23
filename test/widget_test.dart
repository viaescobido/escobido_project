import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:escobido_project/app.dart';

/// Use a tall window so every button is visible without scrolling.
void _tall(WidgetTester tester) {
  tester.view.physicalSize = const Size(900, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Login (guest) -> Home -> Report form.
Future<void> _openReport(WidgetTester tester) async {
  await tester.pumpWidget(const ParkKeysApp());
  await tester.tap(find.text('Continue as Guest'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Report a Problem'));
  await tester.pumpAndSettle();
}

Future<void> _fillValidForm(WidgetTester tester) async {
  await tester.tap(find.text('Tricycle'));
  await tester.tap(find.text('Queue skipping'));
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), 'Driver skipped me');
  await tester.enterText(
      fields.at(1), 'A tricycle drove past me while I was next in line.');
  await tester.pump();
}

void main() {
  testWidgets('Login page still opens first (Activity 8)', (tester) async {
    _tall(tester);
    await tester.pumpWidget(const ParkKeysApp());

    expect(find.text('Welcome back!'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);
  });

  testWidgets('Home has a Report a Problem action', (tester) async {
    _tall(tester);
    await tester.pumpWidget(const ParkKeysApp());
    await tester.tap(find.text('Continue as Guest'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome, Passenger!'), findsOneWidget);
    expect(find.text('Report a Problem'), findsOneWidget);
  });

  testWidgets('Validation shows field-level errors', (tester) async {
    _tall(tester);
    await _openReport(tester);

    await tester.tap(find.text('Send Report'));
    await tester.pump();

    expect(find.text('Choose the transportation.'), findsOneWidget);
    expect(find.text('Enter a short title.'), findsOneWidget);
  });

  testWidgets('EMPTY state before any report is created', (tester) async {
    _tall(tester);
    await _openReport(tester);

    await tester.tap(find.text('My Reports (0)'));
    await tester.pump();

    expect(find.text('No reports yet.'), findsOneWidget);
  });

  testWidgets('LOADING then SUCCESS for a valid report', (tester) async {
    _tall(tester);
    await _openReport(tester);
    await _fillValidForm(tester);

    await tester.tap(find.text('Send Report'));
    await tester.pump();
    expect(find.textContaining('Sending your report'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    expect(find.text('Report sent.'), findsOneWidget);
  });

  testWidgets('ERROR state appears when failure is simulated', (tester) async {
    _tall(tester);
    await _openReport(tester);
    await _fillValidForm(tester);

    await tester.tap(find.byType(Switch));
    await tester.pump();
    await tester.tap(find.text('Send Report'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(find.text('Couldn’t send your report.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}