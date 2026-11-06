enum Mood { great, good, okay, low, rough }

extension MoodDetails on Mood {
  String get label => switch (this) {
    Mood.great => 'Muy bien',
    Mood.good => 'Bien',
    Mood.okay => 'Normal',
    Mood.low => 'Bajo',
    Mood.rough => 'Muy mal',
  };

  String get emoji => switch (this) {
    Mood.great => '😄',
    Mood.good => '🙂',
    Mood.okay => '😐',
    Mood.low => '😔',
    Mood.rough => '😣',
  };

  int get score => switch (this) {
    Mood.great => 5,
    Mood.good => 4,
    Mood.okay => 3,
    Mood.low => 2,
    Mood.rough => 1,
  };
}

class MoodEntry {
  const MoodEntry({
    required this.id,
    required this.mood,
    required this.note,
    required this.createdAt,
  });

  final String id;
  final Mood mood;
  final String note;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'mood': mood.name,
    'note': note,
    'createdAt': createdAt.toIso8601String(),
  };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
    id: json['id'] as String,
    mood: Mood.values.byName(json['mood'] as String),
    note: json['note'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
