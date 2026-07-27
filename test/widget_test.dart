import 'package:coach_app/app/coach_app.dart';
import 'package:coach_app/features/athletes/data/athlete_repository.dart';
import 'package:coach_app/features/athletes/domain/athlete.dart';
import 'package:coach_app/features/exercises/data/exercise_repository.dart';
import 'package:coach_app/features/exercises/domain/exercise.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAthleteRepository implements AthleteRepository {
  @override
  Future<void> archive(String id, DateTime updatedAt) async {}

  @override
  Future<List<Athlete>> getAll({bool includeArchived = false}) async {
    return <Athlete>[];
  }

  @override
  Future<Athlete?> getById(String id) async => null;

  @override
  Future<void> restore(String id, DateTime updatedAt) async {}

  @override
  Future<void> save(Athlete athlete) async {}
}

class _FakeExerciseRepository implements ExerciseRepository {
  @override
  Future<void> archive(String id, DateTime updatedAt) async {}

  @override
  Future<List<Exercise>> getAll({bool includeArchived = false}) async {
    return <Exercise>[];
  }

  @override
  Future<Exercise?> getById(String id) async => null;

  @override
  Future<Exercise?> getByNameKey(String nameKey) async => null;

  @override
  Future<void> restore(String id, DateTime updatedAt) async {}

  @override
  Future<void> save(Exercise exercise) async {}
}

void main() {
  testWidgets('Coach app renders Persian milestone navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      CoachApp(
        athleteRepository: _FakeAthleteRepository(),
        exerciseRepository: _FakeExerciseRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('مربی‌یار'), findsOneWidget);
    expect(find.text('شاگردان'), findsOneWidget);
    expect(find.text('حرکات'), findsOneWidget);
    expect(find.text('برنامه‌ها'), findsOneWidget);
  });
}
