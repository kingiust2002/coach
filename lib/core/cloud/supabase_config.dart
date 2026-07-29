class SupabaseConfig {
  const SupabaseConfig._();

  static const String _defaultUrl = 'https://legdlkbzcvkeudfuzzpy.supabase.co';
  static const String _defaultPublishableKey =
      'sb_publishable_dZgds8rFlS83OpF3AyvI8w_Zkr4cyjB';

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: _defaultUrl,
  );

  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: _defaultPublishableKey,
  );

  static bool get isConfigured {
    final Uri? uri = Uri.tryParse(url);
    return uri != null &&
        uri.hasScheme &&
        uri.host.endsWith('.supabase.co') &&
        publishableKey.startsWith('sb_publishable_');
  }
}
