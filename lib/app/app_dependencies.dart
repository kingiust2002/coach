import '../features/athletes/data/athlete_repository.dart';
import '../features/exercises/data/exercise_repository.dart';

class AppDependencies {
  const AppDependencies({
    required this.athleteRepository,
    required this.exerciseRepository,
  });

  final AthleteRepository athleteRepository;
  final ExerciseRepository exerciseRepository;
}
