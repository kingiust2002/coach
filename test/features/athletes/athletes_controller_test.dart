import 'package:coach_app/features/athletes/data/athlete_repository.dart';
import 'package:coach_app/features/athletes/domain/athlete.dart';
import 'package:coach_app/features/athletes/presentation/athletes_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryAthleteRepository implements AthleteRepository {
  final List<Athlete> items = <Athlete>[];

  @override
  Future<void> archive(String id, DateTime updatedAt) async {
    final int index = items.indexWhere((Athlete item) => item.id == id);
    items[index] = items[index].copyWith(
      isActive: false,
      archivedAt: updatedAt,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<List<Athlete>> getAll({bool includeArchived = false}) async {
    return items
        .where((Athlete item) => includeArchived || item.isActive)
        .toList(growable: false);
  }

  @override
  Future<Athlete?> getById(String id) async {
    for (final Athlete athlete in items) {
      if (athlete.id == id) {
        return athlete;
      }
    }
    return null;
  }

  @override
  Future<void> restore(String id, DateTime updatedAt) async {
    final int index = items.indexWhere((Athlete item) => item.id == id);
    items[index] = items[index].copyWith(
      isActive: true,
      archivedAt: null,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<void> save(Athlete athlete) async {
    final int index = items.indexWhere((Athlete item) => item.id == athlete.id);
    if (index == -1) {
      items.add(athlete);
    } else {
      items[index] = athlete;
    }
  }
}

const AthleteProfileInput _validInput = AthleteProfileInput(
  fullName: '  شاگرد   آزمایشی  ',
  phone: '۰۹۱۲-۰۰۰-۰۰۰۰',
  birthDate: null,
  primaryGoal: AthleteGoal.muscleGain,
  goal: '  افزایش حجم  ',
  trainingLevel: TrainingLevel.intermediate,
  experienceMonths: 18,
  preferredDaysPerWeek: 4,
  preferredSessionMinutes: 75,
  trainingEnvironment: TrainingEnvironment.gym,
  injuries: '',
  medicalNotes: '',
  notes: '  یادداشت مربی  ',
);

void main() {
  test('create normalizes localized input and loads all statuses', () async {
    final _MemoryAthleteRepository repository = _MemoryAthleteRepository();
    final AthletesController controller = AthletesController(repository);

    await controller.create(_validInput);

    expect(repository.items, hasLength(1));
    expect(controller.athletes, hasLength(1));
    expect(controller.athletes.single.fullName, 'شاگرد آزمایشی');
    expect(controller.athletes.single.phone, '09120000000');
    expect(controller.athletes.single.goal, 'افزایش حجم');
    expect(controller.activeCount, 1);
    expect(controller.archivedCount, 0);
  });

  test('archive and restore preserve the same athlete identity', () async {
    final _MemoryAthleteRepository repository = _MemoryAthleteRepository();
    final AthletesController controller = AthletesController(repository);
    await controller.create(_validInput);
    final String id = controller.athletes.single.id;

    await controller.archive(controller.athletes.single);
    expect(controller.byId(id)?.isActive, isFalse);
    expect(controller.byId(id)?.archivedAt, isNotNull);
    expect(controller.archivedCount, 1);

    await controller.restore(controller.byId(id)!);
    expect(controller.byId(id)?.isActive, isTrue);
    expect(controller.byId(id)?.archivedAt, isNull);
    expect(controller.byId(id)?.id, id);
  });

  test('invalid scheduling preference is rejected before persistence', () async {
    final _MemoryAthleteRepository repository = _MemoryAthleteRepository();
    final AthletesController controller = AthletesController(repository);
    const AthleteProfileInput invalid = AthleteProfileInput(
      fullName: 'شاگرد',
      phone: '',
      birthDate: null,
      primaryGoal: AthleteGoal.generalFitness,
      goal: '',
      trainingLevel: TrainingLevel.beginner,
      experienceMonths: 0,
      preferredDaysPerWeek: 8,
      preferredSessionMinutes: 60,
      trainingEnvironment: TrainingEnvironment.home,
      injuries: '',
      medicalNotes: '',
      notes: '',
    );

    expect(() => controller.create(invalid), throwsA(isA<FormatException>()));
    expect(repository.items, isEmpty);
  });
}
