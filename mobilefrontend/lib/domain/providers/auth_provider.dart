import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../../data/models/auth_models.dart';
import '../../data/repositories/auth_repository.dart';
import 'dio_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio);
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthState {
  final UserAccount? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({UserAccount? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final _storage = const FlutterSecureStorage();

  AuthNotifier(this._repository) : super(AuthState()) {
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    String? token;
    try {
      token = await _storage.read(key: 'authToken');
    } catch (e) {
      print('Storage read error details: $e');
    }

    if (token != null) {
      try {
        final user = await _repository.getProfile();
        state = state.copyWith(user: user);
      } catch (e) {
        // If token is invalid/expired, clear it
        try {
          await _storage.delete(key: 'authToken');
        } catch (_) {}
      }
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.login(email, password);
      try {
        await _storage.write(key: 'authToken', value: response.token);
        // Verify immediately
        final saved = await _storage.read(key: 'authToken');
        print('AUTH: Token saved and verified: ${saved != null}');
      } catch (e) {
        print('AUTH: Storage write error: $e');
      }
      state = state.copyWith(user: response.user, isLoading: false);
    } catch (e, st) {
      print('LOGIN EXCEPTION: $e\nStackTrace: $st');
      String errorMessage = 'Login failed. Please check your credentials.';
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic>) {
          if (data['errors'] != null && data['errors'] is Map) {
            final firstError = (data['errors'] as Map).values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError.first.toString();
            } else {
              errorMessage = firstError.toString();
            }
          } else if (data['message'] != null) {
            errorMessage = data['message'].toString();
          }
        }
      } else {
        errorMessage = 'EXCEPTION: $e';
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  Future<void> register(Map<String, dynamic> userData) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.register(userData);
      try {
        await _storage.write(key: 'authToken', value: response.token);
      } catch (e) {
        print('Storage write error ignored: $e');
      }
      state = state.copyWith(user: response.user, isLoading: false);
    } catch (e, st) {
      print('REGISTER EXCEPTION: $e\nStackTrace: $st');
      String errorMessage = 'Registration failed. Email might be already in use.';
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic>) {
          if (data['errors'] != null && data['errors'] is Map) {
            final firstError = (data['errors'] as Map).values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError.first.toString();
            } else {
              errorMessage = firstError.toString();
            }
          } else if (data['message'] != null) {
            errorMessage = data['message'].toString();
          }
        }
      } else {
        errorMessage = 'EXCEPTION: $e';
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }
  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (_) {}
    try {
      await _storage.delete(key: 'authToken');
    } catch (_) {}
    state = AuthState();
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedUser = await _repository.updateProfile(data);
      state = state.copyWith(user: updatedUser, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteAccount();
      await logout(); // Clear local state and storage
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}
