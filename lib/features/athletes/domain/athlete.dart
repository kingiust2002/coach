enum TrainingLevel {
  beginner,
  intermediate,
  advanced;

  String get label {
    switch (this) {
      case TrainingLevel.beginner:
        return 'مبتدی';
      case TrainingLevel.intermediate:
        return 'متوسط';
      case TrainingLevel.advanced:
        return 'پیشرفته';
    }
  }

  String get description {
    switch (this) {
      case TrainingLevel.beginner:
        return 'کمتر از شش ماه تمرین منظم';
      case TrainingLevel.intermediate:
        return 'حداقل شش ماه تمرین منظم و تسلط نسبی بر حرکات';
      case TrainingLevel.advanced:
        return 'سابقه طولانی، اجرای پایدار و تجربه برنامه‌های ساختاریافته';
    }
  }

  static TrainingLevel fromStorage(String value) {
    return TrainingLevel.values.firstWhere(
      (TrainingLevel item) => item.name == value,
      orElse: () => TrainingLevel.beginner,
    );
  }
}

enum AthleteGoal {
  generalFitness,
  muscleGain,
  fatLoss,
  strength,
  endurance,
  mobility,
  rehabilitation,
  sportPerformance,
  other;

  String get label {
    switch (this) {
      case AthleteGoal.generalFitness:
        return 'تناسب اندام عمومی';
      case AthleteGoal.muscleGain:
        return 'عضله‌سازی';
      case AthleteGoal.fatLoss:
        return 'کاهش چربی';
      case AthleteGoal.strength:
        return 'افزایش قدرت';
      case AthleteGoal.endurance:
        return 'استقامت';
      case AthleteGoal.mobility:
        return 'انعطاف و تحرک';
      case AthleteGoal.rehabilitation:
        return 'بازگشت تدریجی به تمرین';
      case AthleteGoal.sportPerformance:
        return 'عملکرد ورزشی';
      case AthleteGoal.other:
        return 'هدف دیگر';
    }
  }

  String get description {
    switch (this) {
      case AthleteGoal.generalFitness:
        return 'سلامت، آمادگی و عملکرد روزمره بهتر';
      case AthleteGoal.muscleGain:
        return 'افزایش حجم عضلانی با برنامه مقاومتی';
      case AthleteGoal.fatLoss:
        return 'کاهش درصد چربی همراه با حفظ عملکرد';
      case AthleteGoal.strength:
        return 'بهبود توان تولید نیرو و رکوردهای اصلی';
      case AthleteGoal.endurance:
        return 'افزایش ظرفیت هوازی یا استقامت عضلانی';
      case AthleteGoal.mobility:
        return 'بهبود دامنه حرکت، کنترل و کیفیت الگوها';
      case AthleteGoal.rehabilitation:
        return 'تمرین کنترل‌شده پس از تأیید متخصص درمان';
      case AthleteGoal.sportPerformance:
        return 'بهبود ویژگی‌های موردنیاز یک رشته ورزشی';
      case AthleteGoal.other:
        return 'هدف اختصاصی در بخش توضیحات ثبت می‌شود';
    }
  }

  static AthleteGoal fromStorage(String value) {
    return AthleteGoal.values.firstWhere(
      (AthleteGoal item) => item.name == value,
      orElse: () => AthleteGoal.generalFitness,
    );
  }
}

enum TrainingEnvironment {
  gym,
  home,
  outdoor,
  mixed;

  String get label {
    switch (this) {
      case TrainingEnvironment.gym:
        return 'باشگاه';
      case TrainingEnvironment.home:
        return 'خانه';
      case TrainingEnvironment.outdoor:
        return 'فضای باز';
      case TrainingEnvironment.mixed:
        return 'ترکیبی';
    }
  }

  String get description {
    switch (this) {
      case TrainingEnvironment.gym:
        return 'دسترسی به دستگاه، وزنه آزاد و تجهیزات باشگاهی';
      case TrainingEnvironment.home:
        return 'تمرین با فضای و تجهیزات محدود خانگی';
      case TrainingEnvironment.outdoor:
        return 'تمرین در پارک، پیست یا محیط باز';
      case TrainingEnvironment.mixed:
        return 'ترکیب چند محیط بر اساس برنامه هفتگی';
    }
  }

  static TrainingEnvironment fromStorage(String value) {
    return TrainingEnvironment.values.firstWhere(
      (TrainingEnvironment item) => item.name == value,
      orElse: () => TrainingEnvironment.gym,
    );
  }
}

class AthleteProfileInput {
  const AthleteProfileInput({
    required this.fullName,
    required this.phone,
    required this.birthDate,
    required this.primaryGoal,
    required this.goal,
    required this.trainingLevel,
    required this.experienceMonths,
    required this.preferredDaysPerWeek,
    required this.preferredSessionMinutes,
    required this.trainingEnvironment,
    required this.injuries,
    required this.medicalNotes,
    required this.notes,
  });

  final String fullName;
  final String phone;
  final DateTime? birthDate;
  final AthleteGoal primaryGoal;
  final String goal;
  final TrainingLevel trainingLevel;
  final int experienceMonths;
  final int preferredDaysPerWeek;
  final int preferredSessionMinutes;
  final TrainingEnvironment trainingEnvironment;
  final String injuries;
  final String medicalNotes;
  final String notes;
}

