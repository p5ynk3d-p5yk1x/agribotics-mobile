import 'dart:async';

import 'package:agribotics/core/auth/auth-repository.dart';
import 'package:agribotics/core/auth/auth_state.dart';
import 'package:flutter_riverpod/legacy.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  Timer? _sessionTimer;
  Future<void>? _initialization;

  AuthNotifier(this.authRepository) : super(const AuthLoading()) {
    ensureInitialized();
  }

  Future<void> ensureInitialized() {
    return _initialization ??= _restoreSession();
  }

  Future<void> _restoreSession() async {
    final remaining = await authRepository.validSessionRemaining();
    if (remaining == null) {
      state = const AuthUnauthenticated();
      return;
    }

    state = const AuthAuthenticated();
    _scheduleSignOut(remaining);
  }

  Future<void> signInGoogle() async {
    await authRepository.signInWithGoogle();
    state = const AuthAuthenticated();
    _scheduleSignOut(AuthRepository.sessionDuration);
  }

  Future<void> logout() async {
    _sessionTimer?.cancel();
    try {
      await authRepository.signOut();
    } finally {
      state = const AuthUnauthenticated();
    }
  }

  void _scheduleSignOut(Duration remaining) {
    _sessionTimer?.cancel();
    _sessionTimer = Timer(remaining, () async {
      await authRepository.clearSession();
      state = const AuthUnauthenticated();
    });
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }
}
