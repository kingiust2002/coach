import 'package:coach_app/features/exercises/domain/exercise_media.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exercise media round-trips through sqlite map', () {
    final ExerciseMedia media = ExerciseMedia(
      exerciseId: 'sys_back_squat',
      videoUrl: 'https://media.example.com/back-squat.mp4',
      posterUrl: 'https://media.example.com/back-squat-start.webp',
      secondaryImageUrl: 'https://media.example.com/back-squat-end.webp',
      videoSizeBytes: 4 * 1024 * 1024,
      durationSeconds: 72,
      version: 3,
      updatedAt: DateTime.utc(2026, 7, 28, 8, 30),
    );

    final ExerciseMedia decoded = ExerciseMedia.fromMap(media.toMap());

    expect(decoded.exerciseId, media.exerciseId);
    expect(decoded.videoUrl, media.videoUrl);
    expect(decoded.posterUrl, media.posterUrl);
    expect(decoded.secondaryImageUrl, media.secondaryImageUrl);
    expect(decoded.videoSizeBytes, media.videoSizeBytes);
    expect(decoded.durationSeconds, media.durationSeconds);
    expect(decoded.version, media.version);
    expect(decoded.updatedAt, media.updatedAt);
  });

  test('manifest media requires absolute full video URL', () {
    expect(
      () => ExerciseMedia.fromManifest(<String, Object?>{
        'exerciseId': 'sys_deadlift',
        'videoUrl': '/deadlift.mp4',
      }),
      throwsFormatException,
    );
  });

  test('download only matches the current video revision', () {
    final ExerciseMedia media = ExerciseMedia(
      exerciseId: 'sys_push_up',
      videoUrl: 'https://media.example.com/push-up.mp4',
      posterUrl: '',
      secondaryImageUrl: '',
      videoSizeBytes: null,
      durationSeconds: null,
      version: 2,
      updatedAt: DateTime.utc(2026, 7, 28),
    );
    final ExerciseMediaDownload download = ExerciseMediaDownload(
      exerciseId: media.exerciseId,
      remoteUrl: media.videoUrl,
      localPath: '/tmp/push-up-v2.mp4',
      mediaVersion: 2,
      fileSizeBytes: 1024,
      downloadedAt: DateTime.utc(2026, 7, 28),
      updatedAt: DateTime.utc(2026, 7, 28),
    );

    expect(download.matches(media), isTrue);
    expect(
      download.matches(
        ExerciseMedia(
          exerciseId: media.exerciseId,
          videoUrl: media.videoUrl,
          posterUrl: '',
          secondaryImageUrl: '',
          videoSizeBytes: null,
          durationSeconds: null,
          version: 3,
          updatedAt: DateTime.utc(2026, 7, 29),
        ),
      ),
      isFalse,
    );
  });
}
