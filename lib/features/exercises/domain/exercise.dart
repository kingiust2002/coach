import 'dart:convert';

enum MuscleGroup {
  chest('سینه'),
  back('پشت'),
  shoulders('سرشانه'),
  biceps('جلو بازو'),
  triceps('پشت بازو'),
  forearms('ساعد'),
  quadriceps('چهارسر ران'),
  hamstrings('همسترینگ'),
  glutes('سرینی'),
  calves('ساق'),
  core('میان‌تنه'),
  fullBody('تمام بدن');

  const MuscleGroup(this.label);
  final String label;
}

enum ExerciseType {
  compound('چندمفصلی'),
  isolation('تک‌مفصلی'),
  cardio('هوازی'),
  mobility('تحرک و انعطاف'),
  plyometric('توانی و پرشی');

  const ExerciseType(this.label);
  final String label;
}

enum ExerciseEquipment {
  bodyweight('وزن بدن'),
  barbell('هالتر'),
  dumbbell('دمبل'),
  machine('دستگاه'),
  cable('کابل'),
  resistanceBand('کش تمرینی'),
  kettlebell('کتل‌بل'),
  bench('نیمکت'),
  pullUpBar('میله بارفیکس'),
  cardioMachine('دستگاه هوازی'),
  other('سایر');

  const ExerciseEquipment(this.label);
  final String label;
}

enum ExerciseDifficulty {
  beginner('مبتدی'),
  intermediate('متوسط'),
  advanced('پیشرفته');

  const ExerciseDifficulty(this.label);
  final String label;
}

enum MovementPattern {
  squat('اسکوات'),
  hinge('خم‌کردن لگن'),
  horizontalPush('پرس افقی'),
  verticalPush('پرس عمودی'),
  horizontalPull('کشش افقی'),
  verticalPull('کشش عمودی'),
  lunge('لانج'),
  carry('حمل'),
  rotation('چرخش'),
  antiRotation('ضدچرخش'),
  locomotion('حرکت انتقالی'),
  isolation('ایزوله'),
  mobility('تحرک');

  const MovementPattern(this.label);
  final String label;
}

enum ExerciseLaterality {
  bilateral('دوطرفه'),
  unilateral('یک‌طرفه'),
  alternating('تناوبی');

  const ExerciseLaterality(this.label);
  final String label;
}

class ExerciseInput {
  const ExerciseInput({
    required this.nameFa,
    required this.nameEn,
    required this.primaryMuscle,
    required this.secondaryMuscles,
    required this.type,
    required this.equipment,
    required this.difficulty,
    required this.movementPattern,
    required this.laterality,
    required this.instructions,
    required this.safetyNotes,
    required this.coachNotes,
  });

  final String nameFa;
  final String nameEn;
  final MuscleGroup primaryMuscle;
  final Set<MuscleGroup> secondaryMuscles;
  final ExerciseType type;
  final ExerciseEquipment equipment;
  final ExerciseDifficulty difficulty;
  final MovementPattern movementPattern;
  final ExerciseLaterality laterality;
  final String instructions;
  final String safetyNotes;
  final String coachNotes;
}

