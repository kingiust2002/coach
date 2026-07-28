import 'package:video_player/video_player.dart';

Future<VideoPlayerController> createExerciseVideoController({
  required Uri remoteUrl,
  String? localPath,
}) async {
  final VideoPlayerController controller = VideoPlayerController.networkUrl(
    remoteUrl,
  );
  await controller.initialize();
  return controller;
}
