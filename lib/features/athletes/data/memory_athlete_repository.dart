import '../domain/athlete.dart';
import 'athlete_repository.dart';

/// Volatile repository used by browser previews where SQLite is unavailable.
/// Data is intentionally reset when the page reloads.
class MemoryAthleteRepository implements AthleteRepository {
  final Map<String, Athlete> _items = <String, Athlete>{};

  @override
  Future<List<Athlete>> getAll({bool includeArchived = false}) async {
    final List<Athlete> result = _items.values
        .where((Athlete item) => includeArchived || item.isActive)
        .toList();
    result.sort((Athlete a, Athlete b) {
      final int activeOrder = (b.isActive ? 1 : 0).compareTo(
        a.isActive ? 1 : 0,
      );
      if (activeOrder != 0) {
        return activeOrder;
      }
      final int updatedOrder = b.updatedAt.compareTo(a.updatedAt);
      if (updatedOrder != 0) {
        return updatedOrder;
      }
      return a.fullName.compareTo(b.fullName);
    });
    return List<Athlete>.unmodifiable(result);
  }

  @override
  Future<Athlete?> getById(String id) async => _items[id];

  @override
  Future<void> save(Athlete athlete) async {
    _items[athlete.id] = athlete;
  }

  @override
  Future<void> archive(String id, DateTime updatedAt) async {
    final Athlete athlete = _require(id);
    _items[id] = athlete.copyWith(
      isActive: false,
      archivedAt: updatedAt.toUtc(),
      updatedAt: updatedAt.toUtc(),
    );
  }

  @override
  Future<void> restore(String id, DateTime updatedAt) async {
    final Athlete athlete = _require(id);
    _items[id] = athlete.copyWith(
      isActive: true,
      archivedAt: null,
      updatedAt: updatedAt.toUtc(),
    );
  }

  Athlete _require(String id) {
    final Athlete? athlete = _items[id];
    if (athlete == null) {
      throw StateError('Athlete $id was not found.');
    }
    return athlete;
  }
}
