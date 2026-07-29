import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/cloud/cloud_connection.dart';

class CloudAuthSnapshot {
  const CloudAuthSnapshot({this.userId, this.email = ''});

  const CloudAuthSnapshot.signedOut() : userId = null, email = '';

  final String? userId;
  final String email;

  bool get isSignedIn => userId != null;
}

class CloudAccountProfile {
  const CloudAccountProfile({
    required this.userId,
    required this.role,
    required this.fullName,
    required this.phone,
    this.username = '',
    this.displayName = '',
    this.bio = '',
    this.acceptingClients = false,
  });

  final String userId;
  final String role;
  final String fullName;
  final String phone;
  final String username;
  final String displayName;
  final String bio;
  final bool acceptingClients;
}

class CloudAccountException implements Exception {
  const CloudAccountException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => message;
}

abstract interface class CloudAccountService {
  bool get isAvailable;
  Object? get initializationError;
  CloudAuthSnapshot get currentAuth;
  Stream<CloudAuthSnapshot> get authChanges;

  Future<CloudAuthSnapshot> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<CloudAccountProfile?> fetchProfile(String userId);
}

class SupabaseCloudAccountService implements CloudAccountService {
  SupabaseCloudAccountService({SupabaseClient? client})
    : _client = client ?? CloudConnection.client;

  final SupabaseClient? _client;

  @override
  bool get isAvailable => _client != null;

  @override
  Object? get initializationError => CloudConnection.initializationError;

  @override
  CloudAuthSnapshot get currentAuth {
    final User? user = _client?.auth.currentUser;
    if (user == null) {
      return const CloudAuthSnapshot.signedOut();
    }
    return CloudAuthSnapshot(userId: user.id, email: user.email ?? '');
  }

  @override
  Stream<CloudAuthSnapshot> get authChanges {
    final SupabaseClient? client = _client;
    if (client == null) {
      return const Stream<CloudAuthSnapshot>.empty();
    }
    return client.auth.onAuthStateChange.map((AuthState state) {
      final User? user = state.session?.user;
      if (user == null) {
        return const CloudAuthSnapshot.signedOut();
      }
      return CloudAuthSnapshot(userId: user.id, email: user.email ?? '');
    });
  }

  @override
  Future<CloudAuthSnapshot> signIn({
    required String email,
    required String password,
  }) async {
    final SupabaseClient client = _requireClient();
    final AuthResponse response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final User? user = response.user;
    if (user == null || response.session == null) {
      throw const CloudAccountException(
        'missing_session',
        'جلسه ورود معتبر ایجاد نشد.',
      );
    }
    return CloudAuthSnapshot(userId: user.id, email: user.email ?? email);
  }

  @override
  Future<void> signOut() async {
    await _requireClient().auth.signOut(scope: SignOutScope.local);
  }

  @override
  Future<CloudAccountProfile?> fetchProfile(String userId) async {
    final SupabaseClient client = _requireClient();
    final Map<String, dynamic>? profile = await client
        .from('profiles')
        .select('id, role, full_name, phone')
        .eq('id', userId)
        .maybeSingle();
    if (profile == null) {
      return null;
    }

    Map<String, dynamic>? coachProfile;
    if (profile['role'] == 'coach') {
      coachProfile = await client
          .from('coach_profiles')
          .select('username, display_name, bio, accepting_clients')
          .eq('coach_id', userId)
          .maybeSingle();
    }

    return CloudAccountProfile(
      userId: userId,
      role: profile['role']?.toString() ?? '',
      fullName: profile['full_name']?.toString() ?? '',
      phone: profile['phone']?.toString() ?? '',
      username: coachProfile?['username']?.toString() ?? '',
      displayName: coachProfile?['display_name']?.toString() ?? '',
      bio: coachProfile?['bio']?.toString() ?? '',
      acceptingClients:
          coachProfile?['accepting_clients'] as bool? ?? false,
    );
  }

  SupabaseClient _requireClient() {
    final SupabaseClient? client = _client;
    if (client == null) {
      throw const CloudAccountException(
        'cloud_unavailable',
        'اتصال ابری در دسترس نیست.',
      );
    }
    return client;
  }
}
