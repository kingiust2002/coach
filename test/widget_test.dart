import 'package:coach_app/app/coach_app.dart';
import 'package:coach_app/features/athletes/data/athlete_repository.dart';
import 'package:coach_app/features/athletes/domain/athlete.dart';
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
  Future<void> save(Athlete athlete) async {}
}

void main() {
  testWidgets('Coach app renders the Persian dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      CoachApp(athleteRepository: _FakeAthleteRepository()),
    );
    await tester.pumpAndSettle();

    expect(find.text('مربی‌یار'), findsOneWidget);
    expect(find.text('شاگردان'), findsOneWidget);
    expect(find.text('برنامه‌ها'), findsOneWidget);
  });
}
