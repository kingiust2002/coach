import 'dart:io';

import 'package:video_player/video_player.dart';

VideoPlayerController createExerciseVideoController({
  required String remoteUrl,
  String? localPath,
}) {
  if (localPath != null && localPath.isNotEmpty) {
    return VideoPlayerController.file(File(localPath));
  }
  return VideoPlayerController.networkUrl(Uri.parse(remoteUrl));
}
