import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/media_config.dart';
import '../features/athletes/data/memory_athlete_repository.dart';
import '../features/exercises/data/exercise_video_store.dart';
import '../features/exercises/data/memory_exercise_repository.dart';
import '../features/exercises/data/remote_exercise_media_catalog.dart';
import 'app_dependencies.dart';

Future<AppDependencies> createAppDependencies() async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  return AppDependencies(
    athleteRepository: MemoryAthleteRepository(),
    exerciseRepository: MemoryExerciseRepository(),
    exerciseMediaCatalog: RemoteExerciseMediaCatalog(
      endpoint: MediaConfig.exerciseManifestUri,
      preferences: preferences,
    ),
    exerciseVideoStore: createExerciseVideoStore(),
  );
}