class Exercise {
  const Exercise({
    required this.id,
    required this.nameFa,
    required this.nameKey,
    required this.nameEn,
    required this.primaryMuscle,
    required this.secondaryMuscles,
    required this.type,
    required this.equipment,
    required this.difficulty,
    required this.movementPattern,
    required this.laterality,
    required this.instructions,
    required this.safetyNotes,
    required this.coachNotes,
    required this.isActive,
    required this.isSystem,
    required this.archivedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String nameFa;
  final String nameKey;
  final String nameEn;
  final MuscleGroup primaryMuscle;
  final Set<MuscleGroup> secondaryMuscles;
  final ExerciseType type;
  final ExerciseEquipment equipment;
  final ExerciseDifficulty difficulty;
  final MovementPattern movementPattern;
  final ExerciseLaterality laterality;
  final String instructions;
  final String safetyNotes;
  final String coachNotes;
  final bool isActive;
  final bool isSystem;
  final DateTime? archivedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get displayName => nameEn.isEmpty ? nameFa : '$nameFa · $nameEn';

  Exercise applyInput(
    ExerciseInput input,
    String normalizedNameKey,
    DateTime now,
  ) {
    if (isSystem) {
      throw StateError('حرکت سیستمی قابل ویرایش نیست.');
    }
    return Exercise(
      id: id,
      nameFa: input.nameFa,
      nameKey: normalizedNameKey,
      nameEn: input.nameEn,
      primaryMuscle: input.primaryMuscle,
      secondaryMuscles: input.secondaryMuscles,
      type: input.type,
      equipment: input.equipment,
      difficulty: input.difficulty,
      movementPattern: input.movementPattern,
      laterality: input.laterality,
      instructions: input.instructions,
      safetyNotes: input.safetyNotes,
      coachNotes: input.coachNotes,
      isActive: isActive,
      isSystem: false,
      archivedAt: archivedAt,
      createdAt: createdAt,
      updatedAt: now,
    );
  }

  Map<String, Object?> toMap() => <String, Object?>{
    'id': id,
    'name_fa': nameFa,
    'name_key': nameKey,
    'name_en': nameEn,
    'primary_muscle': primaryMuscle.name,
    'secondary_muscles': jsonEncode(
      secondaryMuscles.map((MuscleGroup item) => item.name).toList(),
    ),
    'exercise_type': type.name,
    'equipment': equipment.name,
    'difficulty': difficulty.name,
    'movement_pattern': movementPattern.name,
    'laterality': laterality.name,
    'instructions': instructions,
    'safety_notes': safetyNotes,
    'coach_notes': coachNotes,
    'is_active': isActive ? 1 : 0,
    'is_system': isSystem ? 1 : 0,
    'archived_at': archivedAt?.toUtc().toIso8601String(),
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };

  factory Exercise.fromMap(Map<String, Object?> map) {
    final Object? rawSecondary = map['secondary_muscles'];
    final List<dynamic> decoded =
        rawSecondary is String && rawSecondary.isNotEmpty
        ? jsonDecode(rawSecondary) as List<dynamic>
        : <dynamic>[];
    return Exercise(
      id: map['id']! as String,
      nameFa: map['name_fa']! as String,
      nameKey: map['name_key']! as String,
      nameEn: map['name_en']! as String,
      primaryMuscle: _enumByName(MuscleGroup.values, map['primary_muscle']),
      secondaryMuscles: decoded
          .map((dynamic item) => _enumByName(MuscleGroup.values, item))
          .toSet(),
      type: _enumByName(ExerciseType.values, map['exercise_type']),
      equipment: _enumByName(ExerciseEquipment.values, map['equipment']),
      difficulty: _enumByName(ExerciseDifficulty.values, map['difficulty']),
      movementPattern: _enumByName(
        MovementPattern.values,
        map['movement_pattern'],
      ),
      laterality: _enumByName(ExerciseLaterality.values, map['laterality']),
      instructions: map['instructions']! as String,
      safetyNotes: map['safety_notes']! as String,
      coachNotes: map['coach_notes']! as String,
      isActive: (map['is_active']! as int) == 1,
      isSystem: (map['is_system']! as int) == 1,
      archivedAt: _dateOrNull(map['archived_at']),
      createdAt: DateTime.parse(map['created_at']! as String).toUtc(),
      updatedAt: DateTime.parse(map['updated_at']! as String).toUtc(),
    );
  }
}

T _enumByName<T extends Enum>(List<T> values, Object? raw) {
  final String name = raw?.toString() ?? '';
  return values.firstWhere(
    (T item) => item.name == name,
    orElse: () => values.first,
  );
}

DateTime? _dateOrNull(Object? raw) {
  if (raw == null || raw.toString().isEmpty) {
    return null;
  }
  return DateTime.parse(raw.toString()).toUtc();
}
