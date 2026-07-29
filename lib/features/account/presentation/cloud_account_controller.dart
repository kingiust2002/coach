import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/cloud/cloud_connection.dart';

class CloudAccountController extends ChangeNotifier {
  CloudAccountController({SupabaseClient? client})
    : _client = client ?? CloudConnection.client {
    final SupabaseClient? availableClient = _client;
    if (availableClient != null) {
      _authSubscription = availableClient.auth.onAuthStateChange.listen((
        AuthState state,
      ) {
        _session = state.session;
        unawaited(refreshProfile());
      });
      _session = availableClient.auth.currentSession;
      unawaited(refreshProfile());
    }
  }

  final SupabaseClient? _client;
  StreamSubscription<AuthState>? _authSubscription;
  Session? _session;
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _coachProfile;
  bool _isBusy = false;
  Object? _error;

  bool get isAvailable => _client != null;
  bool get isBusy => _isBusy;
  bool get isSignedIn => _session?.user != null;
  Object? get error => _error ?? CloudConnection.initializationError;
  String get email => _session?.user.email ?? '';
  String get fullName => _profile?['full_name']?.toString() ?? '';
  String get role => _profile?['role']?.toString() ?? '';
  String get username => _coachProfile?['username']?.toString() ?? '';
  String get displayName =>
      _coachProfile?['display_name']?.toString() ?? fullName;
  bool get acceptingClients =>
      _coachProfile?['accepting_clients'] as bool? ?? false;

  Future<void> signIn({required String email, required String password}) async {
    final SupabaseClient? client = _client;
    if (client == null) {
      _error = StateError('اتصال ابری در دسترس نیست.');
      notifyListeners();
      return;
    }

    final String normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || password.isEmpty) {
      _error = ArgumentError('ایمیل و رمز عبور را کامل وارد کنید.');
      notifyListeners();
      return;
    }

    await _run(() async {
      final AuthResponse response = await client.auth.signInWithPassword(
        email: normalizedEmail,
        password: password,
      );
      _session = response.session;
      await _loadProfile(client);
    });
  }

  Future<void> signOut() async {
    final SupabaseClient? client = _client;
    if (client == null) {
      return;
    }

    await _run(() async {
      await client.auth.signOut();
      _session = null;
      _profile = null;
      _coachProfile = null;
    });
  }

  Future<void> refreshProfile() async {
    final SupabaseClient? client = _client;
    if (client == null) {
      notifyListeners();
      return;
    }

    final User? user = client.auth.currentUser;
    _session = client.auth.currentSession;
    if (user == null) {
      _profile = null;
      _coachProfile = null;
      notifyListeners();
      return;
    }

    await _run(() => _loadProfile(client));
  }

  Future<void> _loadProfile(SupabaseClient client) async {
    final String? userId = client.auth.currentUser?.id;
    if (userId == null) {
      _profile = null;
      _coachProfile = null;
      return;
    }

    final Map<String, dynamic>? profile = await client
        .from('profiles')
        .select('id, role, full_name, phone')
        .eq('id', userId)
        .maybeSingle();
    _profile = profile;

    if (profile?['role'] == 'coach') {
      _coachProfile = await client
          .from('coach_profiles')
          .select('username, display_name, bio, accepting_clients')
          .eq('coach_id', userId)
          .maybeSingle();
    } else {
      _coachProfile = null;
    }
  }

  Future<void> _run(Future<void> Function() operation) async {
    if (_isBusy) {
      return;
    }
    _isBusy = true;
    _error = null;
    notifyListeners();
    try {
      await operation();
    } catch (error) {
      _error = error;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    unawaited(_authSubscription?.cancel());
    super.dispose();
  }
}
