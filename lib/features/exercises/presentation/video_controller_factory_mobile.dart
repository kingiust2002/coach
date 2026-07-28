import 'dart:io';

import 'package:video_player/video_player.dart';

Future<VideoPlayerController> createExerciseVideoController({
  required Uri remoteUrl,
  String? localPath,
}) async {
  final VideoPlayerController controller =
      localPath != null && localPath.isNotEmpty
      ? VideoPlayerController.file(File(localPath))
      : VideoPlayerController.networkUrl(remoteUrl);
  await controller.initialize();
  return controller;
}
