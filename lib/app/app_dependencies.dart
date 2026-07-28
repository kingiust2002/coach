import '../features/athletes/data/athlete_repository.dart';
import '../features/exercises/data/exercise_media_downloader.dart';
import '../features/exercises/data/exercise_media_repository.dart';
import '../features/exercises/data/exercise_repository.dart';

class AppDependencies {
  const AppDependencies({
    required this.athleteRepository,
    required this.exerciseRepository,
    required this.exerciseMediaRepository,
    required this.exerciseMediaDownloader,
  });

  final AthleteRepository athleteRepository;
  final ExerciseRepository exerciseRepository;
  final ExerciseMediaRepository exerciseMediaRepository;
  final ExerciseMediaDownloader exerciseMediaDownloader;
}
