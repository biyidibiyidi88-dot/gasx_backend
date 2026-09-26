import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../models/auth_models.dart';
import '../../core/constants/api_constants.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<AuthResponse> login(String email, String password) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    return AuthResponse.fromJson(response.data);
  }

  Future<AuthResponse> register(Map<String, dynamic> userData) async {
    final containsFiles = userData.values.any((value) => value is PlatformFile);
    dynamic payload = userData;
    if (containsFiles) {
      final fields = <String, dynamic>{};
      for (final entry in userData.entries) {
        final value = entry.value;
        if (value is PlatformFile) {
          final bytes = value.bytes;
          if (bytes == null) {
            throw StateError(
              'Could not read ${value.name}. Please choose the document again.',
            );
          }
          fields[entry.key] = MultipartFile.fromBytes(
            bytes,
            filename: value.name,
          );
        } else {
          fields[entry.key] = value;
        }
      }
      payload = FormData.fromMap(fields);
    }
    final response = await _dio.post(
      ApiConstants.register,
      data: payload,
      options: containsFiles
          ? Options(contentType: 'multipart/form-data')
          : null,
    );
    return AuthResponse.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<UserAccount> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.profile);
      return UserAccount.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserAccount> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch(ApiConstants.profile, data: data);
      return UserAccount.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _dio.delete('/api/users/profile/delete/');
    } catch (e) {
      rethrow;
    }
  }
}
