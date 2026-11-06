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

  testWidgets('self-care activities can be completed and saved', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'profile_name': 'Ana'});
    final preferences = await SharedPreferences.getInstance();
    final repository = MoodRepository(preferences);

    await tester.pumpWidget(MoodApp(repository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Actividades'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Pausa sin pantalla'));
    await tester.tap(find.text('Pausa sin pantalla'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      find.text('¡Bien hecho! "Pausa sin pantalla" quedó guardada.'),
      findsOneWidget,
    );
    expect(
      (await repository.loadActivities()).map((activity) => activity.title),
      contains('Pausa sin pantalla'),
    );

    ScaffoldMessenger.of(tester.element(find.byType(Scaffold)))
        .hideCurrentSnackBar();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Un vaso de agua'));
    await tester.tap(find.text('Un vaso de agua'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      find.text('¡Bien hecho! "Un vaso de agua" quedó guardada.'),
      findsOneWidget,
    );
    expect(
      (await repository.loadActivities()).map((activity) => activity.title),
      contains('Un vaso de agua'),
    );
  });

  testWidgets('the gratitude activity accepts a note and saves it', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'profile_name': 'Ana'});
    final preferences = await SharedPreferences.getInstance();
    final repository = MoodRepository(preferences);

    await tester.pumpWidget(MoodApp(repository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Actividades'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Diario de gratitud'));
    await tester.tap(find.text('Diario de gratitud'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).last,
      'Un momento bonito con mi familia',
    );
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    final activity = (await repository.loadActivities()).single;
    expect(activity.title, 'Diario de gratitud');
    expect(activity.note, 'Un momento bonito con mi familia');
    expect(tester.takeException(), isNull);
  });

  testWidgets('breathing activity opens and starts its timer', (tester) async {
    SharedPreferences.setMockInitialValues({'profile_name': 'Ana'});
    final preferences = await SharedPreferences.getInstance();
    final repository = MoodRepository(preferences);

    await tester.pumpWidget(MoodApp(repository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Actividades'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Respiración consciente'));
    await tester.tap(find.text('Respiración consciente').last);
    await tester.pumpAndSettle();

    expect(find.text('Respirar con calma'), findsNothing);
    expect(find.text('03:00'), findsOneWidget);
    await tester.tap(find.text('Iniciar'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Pausar'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(await repository.loadActivities(), isEmpty);
  });
}