class Athlete {
  const Athlete({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.birthDate,
    required this.primaryGoal,
    required this.goal,
    required this.trainingLevel,
    required this.experienceMonths,
    required this.preferredDaysPerWeek,
    required this.preferredSessionMinutes,
    required this.trainingEnvironment,
    required this.injuries,
    required this.medicalNotes,
    required this.notes,
    required this.isActive,
    required this.archivedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  static const Object _unset = Object();

  final String id;
  final String fullName;
  final String phone;
  final DateTime? birthDate;
  final AthleteGoal primaryGoal;
  final String goal;
  final TrainingLevel trainingLevel;
  final int experienceMonths;
  final int preferredDaysPerWeek;
  final int preferredSessionMinutes;
  final TrainingEnvironment trainingEnvironment;
  final String injuries;
  final String medicalNotes;
  final String notes;
  final bool isActive;
  final DateTime? archivedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  int? ageAt(DateTime referenceDate) {
    final DateTime? birth = birthDate;
    if (birth == null) {
      return null;
    }
    int age = referenceDate.year - birth.year;
    final bool beforeBirthday =
        referenceDate.month < birth.month ||
        (referenceDate.month == birth.month && referenceDate.day < birth.day);
    if (beforeBirthday) {
      age--;
    }
    return age;
  }

  Athlete copyWith({
    String? fullName,
    String? phone,
    Object? birthDate = _unset,
    AthleteGoal? primaryGoal,
    String? goal,
    TrainingLevel? trainingLevel,
    int? experienceMonths,
    int? preferredDaysPerWeek,
    int? preferredSessionMinutes,
    TrainingEnvironment? trainingEnvironment,
    String? injuries,
    String? medicalNotes,
    String? notes,
    bool? isActive,
    Object? archivedAt = _unset,
    DateTime? updatedAt,
  }) {
    return Athlete(
      id: id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      birthDate: identical(birthDate, _unset)
          ? this.birthDate
          : birthDate as DateTime?,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      goal: goal ?? this.goal,
      trainingLevel: trainingLevel ?? this.trainingLevel,
      experienceMonths: experienceMonths ?? this.experienceMonths,
      preferredDaysPerWeek: preferredDaysPerWeek ?? this.preferredDaysPerWeek,
      preferredSessionMinutes:
          preferredSessionMinutes ?? this.preferredSessionMinutes,
      trainingEnvironment: trainingEnvironment ?? this.trainingEnvironment,
      injuries: injuries ?? this.injuries,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      archivedAt: identical(archivedAt, _unset)
          ? this.archivedAt
          : archivedAt as DateTime?,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Athlete applyProfile(AthleteProfileInput input, DateTime updatedAt) {
    return copyWith(
      fullName: input.fullName,
      phone: input.phone,
      birthDate: input.birthDate,
      primaryGoal: input.primaryGoal,
      goal: input.goal,
      trainingLevel: input.trainingLevel,
      experienceMonths: input.experienceMonths,
      preferredDaysPerWeek: input.preferredDaysPerWeek,
      preferredSessionMinutes: input.preferredSessionMinutes,
      trainingEnvironment: input.trainingEnvironment,
      injuries: input.injuries,
      medicalNotes: input.medicalNotes,
      notes: input.notes,
      updatedAt: updatedAt,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'birth_date': birthDate?.toUtc().toIso8601String(),
      'primary_goal': primaryGoal.name,
      'goal': goal,
      'training_level': trainingLevel.name,
      'experience_months': experienceMonths,
      'preferred_days_per_week': preferredDaysPerWeek,
      'preferred_session_minutes': preferredSessionMinutes,
      'training_environment': trainingEnvironment.name,
      'injuries': injuries,
      'medical_notes': medicalNotes,
      'notes': notes,
      'is_active': isActive ? 1 : 0,
      'archived_at': archivedAt?.toUtc().toIso8601String(),
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }

  factory Athlete.fromMap(Map<String, Object?> map) {
    return Athlete(
      id: map['id']! as String,
      fullName: map['full_name']! as String,
      phone: (map['phone'] as String?) ?? '',
      birthDate: _dateOrNull(map['birth_date']),
      primaryGoal: AthleteGoal.fromStorage(
        (map['primary_goal'] as String?) ?? '',
      ),
      goal: (map['goal'] as String?) ?? '',
      trainingLevel: TrainingLevel.fromStorage(
        (map['training_level'] as String?) ?? '',
      ),
      experienceMonths: (map['experience_months'] as int?) ?? 0,
      preferredDaysPerWeek: (map['preferred_days_per_week'] as int?) ?? 3,
      preferredSessionMinutes: (map['preferred_session_minutes'] as int?) ?? 60,
      trainingEnvironment: TrainingEnvironment.fromStorage(
        (map['training_environment'] as String?) ?? '',
      ),
      injuries: (map['injuries'] as String?) ?? '',
      medicalNotes: (map['medical_notes'] as String?) ?? '',
      notes: (map['notes'] as String?) ?? '',
      isActive: (map['is_active'] as int? ?? 1) == 1,
      archivedAt: _dateOrNull(map['archived_at']),
      createdAt: DateTime.parse(map['created_at']! as String).toUtc(),
      updatedAt: DateTime.parse(map['updated_at']! as String).toUtc(),
    );
  }

  static DateTime? _dateOrNull(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value)?.toUtc();
  }
}
