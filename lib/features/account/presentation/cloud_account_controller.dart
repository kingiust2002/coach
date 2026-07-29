import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/cloud_account_service.dart';

enum CloudAccountPhase {
  unavailable,
  signedOut,
  restoring,
  signingIn,
  signedIn,
  signingOut,
}

class CloudAccountController extends ChangeNotifier {
  CloudAccountController({CloudAccountService? service})
    : _service = service ?? SupabaseCloudAccountService() {
    if (!_service.isAvailable) {
      _phase = CloudAccountPhase.unavailable;
      _error = _service.initializationError;
      return;
    }

    _authSubscription = _service.authChanges.listen(
      _handleAuthSnapshot,
      onError: _handleAuthStreamError,
    );

    final CloudAuthSnapshot initialAuth = _service.currentAuth;
    _auth = initialAuth;
    if (initialAuth.isSignedIn) {
      _phase = CloudAccountPhase.restoring;
      unawaited(_restoreProfile(initialAuth));
    }
  }

  final CloudAccountService _service;
  StreamSubscription<CloudAuthSnapshot>? _authSubscription;
  CloudAuthSnapshot _auth = const CloudAuthSnapshot.signedOut();
  CloudAccountProfile? _profile;
  CloudAccountPhase _phase = CloudAccountPhase.signedOut;
  Object? _error;
  bool _ignoreAuthEvents = false;
  bool _disposed = false;
  int _profileRequest = 0;

  CloudAccountPhase get phase => _phase;
  bool get isAvailable => _service.isAvailable;
  bool get isBusy => switch (_phase) {
    CloudAccountPhase.restoring ||
    CloudAccountPhase.signingIn ||
    CloudAccountPhase.signingOut => true,
    _ => false,
  };
  bool get hasSession => _auth.isSignedIn;
  bool get isSignedIn =>
      _phase == CloudAccountPhase.signedIn && _profile != null;
  bool get isAuthorizedCoach =>
      _profile?.role == 'coach' || _profile?.role == 'admin';
  Object? get error => _error ?? _service.initializationError;
  String get email => _auth.email;
  String get fullName => _profile?.fullName ?? '';
  String get phone => _profile?.phone ?? '';
  String get role => _profile?.role ?? '';
  String get username => _profile?.username ?? '';
  String get displayName {
    final String coachDisplayName = _profile?.displayName ?? '';
    if (coachDisplayName.isNotEmpty) {
      return coachDisplayName;
    }
    return fullName;
  }

  String get bio => _profile?.bio ?? '';
  bool get acceptingClients => _profile?.acceptingClients ?? false;

  Future<void> signIn({required String email, required String password}) async {
    if (!isAvailable || isBusy) {
      return;
    }

    final String normalizedEmail = email.trim().toLowerCase();
    if (!_looksLikeEmail(normalizedEmail)) {
      _setError(
        const CloudAccountException(
          'invalid_email',
          'نشانی ایمیل معتبر نیست.',
        ),
      );
      return;
    }
    if (password.isEmpty) {
      _setError(
        const CloudAccountException(
          'missing_password',
          'رمز عبور را وارد کنید.',
        ),
      );
      return;
    }

    _phase = CloudAccountPhase.signingIn;
    _error = null;
    _notify();
    _ignoreAuthEvents = true;
    try {
      final CloudAuthSnapshot auth = await _service.signIn(
        email: normalizedEmail,
        password: password,
      );
      _auth = auth;
      _profile = await _fetchAuthorizedProfile(auth);
      _phase = CloudAccountPhase.signedIn;
    } catch (error) {
      await _clearRejectedSession();
      _error = error;
      _phase = CloudAccountPhase.signedOut;
    } finally {
      _ignoreAuthEvents = false;
      _notify();
    }
  }

  Future<void> signOut() async {
    if (!isAvailable || !hasSession || isBusy) {
      return;
    }

    _phase = CloudAccountPhase.signingOut;
    _error = null;
    _notify();
    _ignoreAuthEvents = true;
    try {
      await _service.signOut();
      _clearAccountState();
      _phase = CloudAccountPhase.signedOut;
    } catch (error) {
      _error = error;
      _phase = _profile == null
          ? CloudAccountPhase.signedOut
          : CloudAccountPhase.signedIn;
    } finally {
      _ignoreAuthEvents = false;
      _notify();
    }
  }

