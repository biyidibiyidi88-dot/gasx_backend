// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationModelImpl _$$NotificationModelImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationModelImpl(
  id: (json['id'] as num).toInt(),
  alertType: json['alert_type'] as String,
  severityLevel: json['severity_level'] as String,
  alertMessage: json['alert_message'] as String,
  isResolved: json['is_resolved'] as bool,
  triggeredAt: DateTime.parse(json['triggered_at'] as String),
  sensorName: json['sensor_name'] as String?,
  houseAddress: json['house_address'] as String?,
);

Map<String, dynamic> _$$NotificationModelImplToJson(
  _$NotificationModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'alert_type': instance.alertType,
  'severity_level': instance.severityLevel,
  'alert_message': instance.alertMessage,
  'is_resolved': instance.isResolved,
  'triggered_at': instance.triggeredAt.toIso8601String(),
  'sensor_name': instance.sensorName,
  'house_address': instance.houseAddress,
};
