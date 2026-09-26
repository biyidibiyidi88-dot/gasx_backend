// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) {
  return _NotificationModel.fromJson(json);
}

/// @nodoc
mixin _$NotificationModel {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'alert_type')
  String get alertType => throw _privateConstructorUsedError;
  @JsonKey(name: 'severity_level')
  String get severityLevel => throw _privateConstructorUsedError;
  @JsonKey(name: 'alert_message')
  String get alertMessage => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_resolved')
  bool get isResolved => throw _privateConstructorUsedError;
  @JsonKey(name: 'triggered_at')
  DateTime get triggeredAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'sensor_name')
  String? get sensorName => throw _privateConstructorUsedError;
  @JsonKey(name: 'house_address')
  String? get houseAddress => throw _privateConstructorUsedError;

  /// Serializes this NotificationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationModelCopyWith<NotificationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationModelCopyWith<$Res> {
  factory $NotificationModelCopyWith(
    NotificationModel value,
    $Res Function(NotificationModel) then,
  ) = _$NotificationModelCopyWithImpl<$Res, NotificationModel>;
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'alert_type') String alertType,
    @JsonKey(name: 'severity_level') String severityLevel,
    @JsonKey(name: 'alert_message') String alertMessage,
    @JsonKey(name: 'is_resolved') bool isResolved,
    @JsonKey(name: 'triggered_at') DateTime triggeredAt,
    @JsonKey(name: 'sensor_name') String? sensorName,
    @JsonKey(name: 'house_address') String? houseAddress,
  });
}

/// @nodoc
class _$NotificationModelCopyWithImpl<$Res, $Val extends NotificationModel>
    implements $NotificationModelCopyWith<$Res> {
  _$NotificationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? alertType = null,
    Object? severityLevel = null,
    Object? alertMessage = null,
    Object? isResolved = null,
    Object? triggeredAt = null,
    Object? sensorName = freezed,
    Object? houseAddress = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            alertType: null == alertType
                ? _value.alertType
                : alertType // ignore: cast_nullable_to_non_nullable
                      as String,
            severityLevel: null == severityLevel
                ? _value.severityLevel
                : severityLevel // ignore: cast_nullable_to_non_nullable
                      as String,
            alertMessage: null == alertMessage
                ? _value.alertMessage
                : alertMessage // ignore: cast_nullable_to_non_nullable
                      as String,
            isResolved: null == isResolved
                ? _value.isResolved
                : isResolved // ignore: cast_nullable_to_non_nullable
                      as bool,
            triggeredAt: null == triggeredAt
                ? _value.triggeredAt
                : triggeredAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            sensorName: freezed == sensorName
                ? _value.sensorName
                : sensorName // ignore: cast_nullable_to_non_nullable
                      as String?,
            houseAddress: freezed == houseAddress
                ? _value.houseAddress
                : houseAddress // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NotificationModelImplCopyWith<$Res>
    implements $NotificationModelCopyWith<$Res> {
  factory _$$NotificationModelImplCopyWith(
    _$NotificationModelImpl value,
    $Res Function(_$NotificationModelImpl) then,
  ) = __$$NotificationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'alert_type') String alertType,
    @JsonKey(name: 'severity_level') String severityLevel,
    @JsonKey(name: 'alert_message') String alertMessage,
    @JsonKey(name: 'is_resolved') bool isResolved,
    @JsonKey(name: 'triggered_at') DateTime triggeredAt,
    @JsonKey(name: 'sensor_name') String? sensorName,
    @JsonKey(name: 'house_address') String? houseAddress,
  });
}

