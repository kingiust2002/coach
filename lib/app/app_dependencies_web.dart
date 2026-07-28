import '../features/athletes/data/memory_athlete_repository.dart';
import '../features/exercises/data/exercise_media_downloader_web.dart';
import '../features/exercises/data/memory_exercise_media_repository.dart';
import '../features/exercises/data/memory_exercise_repository.dart';
import 'app_dependencies.dart';

Future<AppDependencies> createAppDependencies() async {
  return AppDependencies(
    athleteRepository: MemoryAthleteRepository(),
    exerciseRepository: MemoryExerciseRepository(),
    exerciseMediaRepository: MemoryExerciseMediaRepository(),
    exerciseMediaDownloader: createExerciseMediaDownloader(),
  );
}
