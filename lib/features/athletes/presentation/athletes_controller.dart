import 'package:flutter/foundation.dart';

import '../../../core/utils/id_generator.dart';
import '../data/athlete_repository.dart';
import '../domain/athlete.dart';

class AthletesController extends ChangeNotifier {
  AthletesController(this._repository);

  final AthleteRepository _repository;

  final List<Athlete> _athletes = <Athlete>[];
  bool _isLoading = false;
  Object? _error;

  List<Athlete> get athletes => List<Athlete>.unmodifiable(_athletes);
  bool get isLoading => _isLoading;
  Object? get error => _error;
  int get activeCount => _athletes.where((Athlete item) => item.isActive).length;

  Future<void> load() async {
    _setLoading(true);
    try {
      _error = null;
      final List<Athlete> loaded = await _repository.getAll();
      _athletes
        ..clear()
        ..addAll(loaded);
    } catch (error) {
      _error = error;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> create({
    required String fullName,
    required String phone,
    required String goal,
    required TrainingLevel trainingLevel,
    required String injuries,
    required String notes,
  }) async {
    final DateTime now = DateTime.now().toUtc();
    final Athlete athlete = Athlete(
      id: IdGenerator.create('ath'),
      fullName: fullName.trim(),
      phone: phone.trim(),
      goal: goal.trim(),
      trainingLevel: trainingLevel,
      injuries: injuries.trim(),
      notes: notes.trim(),
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    await _repository.save(athlete);
    await load();
  }

  Future<void> update(Athlete athlete) async {
    await _repository.save(
      athlete.copyWith(updatedAt: DateTime.now().toUtc()),
    );
    await load();
  }

  Future<void> archive(Athlete athlete) async {
    await _repository.archive(athlete.id, DateTime.now().toUtc());
    await load();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
