import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mood_tracker/data/mood_repository.dart';
import 'package:mood_tracker/mood_app.dart';
import 'package:mood_tracker/models/mood_entry.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('a person can create a local profile and reach the home screen', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(MoodApp(repository: MoodRepository(preferences)));
    await tester.pumpAndSettle();

    expect(find.text('Un momento para ti'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('nameField')), 'Ana');
    await tester.tap(find.byKey(const Key('startButton')));
    await tester.pumpAndSettle();

    expect(find.text('Hola, Ana'), findsOneWidget);
    expect(MoodRepository(preferences).loadName(), 'Ana');
  });

  testWidgets('a mood check-in is saved and appears in history', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'profile_name': 'Ana'});
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(MoodApp(repository: MoodRepository(preferences)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('moodOption-good')));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveMoodButton')));
    await tester.pumpAndSettle();

    expect(
      find.text('Tu ánimo quedó registrado. Gracias por escucharte.'),
      findsOneWidget,
    );
    expect(
      (await MoodRepository(preferences).loadEntries()).single.mood.label,
      'Bien',
    );

    await tester.tap(find.text('Historial'));
    await tester.pumpAndSettle();
    expect(find.text('Tu historial'), findsOneWidget);
    expect(find.text('Bien'), findsOneWidget);
  });
}
