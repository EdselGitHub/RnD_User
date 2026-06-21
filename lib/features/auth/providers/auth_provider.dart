import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rnd_proj/core/services/auth_firebase_service.dart';
import 'package:rnd_proj/core/models/user_model.dart';

final authServiceProvider = Provider<AuthFirebaseService>((ref) {
  return AuthFirebaseService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

final currentUserProvider = FutureProvider<UserModel?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.getCurrentUserData();
});

class AuthNotifier extends AsyncNotifier<UserModel?> {
  AuthFirebaseService get _authService => ref.read(authServiceProvider);

  @override
  FutureOr<UserModel?> build() async {
    return _authService.getCurrentUserData();
  }

  Future<bool> signIn(String email, String password) async {
    state = const AsyncLoading();
    try {
      final user = await _authService.signInWithEmailPassword(email, password);
      state = AsyncData(user);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    state = const AsyncLoading();
    try {
      final user = await _authService.signUpWithEmailPassword(
          name, email, password);
      state = AsyncData(user);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = const AsyncData(null);
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, UserModel?>(() {
  return AuthNotifier();
});
