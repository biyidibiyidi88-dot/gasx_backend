import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/dashboard_models.dart';
import '../models/recipe.dart';
import '../../core/constants/api_constants.dart';

class DashboardRepository {
  final Dio _dio;

  DashboardRepository(this._dio);

  Future<List<GasSensor>> getSensors() async {
    try {
      final response = await _dio.get(ApiConstants.sensors);
      return (response.data as List)
          .map((e) => GasSensor.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> controlValve(int sensorId, String command) async {
    try {
      await _dio.post(
        'sensors/$sensorId/control-valve/',
        data: {'command': command},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<DailyConsumption>> getDailyReadings() async {
    try {
      final response = await _dio.get(
        ApiConstants.dailyConsumption,
        queryParameters: {
          'start_date': DateTime.now()
              .subtract(const Duration(days: 30))
              .toIso8601String()
              .split('T')[0],
          'end_date': DateTime.now().toIso8601String().split('T')[0],
        },
      );

      final data = response.data;
      if (data is Map && data['data'] != null) {
        return (data['data'] as List)
            .map((e) => DailyConsumption.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return (data as List)
          .map((e) => DailyConsumption.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<PredictionData> getPrediction(int sensorId) async {
    try {
      final response = await _dio.get(ApiConstants.gasPrediction);
      final data = response.data;
      if (data is Map && data['status_code'] == 200) {
        return PredictionData.fromJson(Map<String, dynamic>.from(data));
      }
      return PredictionData.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Recipe>> getCookableFoods(int sensorId) async {
    try {
      final response = await _dio.get(
        ApiConstants.sensorCookableFoods(sensorId),
      );
      dynamic data = response.data;

      // Handle string response if Dio didn't decode it
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (e) {
          print('Error decoding cookable foods string response: $e');
        }
      }

      if (data is! List) {
        print('Error: Cookable foods response data is not a list: $data');
        // Return dummy data for UI testing if API fails
        return _getDummyFoods();
      }

      final dataList = data;
      return dataList
          .map((e) {
            try {
              final map = Map<String, dynamic>.from(e as Map);
              return Recipe.fromJson(map);
            } catch (err) {
              print('Error parsing cookable food item: $err, data: $e');
              // Skip invalid items instead of failing the whole list
              return null;
            }
          })
          .whereType<Recipe>()
          .toList();
    } catch (e) {
      print('Error fetching cookable foods: $e');
      return _getDummyFoods(); // Return dummy data as fallback
    }
  }

  List<Recipe> _getDummyFoods() {
    return [
      Recipe(
        id: -1,
        name: 'TEA / COFFEE (LOCAL)',
        estimatedGasRequired: 0.01,
        cookingTimeMinutes: 5,
      ),
      Recipe(
        id: -2,
        name: 'INSTANT NOODLES (LOCAL)',
        estimatedGasRequired: 0.02,
        cookingTimeMinutes: 10,
      ),
    ];
  }
}
