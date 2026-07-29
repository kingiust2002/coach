import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

class CloudConnection {
  CloudConnection._();

  static SupabaseClient? _client;
  static Object? _initializationError;
  static bool _initializationAttempted = false;

  static SupabaseClient? get client => _client;
  static Object? get initializationError => _initializationError;
  static bool get isAvailable => _client != null;
  static bool get isConfigured => SupabaseConfig.isConfigured;

  static Future<void> initialize() async {
    if (_initializationAttempted) {
      return;
    }
    _initializationAttempted = true;

    if (!SupabaseConfig.isConfigured) {
      _initializationError = StateError('تنظیمات اتصال ابری معتبر نیست.');
      return;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        publishableKey: SupabaseConfig.publishableKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
      _client = Supabase.instance.client;
      _initializationError = null;
    } catch (error) {
      _initializationError = error;
      _client = null;
    }
  }
}
