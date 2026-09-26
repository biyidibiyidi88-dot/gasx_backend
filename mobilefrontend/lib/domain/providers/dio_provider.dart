import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import 'package:dio/dio.dart';

final dioProvider = Provider<Dio>((ref) {
  return DioClient().dio;
});
