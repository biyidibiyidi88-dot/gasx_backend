import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

class ApiConstants {
  // Every app build tries Railway first, then the local Django server.
  static const String onlineBaseUrl =
      'https://web-production-c23ce.up.railway.app/api/';

  // Keep baseUrl for existing call sites; it always means the online primary.
  static String get baseUrl => onlineBaseUrl;

  // Physical devices can override this at build time, for example:
  // --dart-define=LOCAL_API_BASE_URL=http://192.168.1.10:8000/api/
  static const String _localBaseUrlOverride = String.fromEnvironment(
    'LOCAL_API_BASE_URL',
  );

  static String get localBaseUrl {
    if (_localBaseUrlOverride.trim().isNotEmpty) {
      return _normalizeBaseUrl(_localBaseUrlOverride);
    }
    if (kIsWeb) return 'http://localhost:8000/api/';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api/';
    return 'http://127.0.0.1:8000/api/';
  }

  static List<String> get apiBaseUrls {
    final local = localBaseUrl;
    return local == onlineBaseUrl ? [onlineBaseUrl] : [onlineBaseUrl, local];
  }

  static String websocketUrlFor(String apiBaseUrl, String token) {
    final normalizedBase = _normalizeBaseUrl(apiBaseUrl);
    final serverBase = normalizedBase
        .replaceFirst(RegExp(r'/api/?$'), '')
        .replaceFirst(RegExp(r'/$'), '');
    final websocketBase = serverBase
        .replaceFirst(RegExp(r'^https://'), 'wss://')
        .replaceFirst(RegExp(r'^http://'), 'ws://');
    final encodedToken = Uri.encodeQueryComponent(token.trim());
    return '$websocketBase/ws/gas-monitor/?token=$encodedToken';
  }

  static String _normalizeBaseUrl(String url) {
    final trimmed = url.trim();
    return trimmed.endsWith('/') ? trimmed : '$trimmed/';
  }

  // Auth endpoints
  static const String register = 'auth/register/';
  static const String login = 'auth/login/';
  static const String logout = 'auth/logout/';
  static const String profile = 'users/profile/';
  static const String profileImage = 'users/profile/image/';

  // Dashboard endpoints
  static const String sensors = 'sensors/';
  static const String gasReadings = 'gas-readings/';
  static const String dailyConsumption = 'gas-readings/daily/';
  static const String gasPrediction = 'gas/prediction/';
  static const String alerts = 'alerts/';
  static String sensorCookableFoods(int sensorId) =>
      'sensors/$sensorId/cookable-foods/';

  // Vendor endpoints
  static const String vendorRegister = 'vendor/register/';
  static const String vendorProfile = 'vendor/profile/';
  static const String vendorInventory = 'vendor/gas-bottles/';

  // Timeout
  static const int receiveTimeout = 15000;
  static const int connectionTimeout = 15000;
}
