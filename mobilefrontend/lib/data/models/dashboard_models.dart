import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_models.freezed.dart';
part 'dashboard_models.g.dart';

@freezed
class GasSensor with _$GasSensor {
  const factory GasSensor({
    required int id,
    @JsonKey(name: 'serial_number') required String sensorId,
    @JsonKey(name: 'sensor_name') required String name,
    @JsonKey(name: 'current_gas_level') required double currentLevel,
    @Default(0.0) @JsonKey(name: 'current_gas_percentage') double currentGasPercentage,
    @Default(0.0) @JsonKey(name: 'raw_weight') double rawWeight,
    @Default('OPEN') @JsonKey(name: 'desired_valve_state') String desiredValveState,
    @Default('OPEN') @JsonKey(name: 'current_valve_state') String currentValveState,
    @Default('ARM') @JsonKey(name: 'desired_alarm_state') String desiredAlarmState,
    @Default(false) @JsonKey(name: 'is_alarm_silenced') bool isAlarmSilenced,
    @JsonKey(name: 'updated_at') required DateTime lastUpdate,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'alert_threshold') double? alertThreshold,
  }) = _GasSensor;

  factory GasSensor.fromJson(Map<String, dynamic> json) => _$GasSensorFromJson(json);
}

@freezed
class GasReading with _$GasReading {
  const factory GasReading({
    required int id,
    @JsonKey(name: 'remaining_gas') required double gasLevel,
    @JsonKey(name: 'reading_timestamp') required DateTime timestamp,
  }) = _GasReading;

  factory GasReading.fromJson(Map<String, dynamic> json) => _$GasReadingFromJson(json);
}

@freezed
class PredictionData with _$PredictionData {
  const factory PredictionData({
    @JsonKey(name: 'projected_days') required double daysRemaining,
    @JsonKey(name: 'expected_depletion_date') DateTime? expectedDepletionDate,
    @JsonKey(name: 'confidence') required double confidenceScore,
    required String trend,
    required String recommendation,
  }) = _PredictionData;

  factory PredictionData.fromJson(Map<String, dynamic> json) => _$PredictionDataFromJson(json);
}

@freezed
class DailyConsumption with _$DailyConsumption {
  const factory DailyConsumption({
    required String date,
    @JsonKey(name: 'consumption_kg') required double consumption,
    @JsonKey(name: 'avg_remaining_kg') required double avgRemaining,
    @JsonKey(name: 'gas_percentage') required double gasPercentage,
  }) = _DailyConsumption;

  factory DailyConsumption.fromJson(Map<String, dynamic> json) => _$DailyConsumptionFromJson(json);
}
