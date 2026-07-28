import 'package:video_player/video_player.dart';

VideoPlayerController createExerciseVideoController({
  required String remoteUrl,
  String? localPath,
}) => VideoPlayerController.networkUrl(Uri.parse(remoteUrl));
