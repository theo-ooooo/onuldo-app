import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/network/api_client.dart';
import '../../core/network/auth_interceptor.dart';
import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

class AuthState {
  final AuthStatus status;
  final UserInfo? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserInfo? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final FlutterSecureStorage _storage;

  AuthNotifier(this._authRepository, this._storage)
      : super(const AuthState());

  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);

    final hasToken = await AuthInterceptor.hasTokens(_storage);

    if (hasToken) {
      state = state.copyWith(status: AuthStatus.authenticated);
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    try {
      final result = await _authRepository.login(
        LoginRequest(email: email, password: password),
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: result.user,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.message,
      );
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String nickname) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    try {
      await _authRepository.signUp(
        SignUpRequest(
          email: email,
          password: password,
          nickname: nickname,
        ),
      );

      // Auto login after signup
      return login(email, password);
    } on ApiException catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.message,
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authRepositoryProvider),
    ref.read(secureStorageProvider),
  );
});
