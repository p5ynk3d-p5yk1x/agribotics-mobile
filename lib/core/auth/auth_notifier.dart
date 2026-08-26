import 'package:agribotics/core/auth/auth-repository.dart';
import 'package:agribotics/core/auth/auth_state.dart';
import 'package:flutter_riverpod/legacy.dart';

class AuthNotifier extends StateNotifier<AuthState> {

  final AuthRepository authRepository;
  AuthNotifier(this.authRepository) : super(const AuthLoading()) {
    _init();
  }
  Future<void> _init() async {
    final loggedIn =
    await authRepository.isLoggedIn();
    state = loggedIn ? const AuthAuthenticated() : const AuthUnauthenticated();
  }

  Future<void> signInGoogle() async {
    await authRepository.signInWithGoogle();
    state = const AuthAuthenticated();
  }

  Future<void> logout() async {
    await authRepository.signOut();
    state = const AuthUnauthenticated();
  }
}