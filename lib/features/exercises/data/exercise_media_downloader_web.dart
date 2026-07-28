import '../domain/exercise_media.dart';
import 'exercise_media_downloader.dart';

ExerciseMediaDownloader createExerciseMediaDownloader() =>
    const WebExerciseMediaDownloader();

class WebExerciseMediaDownloader implements ExerciseMediaDownloader {
  const WebExerciseMediaDownloader();

  @override
  bool get isSupported => false;

  @override
  Future<DownloadedExerciseMedia> download(
    ExerciseMedia media, {
    required ExerciseDownloadProgress onProgress,
  }) {
    throw UnsupportedError(
      'دانلود آفلاین ویدئو در پیش‌نمایش وب فعال نیست. APK اندروید را اجرا کنید.',
    );
  }

  @override
  Future<bool> exists(String localPath) async => false;

  @override
  Future<void> delete(String localPath) async {}
}
