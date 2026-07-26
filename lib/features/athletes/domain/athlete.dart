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

  static TrainingLevel fromStorage(String value) {
    return TrainingLevel.values.firstWhere(
      (TrainingLevel item) => item.name == value,
      orElse: () => TrainingLevel.beginner,
    );
  }
}

class Athlete {
  const Athlete({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.goal,
    required this.trainingLevel,
    required this.injuries,
    required this.notes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String fullName;
  final String phone;
  final String goal;
  final TrainingLevel trainingLevel;
  final String injuries;
  final String notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Athlete copyWith({
    String? fullName,
    String? phone,
    String? goal,
    TrainingLevel? trainingLevel,
    String? injuries,
    String? notes,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return Athlete(
      id: id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      goal: goal ?? this.goal,
      trainingLevel: trainingLevel ?? this.trainingLevel,
      injuries: injuries ?? this.injuries,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'goal': goal,
      'training_level': trainingLevel.name,
      'injuries': injuries,
      'notes': notes,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }

  factory Athlete.fromMap(Map<String, Object?> map) {
    return Athlete(
      id: map['id']! as String,
      fullName: map['full_name']! as String,
      phone: (map['phone'] as String?) ?? '',
      goal: (map['goal'] as String?) ?? '',
      trainingLevel: TrainingLevel.fromStorage(
        (map['training_level'] as String?) ?? '',
      ),
      injuries: (map['injuries'] as String?) ?? '',
      notes: (map['notes'] as String?) ?? '',
      isActive: (map['is_active'] as int? ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at']! as String).toUtc(),
      updatedAt: DateTime.parse(map['updated_at']! as String).toUtc(),
    );
  }
}
