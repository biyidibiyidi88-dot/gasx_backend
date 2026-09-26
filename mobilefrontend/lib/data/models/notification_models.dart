import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_models.freezed.dart';
part 'notification_models.g.dart';

@freezed
class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required int id,
    @JsonKey(name: 'alert_type') required String alertType,
    @JsonKey(name: 'severity_level') required String severityLevel,
    @JsonKey(name: 'alert_message') required String alertMessage,
    @JsonKey(name: 'is_resolved') required bool isResolved,
    @JsonKey(name: 'triggered_at') required DateTime triggeredAt,
    @JsonKey(name: 'sensor_name') String? sensorName,
    @JsonKey(name: 'house_address') String? houseAddress,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) => _$NotificationModelFromJson(json);
}
