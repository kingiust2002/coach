import 'package:flutter/material.dart';

import '../domain/exercise.dart';
import '../domain/exercise_media.dart';
import 'exercise_media_controller.dart';
import 'exercise_video_page.dart';

class ExerciseMediaCard extends StatelessWidget {
  const ExerciseMediaCard({
    required this.exercise,
    required this.controller,
    super.key,
  });

  final Exercise exercise;
  final ExerciseMediaController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        final ExerciseMedia? media = controller.mediaFor(exercise.id);
        final ExerciseMediaDownload? download = controller.downloadFor(
          exercise.id,
        );
        final bool downloading = controller.isDownloading(exercise.id);
        final double? progress = controller.progressFor(exercise.id);

        return Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (media?.hasPoster == true)
                _RemoteImage(
                  url: media!.posterUrl,
                  semanticLabel: 'تصویر شروع حرکت ${exercise.nameFa}',
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Icon(Icons.ondemand_video_outlined),
                        const SizedBox(width: 8),
                        Text(
                          'ویدئوی کامل حرکت',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        if (download != null)
                          const Chip(
                            avatar: Icon(Icons.offline_pin_outlined, size: 18),
                            label: Text('آفلاین'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (media == null || !media.hasVideo)
                      const Text(
                        'ویدئوی این حرکت هنوز در کتابخانه آنلاین منتشر نشده است.',
                      )
                    else ...<Widget>[
                      Text(
                        _mediaSummary(media, download),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (downloading) ...<Widget>[
                        const SizedBox(height: 12),
                        LinearProgressIndicator(value: progress),
                        const SizedBox(height: 6),
                        Text(
                          progress == null
                              ? 'در حال دریافت ویدئو…'
                              : '${(progress * 100).round()}٪ دریافت شده',
                        ),
                      ],
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: <Widget>[
                          FilledButton.icon(
                            onPressed: downloading
                                ? null
                                : () => _openVideo(context, media, download),
                            icon: Icon(
                              download == null
                                  ? Icons.play_circle_outline_rounded
                                  : Icons.play_circle_filled_rounded,
                            ),
                            label: Text(
                              download == null ? 'پخش آنلاین' : 'پخش آفلاین',
                            ),
                          ),
                          if (download == null)
                            OutlinedButton.icon(
                              onPressed: downloading || !controller.canDownload
                                  ? null
                                  : () => _download(context, media),
                              icon: const Icon(Icons.download_rounded),
                              label: const Text('دانلود برای آفلاین'),
                            )
                          else
                            OutlinedButton.icon(
                              onPressed: downloading
                                  ? null
                                  : () => _deleteDownload(context),
                              icon: const Icon(Icons.delete_outline_rounded),
                              label: const Text('حذف دانلود'),
                            ),
                        ],
                      ),
                      if (!controller.canDownload) ...<Widget>[
                        const SizedBox(height: 10),
                        const Text(
                          'دانلود آفلاین در پیش‌نمایش وب فعال نیست؛ در APK اندروید در دسترس است.',
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              if (media?.hasSecondaryImage == true)
                _RemoteImage(
                  url: media!.secondaryImageUrl,
                  semanticLabel: 'تصویر پایان حرکت ${exercise.nameFa}',
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openVideo(
    BuildContext context,
    ExerciseMedia media,
    ExerciseMediaDownload? download,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => ExerciseVideoPage(
          exercise: exercise,
          media: media,
          download: download,
        ),
      ),
    );
  }

  Future<void> _download(BuildContext context, ExerciseMedia media) async {
    try {
      await controller.download(media);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ویدئو برای استفاده آفلاین ذخیره شد.')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_friendlyError(error))));
      }
    }
  }

  Future<void> _deleteDownload(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('حذف ویدئوی دانلودشده'),
        content: const Text(
          'ویدئو از حافظه گوشی حذف می‌شود و همچنان می‌توان آن را آنلاین پخش یا دوباره دانلود کرد.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('انصراف'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await controller.deleteDownload(exercise.id);
  }

  String _mediaSummary(ExerciseMedia media, ExerciseMediaDownload? download) {
    final List<String> parts = <String>[];
    final int? duration = media.durationSeconds;
    if (duration != null && duration > 0) {
      final int minutes = duration ~/ 60;
      final int seconds = duration.remainder(60);
      parts.add('$minutes:${seconds.toString().padLeft(2, '0')} دقیقه');
    }
    final int? bytes = download?.fileSizeBytes ?? media.videoSizeBytes;
    if (bytes != null && bytes > 0) {
      parts.add(_formatBytes(bytes));
    }
    parts.add('نسخه ${media.version}');
    return parts.join(' · ');
  }

  String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} مگابایت';
    }
    return '${(bytes / 1024).ceil()} کیلوبایت';
  }

  String _friendlyError(Object error) {
    final String message = error.toString();
    return message.startsWith('Exception: ')
        ? message.substring('Exception: '.length)
        : message;
  }
}

class _RemoteImage extends StatelessWidget {
  const _RemoteImage({required this.url, required this.semanticLabel});

  final String url;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        semanticLabel: semanticLabel,
        errorBuilder: (_, __, ___) => const ColoredBox(
          color: Colors.black12,
          child: Center(child: Icon(Icons.broken_image_outlined, size: 42)),
        ),
        loadingBuilder:
            (BuildContext context, Widget child, ImageChunkEvent? progress) {
              if (progress == null) {
                return child;
              }
              final int? total = progress.expectedTotalBytes;
              return Center(
                child: CircularProgressIndicator(
                  value: total == null
                      ? null
                      : progress.cumulativeBytesLoaded / total,
                ),
              );
            },
      ),
    );
  }
}
