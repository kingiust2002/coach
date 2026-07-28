abstract final class DatabaseSchema {
  static const String fileName = 'coach_app.db';
  static const int version = 4;

  static const String athletes = 'athletes';
  static const String exercises = 'exercises';

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

  static const String createExercises =
      '''
CREATE TABLE $exercises (
  id TEXT PRIMARY KEY,
  name_fa TEXT NOT NULL,
  name_key TEXT NOT NULL UNIQUE,
  name_en TEXT NOT NULL DEFAULT '',
  primary_muscle TEXT NOT NULL,
  secondary_muscles TEXT NOT NULL DEFAULT '[]',
  exercise_type TEXT NOT NULL,
  equipment TEXT NOT NULL,
  difficulty TEXT NOT NULL,
  movement_pattern TEXT NOT NULL,
  laterality TEXT NOT NULL DEFAULT 'bilateral',
  instructions TEXT NOT NULL DEFAULT '',
  safety_notes TEXT NOT NULL DEFAULT '',
  coach_notes TEXT NOT NULL DEFAULT '',
  is_active INTEGER NOT NULL DEFAULT 1,
  is_system INTEGER NOT NULL DEFAULT 0,
  archived_at TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
''';

  static const String exercisesFilterIndex =
      '''
CREATE INDEX idx_exercises_filters
ON $exercises (
  is_active,
  primary_muscle,
  equipment,
  exercise_type,
  difficulty
)
''';

  static const String exercisesNameIndex =
      '''
CREATE INDEX idx_exercises_name
ON $exercises (name_fa COLLATE NOCASE, name_en COLLATE NOCASE)
''';

  static const String exercisesSystemIndex =
      '''
CREATE INDEX idx_exercises_system_active
ON $exercises (is_system DESC, is_active DESC, updated_at DESC)
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

  static const List<String> migrateToV3 = <String>[
    createExercises,
    exercisesFilterIndex,
    exercisesNameIndex,
    exercisesSystemIndex,
  ];

  static const String _seedTime = '2026-01-01T00:00:00.000Z';

  static const List<Map<String, Object?>>
  systemExerciseSeeds = <Map<String, Object?>>[
    <String, Object?>{
      'id': 'sys_back_squat',
      'name_fa': 'اسکوات هالتر پشت',
      'name_key': 'اسکوات هالتر پشت',
      'name_en': 'Barbell Back Squat',
      'primary_muscle': 'quadriceps',
      'secondary_muscles': '["glutes","hamstrings","core"]',
      'exercise_type': 'compound',
      'equipment': 'barbell',
      'difficulty': 'intermediate',
      'movement_pattern': 'squat',
      'laterality': 'bilateral',
      'instructions':
          'هالتر را پایدار روی پشت قرار دهید، تنه را کنترل کنید و با حفظ مسیر زانو و کف پا پایین بروید.',
      'safety_notes':
          'ستون فقرات خنثی بماند و عمق حرکت متناسب با کنترل و دامنه بدون درد انتخاب شود.',
      'coach_notes': '',
      'is_active': 1,
      'is_system': 1,
      'archived_at': null,
      'created_at': _seedTime,
      'updated_at': _seedTime,
    },
    <String, Object?>{
      'id': 'sys_goblet_squat',
      'name_fa': 'اسکوات گابلت',
      'name_key': 'اسکوات گابلت',
      'name_en': 'Goblet Squat',
      'primary_muscle': 'quadriceps',
      'secondary_muscles': '["glutes","core"]',
      'exercise_type': 'compound',
      'equipment': 'dumbbell',
      'difficulty': 'beginner',
      'movement_pattern': 'squat',
      'laterality': 'bilateral',
      'instructions':
          'دمبل را نزدیک سینه نگه دارید و با کنترل لگن و زانو بنشینید و بلند شوید.',
      'safety_notes': 'پاشنه‌ها روی زمین و زانوها هم‌جهت پنجه‌ها باقی بمانند.',
      'coach_notes': '',
      'is_active': 1,
      'is_system': 1,
      'archived_at': null,
      'created_at': _seedTime,
      'updated_at': _seedTime,
    },
    <String, Object?>{
      'id': 'sys_deadlift',
      'name_fa': 'ددلیفت هالتر',
      'name_key': 'ددلیفت هالتر',
      'name_en': 'Barbell Deadlift',
      'primary_muscle': 'hamstrings',
      'secondary_muscles': '["glutes","back","core"]',
      'exercise_type': 'compound',
      'equipment': 'barbell',
      'difficulty': 'advanced',
      'movement_pattern': 'hinge',
      'laterality': 'bilateral',
      'instructions':
          'میله را نزدیک ساق نگه دارید، لگن را عقب ببرید و با فشار پاها و بازشدن لگن بلند شوید.',
      'safety_notes': 'پشت خنثی، شکم منقبض و بار متناسب با مهارت انتخاب شود.',
      'coach_notes': '',
      'is_active': 1,
      'is_system': 1,
      'archived_at': null,
      'created_at': _seedTime,
      'updated_at': _seedTime,
    },
    <String, Object?>{
      'id': 'sys_romanian_deadlift',
      'name_fa': 'ددلیفت رومانیایی',
      'name_key': 'ددلیفت رومانیایی',
      'name_en': 'Romanian Deadlift',
      'primary_muscle': 'hamstrings',
      'secondary_muscles': '["glutes","back"]',
      'exercise_type': 'compound',
      'equipment': 'barbell',
      'difficulty': 'intermediate',
      'movement_pattern': 'hinge',
      'laterality': 'bilateral',
      'instructions':
          'با زانوی کمی خم، لگن را عقب ببرید و میله را نزدیک ران و ساق پایین آورید.',
      'safety_notes':
          'دامنه را تا جایی ادامه دهید که ستون فقرات خنثی و کشش همسترینگ کنترل‌شده باشد.',
      'coach_notes': '',
      'is_active': 1,
      'is_system': 1,
      'archived_at': null,
      'created_at': _seedTime,
      'updated_at': _seedTime,
    },
    <String, Object?>{
      'id': 'sys_bench_press',
      'name_fa': 'پرس سینه هالتر',
      'name_key': 'پرس سینه هالتر',
      'name_en': 'Barbell Bench Press',
      'primary_muscle': 'chest',
      'secondary_muscles': '["triceps","shoulders"]',
      'exercise_type': 'compound',
      'equipment': 'barbell',
      'difficulty': 'intermediate',
      'movement_pattern': 'horizontalPush',
      'laterality': 'bilateral',
      'instructions':
          'کتف‌ها را پایدار کنید، میله را کنترل‌شده پایین آورید و در مسیر ثابت پرس کنید.',
      'safety_notes':
          'برای وزنه‌های سنگین از مراقب استفاده شود و مچ‌ها روی ساعد قرار بگیرند.',
      'coach_notes': '',
      'is_active': 1,
      'is_system': 1,
      'archived_at': null,
      'created_at': _seedTime,
      'updated_at': _seedTime,
    },
    <String, Object?>{
      'id': 'sys_push_up',
      'name_fa': 'شنا سوئدی',
      'name_key': 'شنا سوئدی',
      'name_en': 'Push-Up',
      'primary_muscle': 'chest',
      'secondary_muscles': '["triceps","shoulders","core"]',
      'exercise_type': 'compound',
      'equipment': 'bodyweight',
      'difficulty': 'beginner',
      'movement_pattern': 'horizontalPush',
      'laterality': 'bilateral',
      'instructions':
          'بدن را یکپارچه نگه دارید، سینه را کنترل‌شده پایین ببرید و زمین را دور کنید.',
      'safety_notes': 'افتادگی کمر یا جلوآمدن شدید سر ایجاد نشود.',
      'coach_notes': '',
      'is_active': 1,
      'is_system': 1,
      'archived_at': null,
      'created_at': _seedTime,
      'updated_at': _seedTime,
    },
    <String, Object?>{
      'id': 'sys_overhead_press',
      'name_fa': 'پرس سرشانه هالتر',
      'name_key': 'پرس سرشانه هالتر',
      'name_en': 'Barbell Overhead Press',
      'primary_muscle': 'shoulders',
      'secondary_muscles': '["triceps","core"]',
      'exercise_type': 'compound',
      'equipment': 'barbell',
      'difficulty': 'intermediate',
      'movement_pattern': 'verticalPush',
      'laterality': 'bilateral',
      'instructions':
          'میله را از جلوی شانه‌ها به بالای سر پرس کنید و تنه را پایدار نگه دارید.',
      'safety_notes': 'از قوس بیش‌ازحد کمر و مسیر دردناک شانه اجتناب شود.',
      'coach_notes': '',
      'is_active': 1,
      'is_system': 1,
      'archived_at': null,
      'created_at': _seedTime,
      'updated_at': _seedTime,
    },
    <String, Object?>{
      'id': 'sys_lateral_raise',
      'name_fa': 'نشر جانب دمبل',
      'name_key': 'نشر جانب دمبل',
      'name_en': 'Dumbbell Lateral Raise',
      'primary_muscle': 'shoulders',
      'secondary_muscles': '[]',
      'exercise_type': 'isolation',
      'equipment': 'dumbbell',
      'difficulty': 'beginner',
      'movement_pattern': 'isolation',
      'laterality': 'bilateral',
      'instructions':
          'دمبل‌ها را با آرنج کمی خم تا محدوده کنترل‌شده کنار بدن بالا ببرید.',
      'safety_notes':
          'با تاب‌دادن تنه یا بالابردن شانه‌ها حرکت را جبران نکنید.',
      'coach_notes': '',
      'is_active': 1,
      'is_system': 1,
      'archived_at': null,
      'created_at': _seedTime,
      'updated_at': _seedTime,
    },
    <String, Object?>{
      'id': 'sys_barbell_row',
      'name_fa': 'زیربغل هالتر خم',
      'name_key': 'زیربغل هالتر خم',
      'name_en': 'Barbell Bent-Over Row',
      'primary_muscle': 'back',
      'secondary_muscles': '["biceps","hamstrings","core"]',
      'exercise_type': 'compound',
      'equipment': 'barbell',
      'difficulty': 'intermediate',
      'movement_pattern': 'horizontalPull',
      'laterality': 'bilateral',
      'instructions':
          'در وضعیت هیپ‌هینج پایدار، میله را به سمت تنه بکشید و کتف‌ها را کنترل کنید.',
      'safety_notes': 'زاویه تنه و ستون فقرات در طول ست ثابت بماند.',
      'coach_notes': '',
      'is_active': 1,
      'is_system': 1,
      'archived_at': null,
      'created_at': _seedTime,
      'updated_at': _seedTime,
    },
    <String, Object?>{
      'id': 'sys_cable_row',
      'name_fa': 'قایقی کابل',
      'name_key': 'قایقی کابل',
      'name_en': 'Seated Cable Row',
      'primary_muscle': 'back',
      'secondary_muscles': '["biceps"]',
      'exercise_type': 'compound',
      'equipment': 'cable',
      'difficulty': 'beginner',
      'movement_pattern': 'horizontalPull',
      'laterality': 'bilateral',
      'instructions':
          'تنه را پایدار نگه دارید و دستگیره را با جمع‌کردن کتف‌ها به سمت بدن بکشید.',
      'safety_notes':
          'از تاب شدید تنه و جلوآمدن شانه‌ها در انتهای کشش جلوگیری شود.',
      'coach_notes': '',
      'is_active': 1,
      'is_system': 1,
      'archived_at': null,
      'created_at': _seedTime,
      'updated_at': _seedTime,
    },
    <String, Object?>{
      'id': 'sys_pull_up',
      'name_fa': 'بارفیکس',
      'name_key': 'بارفیکس',
      'name_en': 'Pull-Up',
      'primary_muscle': 'back',
      'secondary_muscles': '["biceps","core"]',
      'exercise_type': 'compound',
      'equipment': 'pullUpBar',
      'difficulty': 'advanced',
      'movement_pattern': 'verticalPull',
      'laterality': 'bilateral',
      'instructions':
          'از آویزان پایدار، بدن را با پایین‌آوردن کتف و خم‌کردن آرنج بالا بکشید.',
      'safety_notes': 'از تاب‌دادن کنترل‌نشده و دامنه دردناک شانه پرهیز شود.',
      'coach_notes': '',
      'is_active': 1,
      'is_system': 1,
      'archived_at': null,
      'created_at': _seedTime,
      'updated_at': _seedTime,
    },
    <String, Object?>{
      'id': 'sys_lat_pulldown',
      'name_fa': 'لت سیم‌کش',
      'name_key': 'لت سیم‌کش',
      'name_en': 'Lat Pulldown',
      'primary_muscle': 'back',
      'secondary_muscles': '["biceps"]',
      'exercise_type': 'compound',
      'equipment': 'cable',
      'difficulty': 'beginner',
      'movement_pattern': 'verticalPull',
      'laterality': 'bilateral',
      'instructions':
          'میله را با پایین‌آوردن کتف‌ها به سمت بالای سینه بکشید و کنترل‌شده بازگردانید.',
      'safety_notes': 'میله پشت گردن کشیده نشود و تنه بیش‌ازحد عقب نرود.',
      'coach_notes': '',
      'is_active': 1,
      'is_system': 1,
      'archived_at': null,
      'created_at': _seedTime,
      'updated_at': _seedTime,
    },
    <String, Object?>{
      'id': 'sys_reverse_lunge',
      'name_fa': 'لانج معکوس',
      'name_key': 'لانج معکوس',
      'name_en': 'Reverse Lunge',
      'primary_muscle': 'quadriceps',
      'secondary_muscles': '["glutes","hamstrings","core"]',
      'exercise_type': 'compound',
      'equipment': 'bodyweight',
      'difficulty': 'beginner',
      'movement_pattern': 'lunge',
      'laterality': 'alternating',
      'instructions':
          'یک پا را عقب ببرید، هر دو زانو را خم کنید و با فشار پای جلو بازگردید.',
      'safety_notes': 'تعادل و هم‌جهتی زانوی جلو با پنجه حفظ شود.',
      'coach_notes': '',
      'is_active': 1,
      'is_system': 1,
      'archived_at': null,
      'created_at': _seedTime,
      'updated_at': _seedTime,
    },
    <String, Object?>{
      'id': 'sys_hip_thrust',
      'name_fa': 'هیپ تراست هالتر',
      'name_key': 'هیپ تراست هالتر',
      'name_en': 'Barbell Hip Thrust',
      'primary_muscle': 'glutes',
      'secondary_muscles': '["hamstrings","core"]',
      'exercise_type': 'compound',
      'equipment': 'barbell',
      'difficulty': 'intermediate',
      'movement_pattern': 'hinge',
      'laterality': 'bilateral',
      'instructions':
          'پشت بالایی را روی نیمکت ثابت کنید و لگن را تا راستای کنترل‌شده بالا ببرید.',
      'safety_notes':
          'حرکت از لگن انجام شود و از بازکردن بیش‌ازحد کمر جلوگیری شود.',
      'coach_notes': '',
      'is_active': 1,
      'is_system': 1,
      'archived_at': null,
      'created_at': _seedTime,
      'updated_at': _seedTime,
    },
    <String, Object?>{
      'id': 'sys_biceps_curl',
      'name_fa': 'جلو بازو دمبل',
      'name_key': 'جلو بازو دمبل',
      'name_en': 'Dumbbell Biceps Curl',
      'primary_muscle': 'biceps',
      'secondary_muscles': '["forearms"]',
      'exercise_type': 'isolation',
      'equipment': 'dumbbell',
      'difficulty': 'beginner',
      'movement_pattern': 'isolation',
      'laterality': 'bilateral',
      'instructions':
          'آرنج‌ها را نزدیک بدن ثابت نگه دارید و دمبل‌ها را بدون تاب تنه بالا بیاورید.',
      'safety_notes': 'دامنه و بار باید بدون درد آرنج و مچ باشد.',
      'coach_notes': '',
      'is_active': 1,
      'is_system': 1,
      'archived_at': null,
      'created_at': _seedTime,
      'updated_at': _seedTime,
    },
    <String, Object?>{
      'id': 'sys_triceps_pushdown',
      'name_fa': 'پشت بازو سیم‌کش',
      'name_key': 'پشت بازو سیم‌کش',
      'name_en': 'Cable Triceps Pushdown',
      'primary_muscle': 'triceps',
      'secondary_muscles': '[]',
      'exercise_type': 'isolation',
      'equipment': 'cable',
      'difficulty': 'beginner',
      'movement_pattern': 'isolation',
      'laterality': 'bilateral',
      'instructions':
          'آرنج‌ها را کنار تنه ثابت کنید و ساعدها را تا بازشدن کنترل‌شده پایین ببرید.',
      'safety_notes': 'از جلوآمدن شانه و حرکت آرنج‌ها جلوگیری شود.',
      'coach_notes': '',
      'is_active': 1,
      'is_system': 1,
      'archived_at': null,
      'created_at': _seedTime,
      'updated_at': _seedTime,
    },
    <String, Object?>{
      'id': 'sys_calf_raise',
      'name_fa': 'ساق ایستاده',
      'name_key': 'ساق ایستاده',
      'name_en': 'Standing Calf Raise',
      'primary_muscle': 'calves',
      'secondary_muscles': '[]',
      'exercise_type': 'isolation',
      'equipment': 'bodyweight',
      'difficulty': 'beginner',
      'movement_pattern': 'isolation',
      'laterality': 'bilateral',
      'instructions':
          'پاشنه‌ها را با کنترل بالا ببرید، مکث کوتاه کنید و آهسته پایین بیاورید.',
      'safety_notes':
          'تعادل حفظ شود و از پرش یا ضربه در پایین دامنه پرهیز شود.',
      'coach_notes': '',
      'is_active': 1,
      'is_system': 1,
      'archived_at': null,
      'created_at': _seedTime,
      'updated_at': _seedTime,
    },
    <String, Object?>{
      'id': 'sys_plank',
      'name_fa': 'پلانک ساعد',
      'name_key': 'پلانک ساعد',
      'name_en': 'Forearm Plank',
      'primary_muscle': 'core',
      'secondary_muscles': '["shoulders","glutes"]',
      'exercise_type': 'isolation',
      'equipment': 'bodyweight',
      'difficulty': 'beginner',
      'movement_pattern': 'antiRotation',
      'laterality': 'bilateral',
      'instructions':
          'بدن را از سر تا پاشنه در خط نگه دارید و تنفس کنترل‌شده ادامه یابد.',
      'safety_notes': 'کمر نباید فرو بیفتد و گردن در امتداد ستون فقرات بماند.',
      'coach_notes': '',
      'is_active': 1,
      'is_system': 1,
      'archived_at': null,
      'created_at': _seedTime,
      'updated_at': _seedTime,
    },
  ];
}
