import 'package:coach_app/core/cloud/supabase_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('default Supabase client configuration is valid', () {
    expect(SupabaseConfig.isConfigured, isTrue);
    expect(SupabaseConfig.url, 'https://legdlkbzcvkeudfuzzpy.supabase.co');
    expect(SupabaseConfig.publishableKey, startsWith('sb_publishable_'));
  });
}
