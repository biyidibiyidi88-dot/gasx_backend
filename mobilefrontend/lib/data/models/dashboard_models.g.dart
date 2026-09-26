// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GasSensorImpl _$$GasSensorImplFromJson(Map<String, dynamic> json) =>
    _$GasSensorImpl(
      id: (json['id'] as num).toInt(),
      sensorId: json['serial_number'] as String,
      name: json['sensor_name'] as String,
      currentLevel: (json['current_gas_level'] as num).toDouble(),
      currentGasPercentage:
          (json['current_gas_percentage'] as num?)?.toDouble() ?? 0.0,
      rawWeight: (json['raw_weight'] as num?)?.toDouble() ?? 0.0,
      desiredValveState: json['desired_valve_state'] as String? ?? 'OPEN',
      currentValveState: json['current_valve_state'] as String? ?? 'OPEN',
      desiredAlarmState: json['desired_alarm_state'] as String? ?? 'ARM',
      isAlarmSilenced: json['is_alarm_silenced'] as bool? ?? false,
      lastUpdate: DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] as bool,
      alertThreshold: (json['alert_threshold'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$GasSensorImplToJson(_$GasSensorImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'serial_number': instance.sensorId,
      'sensor_name': instance.name,
      'current_gas_level': instance.currentLevel,
      'current_gas_percentage': instance.currentGasPercentage,
      'raw_weight': instance.rawWeight,
      'desired_valve_state': instance.desiredValveState,
      'current_valve_state': instance.currentValveState,
      'desired_alarm_state': instance.desiredAlarmState,
      'is_alarm_silenced': instance.isAlarmSilenced,
      'updated_at': instance.lastUpdate.toIso8601String(),
      'is_active': instance.isActive,
      'alert_threshold': instance.alertThreshold,
    };

_$GasReadingImpl _$$GasReadingImplFromJson(Map<String, dynamic> json) =>
    _$GasReadingImpl(
      id: (json['id'] as num).toInt(),
      gasLevel: (json['remaining_gas'] as num).toDouble(),
      timestamp: DateTime.parse(json['reading_timestamp'] as String),
    );

Map<String, dynamic> _$$GasReadingImplToJson(_$GasReadingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'remaining_gas': instance.gasLevel,
      'reading_timestamp': instance.timestamp.toIso8601String(),
    };

_$PredictionDataImpl _$$PredictionDataImplFromJson(Map<String, dynamic> json) =>
    _$PredictionDataImpl(
      daysRemaining: (json['projected_days'] as num).toDouble(),
      expectedDepletionDate: json['expected_depletion_date'] == null
          ? null
          : DateTime.parse(json['expected_depletion_date'] as String),
      confidenceScore: (json['confidence'] as num).toDouble(),
      trend: json['trend'] as String,
      recommendation: json['recommendation'] as String,
    );

Map<String, dynamic> _$$PredictionDataImplToJson(
  _$PredictionDataImpl instance,
) => <String, dynamic>{
  'projected_days': instance.daysRemaining,
  'expected_depletion_date': instance.expectedDepletionDate?.toIso8601String(),
  'confidence': instance.confidenceScore,
  'trend': instance.trend,
  'recommendation': instance.recommendation,
};

_$DailyConsumptionImpl _$$DailyConsumptionImplFromJson(
  Map<String, dynamic> json,
) => _$DailyConsumptionImpl(
  date: json['date'] as String,
  consumption: (json['consumption_kg'] as num).toDouble(),
  avgRemaining: (json['avg_remaining_kg'] as num).toDouble(),
  gasPercentage: (json['gas_percentage'] as num).toDouble(),
);

Map<String, dynamic> _$$DailyConsumptionImplToJson(
  _$DailyConsumptionImpl instance,
) => <String, dynamic>{
  'date': instance.date,
  'consumption_kg': instance.consumption,
  'avg_remaining_kg': instance.avgRemaining,
  'gas_percentage': instance.gasPercentage,
};
