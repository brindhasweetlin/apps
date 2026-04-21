import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/user.dart';

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AsyncValue.data(null)) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final authRepo = _ref.read(authRepositoryProvider);
    final isLoggedIn = await authRepo.isLoggedIn();
    if (isLoggedIn) {
      state = AsyncValue.data(User(id: '1', email: 'user@example.com', token: 'saved_token'));
    }
  }

  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final authRepo = _ref.read(authRepositoryProvider);
      final user = await authRepo.login(email, password);
      if (user != null) {
        state = AsyncValue.data(user);
        return true;
      } else {
        state = AsyncValue.error('Invalid credentials', StackTrace.current);
        return false;
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> logout() async {
    final authRepo = _ref.read(authRepositoryProvider);
    await authRepo.logout();
    state = const AsyncValue.data(null);
  }
}
