import '../features/athletes/data/athlete_repository.dart';
import '../features/exercises/data/exercise_media_catalog.dart';
import '../features/exercises/data/exercise_repository.dart';
import '../features/exercises/data/exercise_video_store_base.dart';

class AppDependencies {
  const AppDependencies({
    required this.athleteRepository,
    required this.exerciseRepository,
    required this.exerciseMediaCatalog,
    required this.exerciseVideoStore,
  });

  final AthleteRepository athleteRepository;
  final ExerciseRepository exerciseRepository;
  final ExerciseMediaCatalog exerciseMediaCatalog;
  final ExerciseVideoStore exerciseVideoStore;
}
