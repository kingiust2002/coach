import 'package:flutter/foundation.dart';

import '../../../core/utils/id_generator.dart';
import '../../../core/utils/input_normalizer.dart';
import '../data/athlete_repository.dart';
import '../domain/athlete.dart';

class AthletesController extends ChangeNotifier {
  AthletesController(this._repository);

  final AthleteRepository _repository;

  final List<Athlete> _athletes = <Athlete>[];
  bool _isLoading = false;
  bool _isMutating = false;
  Object? _error;

  List<Athlete> get athletes => List<Athlete>.unmodifiable(_athletes);
  bool get isLoading => _isLoading;
  bool get isMutating => _isMutating;
  Object? get error => _error;
  int get activeCount =>
      _athletes.where((Athlete item) => item.isActive).length;
  int get archivedCount =>
      _athletes.where((Athlete item) => !item.isActive).length;

  Athlete? byId(String id) {
    for (final Athlete athlete in _athletes) {
      if (athlete.id == id) {
        return athlete;
      }
    }
    return null;
  }

  Future<void> load() async {
    _setLoading(true);
    try {
      _error = null;
      final List<Athlete> loaded = await _repository.getAll(
        includeArchived: true,
      );
      _athletes
        ..clear()
        ..addAll(loaded);
    } catch (error) {
      _error = error;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> create(AthleteProfileInput input) async {
    final AthleteProfileInput normalized = _normalizeAndValidate(input);
    final DateTime now = DateTime.now().toUtc();
    final Athlete athlete = Athlete(
      id: IdGenerator.create('ath'),
      fullName: normalized.fullName,
      phone: normalized.phone,
      birthDate: normalized.birthDate,
      primaryGoal: normalized.primaryGoal,
      goal: normalized.goal,
      trainingLevel: normalized.trainingLevel,
      experienceMonths: normalized.experienceMonths,
      preferredDaysPerWeek: normalized.preferredDaysPerWeek,
      preferredSessionMinutes: normalized.preferredSessionMinutes,
      trainingEnvironment: normalized.trainingEnvironment,
      injuries: normalized.injuries,
      medicalNotes: normalized.medicalNotes,
      notes: normalized.notes,
      isActive: true,
      archivedAt: null,
      createdAt: now,
      updatedAt: now,
    );

    await _mutate(() => _repository.save(athlete));
  }

  Future<void> updateProfile(Athlete athlete, AthleteProfileInput input) async {
    final AthleteProfileInput normalized = _normalizeAndValidate(input);
    final Athlete updated = athlete.applyProfile(
      normalized,
      DateTime.now().toUtc(),
    );
    await _mutate(() => _repository.save(updated));
  }

  Future<void> archive(Athlete athlete) async {
    if (!athlete.isActive) {
      return;
    }
    await _mutate(
      () => _repository.archive(athlete.id, DateTime.now().toUtc()),
    );
  }

  Future<void> restore(Athlete athlete) async {
    if (athlete.isActive) {
      return;
    }
    await _mutate(
      () => _repository.restore(athlete.id, DateTime.now().toUtc()),
    );
  }

  Future<void> _mutate(Future<void> Function() operation) async {
    if (_isMutating) {
      throw StateError('Another athlete operation is already running.');
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

  AthleteProfileInput _normalizeAndValidate(AthleteProfileInput input) {
    final DateTime? birthDate = input.birthDate == null
        ? null
        : DateTime.utc(
            input.birthDate!.year,
            input.birthDate!.month,
            input.birthDate!.day,
          );
    final AthleteProfileInput normalized = AthleteProfileInput(
      fullName: InputNormalizer.singleLine(input.fullName),
      phone: InputNormalizer.phone(input.phone),
      birthDate: birthDate,
      primaryGoal: input.primaryGoal,
      goal: InputNormalizer.multiLine(input.goal),
      trainingLevel: input.trainingLevel,
      experienceMonths: input.experienceMonths,
      preferredDaysPerWeek: input.preferredDaysPerWeek,
      preferredSessionMinutes: input.preferredSessionMinutes,
      trainingEnvironment: input.trainingEnvironment,
      injuries: InputNormalizer.multiLine(input.injuries),
      medicalNotes: InputNormalizer.multiLine(input.medicalNotes),
      notes: InputNormalizer.multiLine(input.notes),
    );

    if (normalized.fullName.length < 2 || normalized.fullName.length > 80) {
      throw const FormatException('نام شاگرد باید بین ۲ تا ۸۰ نویسه باشد.');
    }
    final String phoneDigits = normalized.phone.replaceFirst('+', '');
    if (phoneDigits.isNotEmpty &&
        (phoneDigits.length < 7 || phoneDigits.length > 15)) {
      throw const FormatException('شماره تماس معتبر نیست.');
    }
    final DateTime? date = normalized.birthDate;
    if (date != null && date.isAfter(DateTime.now().toUtc())) {
      throw const FormatException('تاریخ تولد نمی‌تواند در آینده باشد.');
    }
    if (normalized.experienceMonths < 0 || normalized.experienceMonths > 720) {
      throw const FormatException('سابقه تمرین باید بین صفر تا ۷۲۰ ماه باشد.');
    }
    if (normalized.preferredDaysPerWeek < 1 ||
        normalized.preferredDaysPerWeek > 7) {
      throw const FormatException('تعداد روز تمرین باید بین ۱ تا ۷ باشد.');
    }
    if (normalized.preferredSessionMinutes < 15 ||
        normalized.preferredSessionMinutes > 300) {
      throw const FormatException('مدت جلسه باید بین ۱۵ تا ۳۰۰ دقیقه باشد.');
    }
    return normalized;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
