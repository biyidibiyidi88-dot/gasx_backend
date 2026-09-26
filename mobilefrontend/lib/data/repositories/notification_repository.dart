import 'package:dio/dio.dart';
import '../models/notification_models.dart';
import '../../core/constants/api_constants.dart';

class NotificationRepository {
  final Dio _dio;

  NotificationRepository(this._dio);

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _dio.get('/notifications/');
      return (response.data as List).map((n) => NotificationModel.fromJson(n)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _dio.post('/notifications/$id/read/');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _dio.post('/notifications/mark-all-read/');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      await _dio.delete('/notifications/$id/');
    } catch (e) {
      rethrow;
    }
  }
}
