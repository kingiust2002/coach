abstract final class MediaConfig {
  static const String exerciseManifestUrl = String.fromEnvironment(
    'EXERCISE_MEDIA_MANIFEST_URL',
    defaultValue: '',
  );

  static Uri? get exerciseManifestUri {
    final String value = exerciseManifestUrl.trim();
    if (value.isEmpty) {
      return null;
    }
    final Uri? uri = Uri.tryParse(value);
    return uri != null && uri.hasScheme && uri.host.isNotEmpty ? uri : null;
  }
}
