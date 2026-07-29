import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:coach_app/features/account/data/cloud_account_service.dart';
import 'package:coach_app/features/account/presentation/cloud_account_controller.dart';

void main() {
  group('CloudAccountController', () {
    test('starts signed out when no cached session exists', () {
      final _FakeCloudAccountService service = _FakeCloudAccountService();
      final CloudAccountController controller = CloudAccountController(
        service: service,
      );

      expect(controller.isAvailable, isTrue);
      expect(controller.hasSession, isFalse);
      expect(controller.isSignedIn, isFalse);
      expect(controller.phase, CloudAccountPhase.signedOut);

      controller.dispose();
      service.dispose();
    });

    test('signs in a valid coach and loads coach profile', () async {
      final _FakeCloudAccountService service = _FakeCloudAccountService(
        profile: const CloudAccountProfile(
          userId: 'coach-1',
          role: 'coach',
          fullName: 'مربی آزمایشی',
          phone: '',
          username: 'coach_test',
          displayName: 'مربی آزمایشی',
          acceptingClients: true,
        ),
      );
      final CloudAccountController controller = CloudAccountController(
        service: service,
      );

      await controller.signIn(
        email: 'COACH@EXAMPLE.COM ',
        password: 'strong-password',
      );

      expect(service.lastEmail, 'coach@example.com');
      expect(controller.isSignedIn, isTrue);
      expect(controller.isAuthorizedCoach, isTrue);
      expect(controller.username, 'coach_test');
      expect(controller.acceptingClients, isTrue);
      expect(controller.error, isNull);

      controller.dispose();
      service.dispose();
    });

    test('rejects an athlete account and clears its session', () async {
      final _FakeCloudAccountService service = _FakeCloudAccountService(
        profile: const CloudAccountProfile(
          userId: 'coach-1',
          role: 'athlete',
          fullName: 'شاگرد آزمایشی',
          phone: '',
        ),
      );
      final CloudAccountController controller = CloudAccountController(
        service: service,
      );

      await controller.signIn(
        email: 'athlete@example.com',
        password: 'strong-password',
      );

      expect(service.signOutCount, 1);
      expect(controller.hasSession, isFalse);
      expect(controller.isSignedIn, isFalse);
      expect(controller.error, isA<CloudAccountException>());
      expect(
        (controller.error! as CloudAccountException).code,
        'role_not_allowed',
      );

      controller.dispose();
      service.dispose();
    });

    test('restores a cached coach session', () async {
      final _FakeCloudAccountService service = _FakeCloudAccountService(
        currentAuth: const CloudAuthSnapshot(
          userId: 'coach-1',
          email: 'coach@example.com',
        ),
        profile: const CloudAccountProfile(
          userId: 'coach-1',
          role: 'coach',
          fullName: 'مربی آزمایشی',
          phone: '',
          username: 'coach_test',
        ),
      );
      final CloudAccountController controller = CloudAccountController(
        service: service,
      );

      await _flushAsyncWork();

      expect(controller.hasSession, isTrue);
      expect(controller.isSignedIn, isTrue);
      expect(controller.phase, CloudAccountPhase.signedIn);

      controller.dispose();
      service.dispose();
    });

    test('keeps cached session after a transient profile error', () async {
      final _FakeCloudAccountService service = _FakeCloudAccountService(
        currentAuth: const CloudAuthSnapshot(
          userId: 'coach-1',
          email: 'coach@example.com',
        ),
        fetchError: StateError('network unavailable'),
      );
      final CloudAccountController controller = CloudAccountController(
        service: service,
      );

      await _flushAsyncWork();

      expect(controller.hasSession, isTrue);
      expect(controller.isSignedIn, isFalse);
      expect(controller.phase, CloudAccountPhase.signedOut);
      expect(controller.error, isA<StateError>());
      expect(service.signOutCount, 0);

      controller.dispose();
      service.dispose();
    });

    test('handles auth stream errors without an unhandled exception', () async {
      final _FakeCloudAccountService service = _FakeCloudAccountService();
      final CloudAccountController controller = CloudAccountController(
        service: service,
      );

      service.emitError(StateError('refresh failed'));
      await _flushAsyncWork();

      expect(controller.error, isA<CloudAccountException>());
      expect(
        (controller.error! as CloudAccountException).code,
        'auth_stream_error',
      );

      controller.dispose();
      service.dispose();
    });
  });
}

Future<void> _flushAsyncWork() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

class _FakeCloudAccountService implements CloudAccountService {
  _FakeCloudAccountService({
    CloudAuthSnapshot currentAuth = const CloudAuthSnapshot.signedOut(),
    this.profile,
    this.fetchError,
  }) : _currentAuth = currentAuth;

  final StreamController<CloudAuthSnapshot> _authController =
      StreamController<CloudAuthSnapshot>.broadcast(sync: true);
  CloudAuthSnapshot _currentAuth;
  CloudAccountProfile? profile;
  Object? fetchError;
  int signOutCount = 0;
  String? lastEmail;

  @override
  bool get isAvailable => true;

  @override
  Object? get initializationError => null;

  @override
  CloudAuthSnapshot get currentAuth => _currentAuth;

  @override
  Stream<CloudAuthSnapshot> get authChanges => _authController.stream;

  @override
  Future<CloudAccountProfile?> fetchProfile(String userId) async {
    final Object? error = fetchError;
    if (error != null) {
      throw error;
    }
    return profile;
  }

  @override
  Future<CloudAuthSnapshot> signIn({
    required String email,
    required String password,
  }) async {
    lastEmail = email;
    _currentAuth = CloudAuthSnapshot(userId: 'coach-1', email: email);
    _authController.add(_currentAuth);
    return _currentAuth;
  }

  @override
  Future<void> signOut() async {
    signOutCount += 1;
    _currentAuth = const CloudAuthSnapshot.signedOut();
    _authController.add(_currentAuth);
  }

  void emitError(Object error) {
    _authController.addError(error, StackTrace.current);
  }

  void dispose() {
    _authController.close();
  }
}
