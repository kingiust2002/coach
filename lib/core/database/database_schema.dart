abstract final class DatabaseSchema {
  static const String fileName = 'coach_app.db';
  static const int version = 2;

  static const String athletes = 'athletes';

  static const String createAthletes =
      '''
CREATE TABLE $athletes (
  id TEXT PRIMARY KEY,
  full_name TEXT NOT NULL,
  phone TEXT NOT NULL DEFAULT '',
  birth_date TEXT,
  primary_goal TEXT NOT NULL DEFAULT 'generalFitness',
  goal TEXT NOT NULL DEFAULT '',
  training_level TEXT NOT NULL DEFAULT 'beginner',
  experience_months INTEGER NOT NULL DEFAULT 0,
  preferred_days_per_week INTEGER NOT NULL DEFAULT 3,
  preferred_session_minutes INTEGER NOT NULL DEFAULT 60,
  training_environment TEXT NOT NULL DEFAULT 'gym',
  injuries TEXT NOT NULL DEFAULT '',
  medical_notes TEXT NOT NULL DEFAULT '',
  notes TEXT NOT NULL DEFAULT '',
  is_active INTEGER NOT NULL DEFAULT 1,
  archived_at TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
''';

  static const String athletesActiveIndex =
      '''
CREATE INDEX idx_athletes_active_name
ON $athletes (is_active, full_name)
''';

  static const String athletesStatusUpdatedIndex =
      '''
CREATE INDEX idx_athletes_status_updated
ON $athletes (is_active, updated_at DESC)
''';

  static const String athletesPhoneIndex =
      '''
CREATE INDEX idx_athletes_phone
ON $athletes (phone)
''';

  static const List<String> migrateAthletesToV2 = <String>[
    'ALTER TABLE $athletes ADD COLUMN birth_date TEXT',
    "ALTER TABLE $athletes ADD COLUMN primary_goal TEXT NOT NULL DEFAULT 'generalFitness'",
    'ALTER TABLE $athletes ADD COLUMN experience_months INTEGER NOT NULL DEFAULT 0',
    'ALTER TABLE $athletes ADD COLUMN preferred_days_per_week INTEGER NOT NULL DEFAULT 3',
    'ALTER TABLE $athletes ADD COLUMN preferred_session_minutes INTEGER NOT NULL DEFAULT 60',
    "ALTER TABLE $athletes ADD COLUMN training_environment TEXT NOT NULL DEFAULT 'gym'",
    "ALTER TABLE $athletes ADD COLUMN medical_notes TEXT NOT NULL DEFAULT ''",
    'ALTER TABLE $athletes ADD COLUMN archived_at TEXT',
    athletesStatusUpdatedIndex,
    athletesPhoneIndex,
  ];
}