/// @nodoc
class __$$NotificationModelImplCopyWithImpl<$Res>
    extends _$NotificationModelCopyWithImpl<$Res, _$NotificationModelImpl>
    implements _$$NotificationModelImplCopyWith<$Res> {
  __$$NotificationModelImplCopyWithImpl(
    _$NotificationModelImpl _value,
    $Res Function(_$NotificationModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? alertType = null,
    Object? severityLevel = null,
    Object? alertMessage = null,
    Object? isResolved = null,
    Object? triggeredAt = null,
    Object? sensorName = freezed,
    Object? houseAddress = freezed,
  }) {
    return _then(
      _$NotificationModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        alertType: null == alertType
            ? _value.alertType
            : alertType // ignore: cast_nullable_to_non_nullable
                  as String,
        severityLevel: null == severityLevel
            ? _value.severityLevel
            : severityLevel // ignore: cast_nullable_to_non_nullable
                  as String,
        alertMessage: null == alertMessage
            ? _value.alertMessage
            : alertMessage // ignore: cast_nullable_to_non_nullable
                  as String,
        isResolved: null == isResolved
            ? _value.isResolved
            : isResolved // ignore: cast_nullable_to_non_nullable
                  as bool,
        triggeredAt: null == triggeredAt
            ? _value.triggeredAt
            : triggeredAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        sensorName: freezed == sensorName
            ? _value.sensorName
            : sensorName // ignore: cast_nullable_to_non_nullable
                  as String?,
        houseAddress: freezed == houseAddress
            ? _value.houseAddress
            : houseAddress // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationModelImpl implements _NotificationModel {
  const _$NotificationModelImpl({
    required this.id,
    @JsonKey(name: 'alert_type') required this.alertType,
    @JsonKey(name: 'severity_level') required this.severityLevel,
    @JsonKey(name: 'alert_message') required this.alertMessage,
    @JsonKey(name: 'is_resolved') required this.isResolved,
    @JsonKey(name: 'triggered_at') required this.triggeredAt,
    @JsonKey(name: 'sensor_name') this.sensorName,
    @JsonKey(name: 'house_address') this.houseAddress,
  });

  factory _$NotificationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationModelImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'alert_type')
  final String alertType;
  @override
  @JsonKey(name: 'severity_level')
  final String severityLevel;
  @override
  @JsonKey(name: 'alert_message')
  final String alertMessage;
  @override
  @JsonKey(name: 'is_resolved')
  final bool isResolved;
  @override
  @JsonKey(name: 'triggered_at')
  final DateTime triggeredAt;
  @override
  @JsonKey(name: 'sensor_name')
  final String? sensorName;
  @override
  @JsonKey(name: 'house_address')
  final String? houseAddress;

  @override
  String toString() {
    return 'NotificationModel(id: $id, alertType: $alertType, severityLevel: $severityLevel, alertMessage: $alertMessage, isResolved: $isResolved, triggeredAt: $triggeredAt, sensorName: $sensorName, houseAddress: $houseAddress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.alertType, alertType) ||
                other.alertType == alertType) &&
            (identical(other.severityLevel, severityLevel) ||
                other.severityLevel == severityLevel) &&
            (identical(other.alertMessage, alertMessage) ||
                other.alertMessage == alertMessage) &&
            (identical(other.isResolved, isResolved) ||
                other.isResolved == isResolved) &&
            (identical(other.triggeredAt, triggeredAt) ||
                other.triggeredAt == triggeredAt) &&
            (identical(other.sensorName, sensorName) ||
                other.sensorName == sensorName) &&
            (identical(other.houseAddress, houseAddress) ||
                other.houseAddress == houseAddress));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    alertType,
    severityLevel,
    alertMessage,
    isResolved,
    triggeredAt,
    sensorName,
    houseAddress,
  );

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationModelImplCopyWith<_$NotificationModelImpl> get copyWith =>
      __$$NotificationModelImplCopyWithImpl<_$NotificationModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationModelImplToJson(this);
  }
}

abstract class _NotificationModel implements NotificationModel {
  const factory _NotificationModel({
    required final int id,
    @JsonKey(name: 'alert_type') required final String alertType,
    @JsonKey(name: 'severity_level') required final String severityLevel,
    @JsonKey(name: 'alert_message') required final String alertMessage,
    @JsonKey(name: 'is_resolved') required final bool isResolved,
    @JsonKey(name: 'triggered_at') required final DateTime triggeredAt,
    @JsonKey(name: 'sensor_name') final String? sensorName,
    @JsonKey(name: 'house_address') final String? houseAddress,
  }) = _$NotificationModelImpl;

  factory _NotificationModel.fromJson(Map<String, dynamic> json) =
      _$NotificationModelImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'alert_type')
  String get alertType;
  @override
  @JsonKey(name: 'severity_level')
  String get severityLevel;
  @override
  @JsonKey(name: 'alert_message')
  String get alertMessage;
  @override
  @JsonKey(name: 'is_resolved')
  bool get isResolved;
  @override
  @JsonKey(name: 'triggered_at')
  DateTime get triggeredAt;
  @override
  @JsonKey(name: 'sensor_name')
  String? get sensorName;
  @override
  @JsonKey(name: 'house_address')
  String? get houseAddress;

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationModelImplCopyWith<_$NotificationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
