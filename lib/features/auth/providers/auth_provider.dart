import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rnd_proj/core/datasources/firebase/auth_firebase_service.dart';
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

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthFirebaseService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final user = await _authService.getCurrentUserData();
      if (mounted) {
        state = AsyncValue.data(user);
      }
    } catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<bool> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.signInWithEmailPassword(email, password);
      state = AsyncValue.data(user);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.signUpWithEmailPassword(
          name, email, password);
      state = AsyncValue.data(user);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = const AsyncValue.data(null);
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
