import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/mood_repository.dart';
import 'mood_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(MoodApp(repository: MoodRepository(preferences)));
}
