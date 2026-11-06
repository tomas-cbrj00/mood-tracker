import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/mood_entry.dart';

class MoodRepository {
  MoodRepository(this._preferences);

  static const _nameKey = 'profile_name';
  static const _entriesKey = 'mood_entries';
  static const _activitiesKey = 'activity_logs';

  final SharedPreferences _preferences;

  String? loadName() => _preferences.getString(_nameKey);

  Future<void> saveName(String name) async {
    final saved = await _preferences.setString(_nameKey, name.trim());
    if (!saved) {
      throw StateError('No se pudo guardar el perfil en este dispositivo.');
    }
  }

  Future<List<MoodEntry>> loadEntries() async {
    final rawEntries = _preferences.getString(_entriesKey);
    if (rawEntries == null) return [];

    final decoded = jsonDecode(rawEntries) as List<dynamic>;
    final entries =
        decoded
            .map((item) => MoodEntry.fromJson(item as Map<String, dynamic>))
            .toList()
          ..sort(
            (first, second) => second.createdAt.compareTo(first.createdAt),
          );
    return entries;
  }

  Future<void> saveEntry(MoodEntry entry) async {
    final entries = await loadEntries();
    entries.insert(0, entry);
    final saved = await _preferences.setString(
      _entriesKey,
      jsonEncode(entries.map((item) => item.toJson()).toList()),
    );
    if (!saved) {
      throw StateError('No se pudo guardar tu registro de ánimo.');
    }
  }

  Future<List<ActivityLog>> loadActivities() async {
    final rawActivities = _preferences.getString(_activitiesKey);
    if (rawActivities == null) return [];

    final decoded = jsonDecode(rawActivities) as List<dynamic>;
    return decoded
        .map((item) => ActivityLog.fromJson(item as Map<String, dynamic>))
        .toList()
      ..sort(
        (first, second) => second.completedAt.compareTo(first.completedAt),
      );
  }

  Future<void> logActivity(String title, {String note = ''}) async {
    final activities = await loadActivities();
    activities.insert(
      0,
      ActivityLog(title: title, note: note, completedAt: DateTime.now()),
    );
    final saved = await _preferences.setString(
      _activitiesKey,
      jsonEncode(activities.take(2000).map((item) => item.toJson()).toList()),
    );
    if (!saved) {
      throw StateError('No se pudo guardar la actividad completada.');
    }
  }

  Future<void> clearAll() async {
    final cleared = await _preferences.clear();
    if (!cleared) {
      throw StateError('No se pudieron eliminar los datos locales.');
    }
  }
}

class ActivityLog {
  const ActivityLog({
    required this.title,
    required this.note,
    required this.completedAt,
  });

  final String title;
  final String note;
  final DateTime completedAt;

  Map<String, dynamic> toJson() => {
    'title': title,
    'note': note,
    'completedAt': completedAt.toIso8601String(),
  };

  factory ActivityLog.fromJson(Map<String, dynamic> json) => ActivityLog(
    title: json['title'] as String,
    note: json['note'] as String,
    completedAt: DateTime.parse(json['completedAt'] as String),
  );
}
