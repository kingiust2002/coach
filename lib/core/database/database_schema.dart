abstract final class DatabaseSchema {
  static const String fileName = 'coach_app.db';
  static const int version = 1;

  static const String athletes = 'athletes';

  static const String createAthletes =
      '''
CREATE TABLE $athletes (
  id TEXT PRIMARY KEY,
  full_name TEXT NOT NULL,
  phone TEXT NOT NULL DEFAULT '',
  goal TEXT NOT NULL DEFAULT '',
  training_level TEXT NOT NULL DEFAULT 'beginner',
  injuries TEXT NOT NULL DEFAULT '',
  notes TEXT NOT NULL DEFAULT '',
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
''';

  static const String athletesActiveIndex =
      '''
CREATE INDEX idx_athletes_active_name
ON $athletes (is_active, full_name)
''';
}
