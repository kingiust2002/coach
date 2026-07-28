import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../domain/exercise.dart';
import '../domain/exercise_media.dart';
import 'exercise_video_controller_factory_mobile.dart'
    if (dart.library.html) 'exercise_video_controller_factory_web.dart'
    as platform;

class ExerciseVideoPage extends StatefulWidget {
  const ExerciseVideoPage({
    required this.exercise,
    required this.media,
    this.download,
    super.key,
  });

  final Exercise exercise;
  final ExerciseMedia media;
  final ExerciseMediaDownload? download;

  @override
  State<ExerciseVideoPage> createState() => _ExerciseVideoPageState();
}

class _ExerciseVideoPageState extends State<ExerciseVideoPage> {
  late final VideoPlayerController _controller;
  late final Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _controller = platform.createExerciseVideoController(
      remoteUrl: widget.media.videoUrl,
      localPath: widget.download?.localPath,
    );
    _initialization = _controller.initialize().then((_) {
      _controller.setLooping(false);
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.nameFa),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 16),
            child: Center(
              child: Text(
                widget.download == null ? 'پخش آنلاین' : 'پخش آفلاین',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _initialization,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.hasError) {
            return _VideoError(error: snapshot.error);
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio > 0
                          ? _controller.value.aspectRatio
                          : 16 / 9,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          ColoredBox(
                            color: Colors.black,
                            child: VideoPlayer(_controller),
                          ),
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (BuildContext context, Widget? child) {
                              return IconButton.filled(
                                iconSize: 42,
                                tooltip: _controller.value.isPlaying
                                    ? 'توقف'
                                    : 'پخش',
                                onPressed: () {
                                  _controller.value.isPlaying
                                      ? _controller.pause()
                                      : _controller.play();
                                  setState(() {});
                                },
                                icon: Icon(
                                  _controller.value.isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  child: Column(
                    children: <Widget>[
                      VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      Row(
                        children: <Widget>[
                          IconButton(
                            tooltip: '۱۰ ثانیه عقب',
                            onPressed: () =>
                                _seekBy(const Duration(seconds: -10)),
                            icon: const Icon(Icons.replay_10_rounded),
                          ),
                          IconButton.filled(
                            tooltip: _controller.value.isPlaying
                                ? 'توقف'
                                : 'پخش',
                            onPressed: () {
                              _controller.value.isPlaying
                                  ? _controller.pause()
                                  : _controller.play();
                              setState(() {});
                            },
                            icon: Icon(
                              _controller.value.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                            ),
                          ),
                          IconButton(
                            tooltip: '۱۰ ثانیه جلو',
                            onPressed: () =>
                                _seekBy(const Duration(seconds: 10)),
                            icon: const Icon(Icons.forward_10_rounded),
                          ),
                          const Spacer(),
                          Text(_durationLabel()),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _seekBy(Duration delta) async {
    final Duration duration = _controller.value.duration;
    final Duration position = _controller.value.position;
    Duration next = position + delta;
    if (next < Duration.zero) {
      next = Duration.zero;
    } else if (next > duration) {
      next = duration;
    }
    await _controller.seekTo(next);
    if (mounted) {
      setState(() {});
    }
  }

  String _durationLabel() {
    final Duration position = _controller.value.position;
    final Duration duration = _controller.value.duration;
    return '${_format(position)} / ${_format(duration)}';
  }

  String _format(Duration value) {
    final int minutes = value.inMinutes;
    final int seconds = value.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
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
            const Icon(Icons.video_file_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              'پخش ویدئو انجام نشد',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            SelectableText(
              error?.toString() ?? 'خطای ناشناخته',
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
