import '../domain/athlete.dart';

abstract interface class AthleteRepository {
  Future<List<Athlete>> getAll({bool includeArchived = false});

  Future<Athlete?> getById(String id);

  Future<void> save(Athlete athlete);

  Future<void> archive(String id, DateTime updatedAt);

  Future<void> restore(String id, DateTime updatedAt);
}
