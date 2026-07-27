import 'package:flutter/foundation.dart';

import '../../../core/utils/id_generator.dart';
import '../../../core/utils/input_normalizer.dart';
import '../data/exercise_repository.dart';
import '../domain/exercise.dart';

class ExercisesController extends ChangeNotifier {
  ExercisesController(this._repository);

  final ExerciseRepository _repository;
  final List<Exercise> _exercises = <Exercise>[];

  bool _isLoading = false;
  bool _isMutating = false;
  Object? _error;

  List<Exercise> get exercises => List<Exercise>.unmodifiable(_exercises);
  bool get isLoading => _isLoading;
  bool get isMutating => _isMutating;
  Object? get error => _error;
  int get activeCount =>
      _exercises.where((Exercise item) => item.isActive).length;
  int get archivedCount =>
      _exercises.where((Exercise item) => !item.isActive).length;
  int get systemCount =>
      _exercises.where((Exercise item) => item.isSystem).length;
  int get customCount =>
      _exercises.where((Exercise item) => !item.isSystem).length;

  Exercise? byId(String id) {
    for (final Exercise exercise in _exercises) {
      if (exercise.id == id) {
        return exercise;
      }
    }
    return null;
  }

  Future<void> load() async {
    _setLoading(true);
    try {
      _error = null;
      final List<Exercise> loaded = await _repository.getAll(
        includeArchived: true,
      );
      _exercises
        ..clear()
        ..addAll(loaded);
    } catch (error) {
      _error = error;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> create(ExerciseInput input) async {
    final ExerciseInput normalized = _normalizeAndValidate(input);
    final String nameKey = _nameKey(normalized.nameFa);
    await _ensureUniqueName(nameKey);

    final DateTime now = DateTime.now().toUtc();
    final Exercise exercise = Exercise(
      id: IdGenerator.create('ex'),
      nameFa: normalized.nameFa,
      nameKey: nameKey,
      nameEn: normalized.nameEn,
      primaryMuscle: normalized.primaryMuscle,
      secondaryMuscles: normalized.secondaryMuscles,
      type: normalized.type,
      equipment: normalized.equipment,
      difficulty: normalized.difficulty,
      movementPattern: normalized.movementPattern,
      laterality: normalized.laterality,
      instructions: normalized.instructions,
      safetyNotes: normalized.safetyNotes,
      coachNotes: normalized.coachNotes,
      isActive: true,
      isSystem: false,
      archivedAt: null,
      createdAt: now,
      updatedAt: now,
    );

    await _mutate(() => _repository.save(exercise));
  }

  Future<void> updateCustom(Exercise exercise, ExerciseInput input) async {
    if (exercise.isSystem) {
      throw StateError('حرکت سیستمی قابل ویرایش نیست.');
    }
    final ExerciseInput normalized = _normalizeAndValidate(input);
    final String nameKey = _nameKey(normalized.nameFa);
    await _ensureUniqueName(nameKey, exceptId: exercise.id);
    final Exercise updated = exercise.applyInput(
      normalized,
      nameKey,
      DateTime.now().toUtc(),
    );
    await _mutate(() => _repository.save(updated));
  }

  Future<void> archive(Exercise exercise) async {
    if (!exercise.isActive) {
      return;
    }
    await _mutate(
      () => _repository.archive(exercise.id, DateTime.now().toUtc()),
    );
  }

  Future<void> restore(Exercise exercise) async {
    if (exercise.isActive) {
      return;
    }
    await _mutate(
      () => _repository.restore(exercise.id, DateTime.now().toUtc()),
    );
  }

  Future<void> _ensureUniqueName(String nameKey, {String? exceptId}) async {
    final Exercise? existing = await _repository.getByNameKey(nameKey);
    if (existing != null && existing.id != exceptId) {
      throw const FormatException('حرکتی با این نام از قبل وجود دارد.');
    }
  }

  ExerciseInput _normalizeAndValidate(ExerciseInput input) {
    final String nameFa = InputNormalizer.singleLine(input.nameFa);
    final String nameEn = InputNormalizer.singleLine(input.nameEn);
    final String instructions = InputNormalizer.multiLine(input.instructions);
    final String safetyNotes = InputNormalizer.multiLine(input.safetyNotes);
    final String coachNotes = InputNormalizer.multiLine(input.coachNotes);
    final Set<MuscleGroup> secondary = Set<MuscleGroup>.from(
      input.secondaryMuscles,
    )..remove(input.primaryMuscle);

    if (nameFa.length < 2 || nameFa.length > 100) {
      throw const FormatException(
        'نام فارسی حرکت باید بین ۲ تا ۱۰۰ نویسه باشد.',
      );
    }
    if (nameEn.length > 120) {
      throw const FormatException('نام انگلیسی حرکت بیش از حد طولانی است.');
    }
    if (instructions.length > 2000 ||
        safetyNotes.length > 1500 ||
        coachNotes.length > 1500) {
      throw const FormatException('توضیحات حرکت بیش از حد طولانی است.');
    }

    return ExerciseInput(
      nameFa: nameFa,
      nameEn: nameEn,
      primaryMuscle: input.primaryMuscle,
      secondaryMuscles: secondary,
      type: input.type,
      equipment: input.equipment,
      difficulty: input.difficulty,
      movementPattern: input.movementPattern,
      laterality: input.laterality,
      instructions: instructions,
      safetyNotes: safetyNotes,
      coachNotes: coachNotes,
    );
  }

  static String _nameKey(String value) {
    return InputNormalizer.singleLine(
      value,
    ).replaceAll('ي', 'ی').replaceAll('ك', 'ک').toLowerCase();
  }

  Future<void> _mutate(Future<void> Function() operation) async {
    if (_isMutating) {
      throw StateError('Another exercise operation is already running.');
    }
    _isMutating = true;
    _error = null;
    notifyListeners();
    try {
      await operation();
      await load();
    } catch (error) {
      _error = error;
      rethrow;
    } finally {
      _isMutating = false;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
