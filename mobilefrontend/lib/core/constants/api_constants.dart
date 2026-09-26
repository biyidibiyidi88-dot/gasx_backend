import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class ApiConstants {
  // Base URLs
  static String get baseUrl {
    if (kReleaseMode) {
      return prodBaseUrl;
    }

    // Check for web first as Platform is not available on web
    if (kIsWeb) {
      return 'http://localhost:8000/api/';
    }

    // For mobile (Android emulator uses 10.0.2.2 to access host machine)
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api/';
    }

    // iOS and Desktop
    return 'http://127.0.0.1:8000/api/';
  }

  static const String localBaseUrl = 'http://127.0.0.1:8000/api/';
  static const String prodBaseUrl =
      'https://gasx-backend-production.up.railway.app/api/';

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
