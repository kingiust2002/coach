import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../domain/exercise_media.dart';
import 'video_controller_factory.dart';

class ExerciseVideoPage extends StatefulWidget {
  const ExerciseVideoPage({
    required this.title,
    required this.media,
    this.download,
    super.key,
  });

  final String title;
  final ExerciseMedia media;
  final ExerciseVideoDownload? download;

  @override
  State<ExerciseVideoPage> createState() => _ExerciseVideoPageState();
}

class _ExerciseVideoPageState extends State<ExerciseVideoPage> {
  late final Future<VideoPlayerController> _initialization =
      createExerciseVideoController(
        remoteUrl: Uri.parse(widget.media.fullVideoUrl),
        localPath: widget.download?.localPath,
      );
  VideoPlayerController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<VideoPlayerController>(
        future: _initialization,
        builder: (
          BuildContext context,
          AsyncSnapshot<VideoPlayerController> snapshot,
        ) {
          if (snapshot.hasError) {
            return _VideoError(error: snapshot.error);
          }
          final VideoPlayerController? controller = snapshot.data;
          if (controller == null) {
            return const Center(child: CircularProgressIndicator());
          }
          _controller ??= controller;
          return AnimatedBuilder(
            animation: controller,
            builder: (BuildContext context, Widget? child) {
              final double aspectRatio = controller.value.aspectRatio > 0
                  ? controller.value.aspectRatio
                  : 16 / 9;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: ColoredBox(
                      color: Colors.black,
                      child: AspectRatio(
                        aspectRatio: aspectRatio,
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            VideoPlayer(controller),
                            if (!controller.value.isPlaying)
                              IconButton.filledTonal(
                                iconSize: 44,
                                tooltip: 'پخش',
                                onPressed: () => controller.play(),
                                icon: const Icon(Icons.play_arrow_rounded),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  VideoProgressIndicator(
                    controller,
                    allowScrubbing: true,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  Row(
                    children: <Widget>[
                      FilledButton.tonalIcon(
                        onPressed: () => controller.value.isPlaying
                            ? controller.pause()
                            : controller.play(),
                        icon: Icon(
                          controller.value.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        label: Text(
                          controller.value.isPlaying ? 'توقف' : 'پخش',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(_positionLabel(controller.value)),
                      const Spacer(),
                      if (widget.download != null)
                        const Chip(
                          avatar: Icon(Icons.offline_pin_outlined, size: 18),
                          label: Text('نسخه آفلاین'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'این بخش فقط ویدیوی کامل آموزشی را نمایش می‌دهد. کلیپ کوتاه یا ویدیوی میانی در ساختار کتابخانه استفاده نمی‌شود.',
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _positionLabel(VideoPlayerValue value) {
    final Duration position = value.position;
    final Duration duration = value.duration;
    return '${_duration(position)} / ${_duration(duration)}';
  }

  String _duration(Duration value) {
    final String minutes = value.inMinutes.toString().padLeft(2, '0');
    final String seconds = (value.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _VideoError extends StatelessWidget {
  const _VideoError({required this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.video_file_outlined, size: 56),
            const SizedBox(height: 16),
            Text(
              'ویدیو پخش نشد',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'خطای ناشناخته',
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
            ),
          ],
        ),
      ),
    );
  }
}