  Future<void> refreshProfile() async {
    if (!hasSession || isBusy) {
      return;
    }

    _phase = CloudAccountPhase.restoring;
    _error = null;
    _notify();
    try {
      _profile = await _fetchAuthorizedProfile(_auth);
      _phase = CloudAccountPhase.signedIn;
    } catch (error) {
      _error = error;
      _phase = _profile == null
          ? CloudAccountPhase.signedOut
          : CloudAccountPhase.signedIn;
    } finally {
      _notify();
    }
  }

  Future<void> _restoreProfile(CloudAuthSnapshot auth) async {
    final int request = ++_profileRequest;
    try {
      final CloudAccountProfile profile = await _fetchAuthorizedProfile(auth);
      if (request != _profileRequest || !_sameUser(auth, _auth)) {
        return;
      }
      _profile = profile;
      _error = null;
      _phase = CloudAccountPhase.signedIn;
    } catch (error) {
      if (request != _profileRequest) {
        return;
      }
      await _clearRejectedSession();
      _error = error;
      _phase = CloudAccountPhase.signedOut;
    } finally {
      _notify();
    }
  }

  Future<CloudAccountProfile> _fetchAuthorizedProfile(
    CloudAuthSnapshot auth,
  ) async {
    final String? userId = auth.userId;
    if (userId == null) {
      throw const CloudAccountException(
        'missing_session',
        'جلسه ورود معتبر نیست.',
      );
    }

    final CloudAccountProfile? profile = await _service.fetchProfile(userId);
    if (profile == null) {
      throw const CloudAccountException(
        'profile_missing',
        'پروفایل این حساب در سامانه ساخته نشده است.',
      );
    }
    if (profile.role != 'coach' && profile.role != 'admin') {
      throw const CloudAccountException(
        'role_not_allowed',
        'این حساب مجوز ورود به اپ مربی را ندارد.',
      );
    }
    if (profile.role == 'coach' && profile.username.isEmpty) {
      throw const CloudAccountException(
        'coach_profile_incomplete',
        'پروفایل مربی کامل نیست.',
      );
    }
    return profile;
  }

  void _handleAuthSnapshot(CloudAuthSnapshot auth) {
    if (_disposed) {
      return;
    }
    _auth = auth;
    if (_ignoreAuthEvents) {
      return;
    }
    if (!auth.isSignedIn) {
      ++_profileRequest;
      _clearAccountState();
      _phase = CloudAccountPhase.signedOut;
      _error = null;
      _notify();
      return;
    }

    _phase = CloudAccountPhase.restoring;
    _error = null;
    _notify();
    unawaited(_restoreProfile(auth));
  }

  void _handleAuthStreamError(Object error, StackTrace stackTrace) {
    if (_disposed) {
      return;
    }
    _error = const CloudAccountException(
      'auth_stream_error',
      'به‌روزرسانی وضعیت حساب با خطا روبه‌رو شد.',
    );
    if (!hasSession) {
      _phase = CloudAccountPhase.signedOut;
    }
    _notify();
  }

  Future<void> _clearRejectedSession() async {
    ++_profileRequest;
    try {
      if (_service.currentAuth.isSignedIn || _auth.isSignedIn) {
        await _service.signOut();
      }
    } catch (_) {
      // The rejected account must never remain authorized in this controller.
    }
    _clearAccountState();
  }

  void _clearAccountState() {
    _auth = const CloudAuthSnapshot.signedOut();
    _profile = null;
  }

  void _setError(Object error) {
    _error = error;
    _notify();
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  static bool _sameUser(CloudAuthSnapshot left, CloudAuthSnapshot right) =>
      left.userId != null && left.userId == right.userId;

  static bool _looksLikeEmail(String value) {
    final int at = value.indexOf('@');
    final int dot = value.lastIndexOf('.');
    return at > 0 && dot > at + 1 && dot < value.length - 1;
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_authSubscription?.cancel());
    super.dispose();
  }
}
