// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GasSensor _$GasSensorFromJson(Map<String, dynamic> json) {
  return _GasSensor.fromJson(json);
}

/// @nodoc
mixin _$GasSensor {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'serial_number')
  String get sensorId => throw _privateConstructorUsedError;
  @JsonKey(name: 'sensor_name')
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_gas_level')
  double get currentLevel => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_gas_percentage')
  double get currentGasPercentage => throw _privateConstructorUsedError;
  @JsonKey(name: 'raw_weight')
  double get rawWeight => throw _privateConstructorUsedError;
  @JsonKey(name: 'desired_valve_state')
  String get desiredValveState => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_valve_state')
  String get currentValveState => throw _privateConstructorUsedError;
  @JsonKey(name: 'desired_alarm_state')
  String get desiredAlarmState => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_alarm_silenced')
  bool get isAlarmSilenced => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get lastUpdate => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'alert_threshold')
  double? get alertThreshold => throw _privateConstructorUsedError;

  /// Serializes this GasSensor to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GasSensor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GasSensorCopyWith<GasSensor> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GasSensorCopyWith<$Res> {
  factory $GasSensorCopyWith(GasSensor value, $Res Function(GasSensor) then) =
      _$GasSensorCopyWithImpl<$Res, GasSensor>;
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'serial_number') String sensorId,
    @JsonKey(name: 'sensor_name') String name,
    @JsonKey(name: 'current_gas_level') double currentLevel,
    @JsonKey(name: 'current_gas_percentage') double currentGasPercentage,
    @JsonKey(name: 'raw_weight') double rawWeight,
    @JsonKey(name: 'desired_valve_state') String desiredValveState,
    @JsonKey(name: 'current_valve_state') String currentValveState,
    @JsonKey(name: 'desired_alarm_state') String desiredAlarmState,
    @JsonKey(name: 'is_alarm_silenced') bool isAlarmSilenced,
    @JsonKey(name: 'updated_at') DateTime lastUpdate,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'alert_threshold') double? alertThreshold,
  });
}

/// @nodoc
class _$GasSensorCopyWithImpl<$Res, $Val extends GasSensor>
    implements $GasSensorCopyWith<$Res> {
  _$GasSensorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GasSensor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sensorId = null,
    Object? name = null,
    Object? currentLevel = null,
    Object? currentGasPercentage = null,
    Object? rawWeight = null,
    Object? desiredValveState = null,
    Object? currentValveState = null,
    Object? desiredAlarmState = null,
    Object? isAlarmSilenced = null,
    Object? lastUpdate = null,
    Object? isActive = null,
    Object? alertThreshold = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            sensorId: null == sensorId
                ? _value.sensorId
                : sensorId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            currentLevel: null == currentLevel
                ? _value.currentLevel
                : currentLevel // ignore: cast_nullable_to_non_nullable
                      as double,
            currentGasPercentage: null == currentGasPercentage
                ? _value.currentGasPercentage
                : currentGasPercentage // ignore: cast_nullable_to_non_nullable
                      as double,
            rawWeight: null == rawWeight
                ? _value.rawWeight
                : rawWeight // ignore: cast_nullable_to_non_nullable
                      as double,
            desiredValveState: null == desiredValveState
                ? _value.desiredValveState
                : desiredValveState // ignore: cast_nullable_to_non_nullable
                      as String,
            currentValveState: null == currentValveState
                ? _value.currentValveState
                : currentValveState // ignore: cast_nullable_to_non_nullable
                      as String,
            desiredAlarmState: null == desiredAlarmState
                ? _value.desiredAlarmState
                : desiredAlarmState // ignore: cast_nullable_to_non_nullable
                      as String,
            isAlarmSilenced: null == isAlarmSilenced
                ? _value.isAlarmSilenced
                : isAlarmSilenced // ignore: cast_nullable_to_non_nullable
                      as bool,
            lastUpdate: null == lastUpdate
                ? _value.lastUpdate
                : lastUpdate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            alertThreshold: freezed == alertThreshold
                ? _value.alertThreshold
                : alertThreshold // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GasSensorImplCopyWith<$Res>
    implements $GasSensorCopyWith<$Res> {
  factory _$$GasSensorImplCopyWith(
    _$GasSensorImpl value,
    $Res Function(_$GasSensorImpl) then,
  ) = __$$GasSensorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'serial_number') String sensorId,
    @JsonKey(name: 'sensor_name') String name,
    @JsonKey(name: 'current_gas_level') double currentLevel,
    @JsonKey(name: 'current_gas_percentage') double currentGasPercentage,
    @JsonKey(name: 'raw_weight') double rawWeight,
    @JsonKey(name: 'desired_valve_state') String desiredValveState,
    @JsonKey(name: 'current_valve_state') String currentValveState,
    @JsonKey(name: 'desired_alarm_state') String desiredAlarmState,
    @JsonKey(name: 'is_alarm_silenced') bool isAlarmSilenced,
    @JsonKey(name: 'updated_at') DateTime lastUpdate,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'alert_threshold') double? alertThreshold,
  });
}

/// @nodoc
class __$$GasSensorImplCopyWithImpl<$Res>
    extends _$GasSensorCopyWithImpl<$Res, _$GasSensorImpl>
    implements _$$GasSensorImplCopyWith<$Res> {
  __$$GasSensorImplCopyWithImpl(
    _$GasSensorImpl _value,
    $Res Function(_$GasSensorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GasSensor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sensorId = null,
    Object? name = null,
    Object? currentLevel = null,
    Object? currentGasPercentage = null,
    Object? rawWeight = null,
    Object? desiredValveState = null,
    Object? currentValveState = null,
    Object? desiredAlarmState = null,
    Object? isAlarmSilenced = null,
    Object? lastUpdate = null,
    Object? isActive = null,
    Object? alertThreshold = freezed,
  }) {
    return _then(
      _$GasSensorImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        sensorId: null == sensorId
            ? _value.sensorId
            : sensorId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        currentLevel: null == currentLevel
            ? _value.currentLevel
            : currentLevel // ignore: cast_nullable_to_non_nullable
                  as double,
        currentGasPercentage: null == currentGasPercentage
            ? _value.currentGasPercentage
            : currentGasPercentage // ignore: cast_nullable_to_non_nullable
                  as double,
        rawWeight: null == rawWeight
            ? _value.rawWeight
            : rawWeight // ignore: cast_nullable_to_non_nullable
                  as double,
        desiredValveState: null == desiredValveState
            ? _value.desiredValveState
            : desiredValveState // ignore: cast_nullable_to_non_nullable
                  as String,
        currentValveState: null == currentValveState
            ? _value.currentValveState
            : currentValveState // ignore: cast_nullable_to_non_nullable
                  as String,
        desiredAlarmState: null == desiredAlarmState
            ? _value.desiredAlarmState
            : desiredAlarmState // ignore: cast_nullable_to_non_nullable
                  as String,
        isAlarmSilenced: null == isAlarmSilenced
            ? _value.isAlarmSilenced
            : isAlarmSilenced // ignore: cast_nullable_to_non_nullable
                  as bool,
        lastUpdate: null == lastUpdate
            ? _value.lastUpdate
            : lastUpdate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        alertThreshold: freezed == alertThreshold
            ? _value.alertThreshold
            : alertThreshold // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GasSensorImpl implements _GasSensor {
  const _$GasSensorImpl({
    required this.id,
    @JsonKey(name: 'serial_number') required this.sensorId,
    @JsonKey(name: 'sensor_name') required this.name,
    @JsonKey(name: 'current_gas_level') required this.currentLevel,
    @JsonKey(name: 'current_gas_percentage') this.currentGasPercentage = 0.0,
    @JsonKey(name: 'raw_weight') this.rawWeight = 0.0,
    @JsonKey(name: 'desired_valve_state') this.desiredValveState = 'OPEN',
    @JsonKey(name: 'current_valve_state') this.currentValveState = 'OPEN',
    @JsonKey(name: 'desired_alarm_state') this.desiredAlarmState = 'ARM',
    @JsonKey(name: 'is_alarm_silenced') this.isAlarmSilenced = false,
    @JsonKey(name: 'updated_at') required this.lastUpdate,
    @JsonKey(name: 'is_active') required this.isActive,
    @JsonKey(name: 'alert_threshold') this.alertThreshold,
  });

  factory _$GasSensorImpl.fromJson(Map<String, dynamic> json) =>
      _$$GasSensorImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'serial_number')
  final String sensorId;
  @override
  @JsonKey(name: 'sensor_name')
  final String name;
  @override
  @JsonKey(name: 'current_gas_level')
  final double currentLevel;
  @override
  @JsonKey(name: 'current_gas_percentage')
  final double currentGasPercentage;
  @override
  @JsonKey(name: 'raw_weight')
  final double rawWeight;
  @override
  @JsonKey(name: 'desired_valve_state')
  final String desiredValveState;
  @override
  @JsonKey(name: 'current_valve_state')
  final String currentValveState;
  @override
  @JsonKey(name: 'desired_alarm_state')
  final String desiredAlarmState;
  @override
  @JsonKey(name: 'is_alarm_silenced')
  final bool isAlarmSilenced;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime lastUpdate;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'alert_threshold')
  final double? alertThreshold;

  @override
  String toString() {
    return 'GasSensor(id: $id, sensorId: $sensorId, name: $name, currentLevel: $currentLevel, currentGasPercentage: $currentGasPercentage, rawWeight: $rawWeight, desiredValveState: $desiredValveState, currentValveState: $currentValveState, desiredAlarmState: $desiredAlarmState, isAlarmSilenced: $isAlarmSilenced, lastUpdate: $lastUpdate, isActive: $isActive, alertThreshold: $alertThreshold)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GasSensorImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sensorId, sensorId) ||
                other.sensorId == sensorId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.currentLevel, currentLevel) ||
                other.currentLevel == currentLevel) &&
            (identical(other.currentGasPercentage, currentGasPercentage) ||
                other.currentGasPercentage == currentGasPercentage) &&
            (identical(other.rawWeight, rawWeight) ||
                other.rawWeight == rawWeight) &&
            (identical(other.desiredValveState, desiredValveState) ||
                other.desiredValveState == desiredValveState) &&
            (identical(other.currentValveState, currentValveState) ||
                other.currentValveState == currentValveState) &&
            (identical(other.desiredAlarmState, desiredAlarmState) ||
                other.desiredAlarmState == desiredAlarmState) &&
            (identical(other.isAlarmSilenced, isAlarmSilenced) ||
                other.isAlarmSilenced == isAlarmSilenced) &&
            (identical(other.lastUpdate, lastUpdate) ||
                other.lastUpdate == lastUpdate) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.alertThreshold, alertThreshold) ||
                other.alertThreshold == alertThreshold));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    sensorId,
    name,
    currentLevel,
    currentGasPercentage,
    rawWeight,
    desiredValveState,
    currentValveState,
    desiredAlarmState,
    isAlarmSilenced,
    lastUpdate,
    isActive,
    alertThreshold,
  );

  /// Create a copy of GasSensor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GasSensorImplCopyWith<_$GasSensorImpl> get copyWith =>
      __$$GasSensorImplCopyWithImpl<_$GasSensorImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GasSensorImplToJson(this);
  }
}

abstract class _GasSensor implements GasSensor {
  const factory _GasSensor({
    required final int id,
    @JsonKey(name: 'serial_number') required final String sensorId,
    @JsonKey(name: 'sensor_name') required final String name,
    @JsonKey(name: 'current_gas_level') required final double currentLevel,
    @JsonKey(name: 'current_gas_percentage') final double currentGasPercentage,
    @JsonKey(name: 'raw_weight') final double rawWeight,
    @JsonKey(name: 'desired_valve_state') final String desiredValveState,
    @JsonKey(name: 'current_valve_state') final String currentValveState,
    @JsonKey(name: 'desired_alarm_state') final String desiredAlarmState,
    @JsonKey(name: 'is_alarm_silenced') final bool isAlarmSilenced,
    @JsonKey(name: 'updated_at') required final DateTime lastUpdate,
    @JsonKey(name: 'is_active') required final bool isActive,
    @JsonKey(name: 'alert_threshold') final double? alertThreshold,
  }) = _$GasSensorImpl;

  factory _GasSensor.fromJson(Map<String, dynamic> json) =
      _$GasSensorImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'serial_number')
  String get sensorId;
  @override
  @JsonKey(name: 'sensor_name')
  String get name;
  @override
  @JsonKey(name: 'current_gas_level')
  double get currentLevel;
  @override
  @JsonKey(name: 'current_gas_percentage')
  double get currentGasPercentage;
  @override
  @JsonKey(name: 'raw_weight')
  double get rawWeight;
  @override
  @JsonKey(name: 'desired_valve_state')
  String get desiredValveState;
  @override
  @JsonKey(name: 'current_valve_state')
  String get currentValveState;
  @override
  @JsonKey(name: 'desired_alarm_state')
  String get desiredAlarmState;
  @override
  @JsonKey(name: 'is_alarm_silenced')
  bool get isAlarmSilenced;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get lastUpdate;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'alert_threshold')
  double? get alertThreshold;

  /// Create a copy of GasSensor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GasSensorImplCopyWith<_$GasSensorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GasReading _$GasReadingFromJson(Map<String, dynamic> json) {
  return _GasReading.fromJson(json);
}

/// @nodoc
mixin _$GasReading {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'remaining_gas')
  double get gasLevel => throw _privateConstructorUsedError;
  @JsonKey(name: 'reading_timestamp')
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this GasReading to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GasReading
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GasReadingCopyWith<GasReading> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GasReadingCopyWith<$Res> {
  factory $GasReadingCopyWith(
    GasReading value,
    $Res Function(GasReading) then,
  ) = _$GasReadingCopyWithImpl<$Res, GasReading>;
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'remaining_gas') double gasLevel,
    @JsonKey(name: 'reading_timestamp') DateTime timestamp,
  });
}

/// @nodoc
class _$GasReadingCopyWithImpl<$Res, $Val extends GasReading>
    implements $GasReadingCopyWith<$Res> {
  _$GasReadingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GasReading
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? gasLevel = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            gasLevel: null == gasLevel
                ? _value.gasLevel
                : gasLevel // ignore: cast_nullable_to_non_nullable
                      as double,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GasReadingImplCopyWith<$Res>
    implements $GasReadingCopyWith<$Res> {
  factory _$$GasReadingImplCopyWith(
    _$GasReadingImpl value,
    $Res Function(_$GasReadingImpl) then,
  ) = __$$GasReadingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'remaining_gas') double gasLevel,
    @JsonKey(name: 'reading_timestamp') DateTime timestamp,
  });
}

/// @nodoc
class __$$GasReadingImplCopyWithImpl<$Res>
    extends _$GasReadingCopyWithImpl<$Res, _$GasReadingImpl>
    implements _$$GasReadingImplCopyWith<$Res> {
  __$$GasReadingImplCopyWithImpl(
    _$GasReadingImpl _value,
    $Res Function(_$GasReadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GasReading
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? gasLevel = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$GasReadingImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        gasLevel: null == gasLevel
            ? _value.gasLevel
            : gasLevel // ignore: cast_nullable_to_non_nullable
                  as double,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GasReadingImpl implements _GasReading {
  const _$GasReadingImpl({
    required this.id,
    @JsonKey(name: 'remaining_gas') required this.gasLevel,
    @JsonKey(name: 'reading_timestamp') required this.timestamp,
  });

  factory _$GasReadingImpl.fromJson(Map<String, dynamic> json) =>
      _$$GasReadingImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'remaining_gas')
  final double gasLevel;
  @override
  @JsonKey(name: 'reading_timestamp')
  final DateTime timestamp;

  @override
  String toString() {
    return 'GasReading(id: $id, gasLevel: $gasLevel, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GasReadingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.gasLevel, gasLevel) ||
                other.gasLevel == gasLevel) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, gasLevel, timestamp);

  /// Create a copy of GasReading
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GasReadingImplCopyWith<_$GasReadingImpl> get copyWith =>
      __$$GasReadingImplCopyWithImpl<_$GasReadingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GasReadingImplToJson(this);
  }
}

abstract class _GasReading implements GasReading {
  const factory _GasReading({
    required final int id,
    @JsonKey(name: 'remaining_gas') required final double gasLevel,
    @JsonKey(name: 'reading_timestamp') required final DateTime timestamp,
  }) = _$GasReadingImpl;

  factory _GasReading.fromJson(Map<String, dynamic> json) =
      _$GasReadingImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'remaining_gas')
  double get gasLevel;
  @override
  @JsonKey(name: 'reading_timestamp')
  DateTime get timestamp;

  /// Create a copy of GasReading
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GasReadingImplCopyWith<_$GasReadingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PredictionData _$PredictionDataFromJson(Map<String, dynamic> json) {
  return _PredictionData.fromJson(json);
}

/// @nodoc
mixin _$PredictionData {
  @JsonKey(name: 'projected_days')
  double get daysRemaining => throw _privateConstructorUsedError;
  @JsonKey(name: 'expected_depletion_date')
  DateTime? get expectedDepletionDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'confidence')
  double get confidenceScore => throw _privateConstructorUsedError;
  String get trend => throw _privateConstructorUsedError;
  String get recommendation => throw _privateConstructorUsedError;

  /// Serializes this PredictionData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PredictionData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PredictionDataCopyWith<PredictionData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PredictionDataCopyWith<$Res> {
  factory $PredictionDataCopyWith(
    PredictionData value,
    $Res Function(PredictionData) then,
  ) = _$PredictionDataCopyWithImpl<$Res, PredictionData>;
  @useResult
  $Res call({
    @JsonKey(name: 'projected_days') double daysRemaining,
    @JsonKey(name: 'expected_depletion_date') DateTime? expectedDepletionDate,
    @JsonKey(name: 'confidence') double confidenceScore,
    String trend,
    String recommendation,
  });
}

/// @nodoc
class _$PredictionDataCopyWithImpl<$Res, $Val extends PredictionData>
    implements $PredictionDataCopyWith<$Res> {
  _$PredictionDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PredictionData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? daysRemaining = null,
    Object? expectedDepletionDate = freezed,
    Object? confidenceScore = null,
    Object? trend = null,
    Object? recommendation = null,
  }) {
    return _then(
      _value.copyWith(
            daysRemaining: null == daysRemaining
                ? _value.daysRemaining
                : daysRemaining // ignore: cast_nullable_to_non_nullable
                      as double,
            expectedDepletionDate: freezed == expectedDepletionDate
                ? _value.expectedDepletionDate
                : expectedDepletionDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            confidenceScore: null == confidenceScore
                ? _value.confidenceScore
                : confidenceScore // ignore: cast_nullable_to_non_nullable
                      as double,
            trend: null == trend
                ? _value.trend
                : trend // ignore: cast_nullable_to_non_nullable
                      as String,
            recommendation: null == recommendation
                ? _value.recommendation
                : recommendation // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PredictionDataImplCopyWith<$Res>
    implements $PredictionDataCopyWith<$Res> {
  factory _$$PredictionDataImplCopyWith(
    _$PredictionDataImpl value,
    $Res Function(_$PredictionDataImpl) then,
  ) = __$$PredictionDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'projected_days') double daysRemaining,
    @JsonKey(name: 'expected_depletion_date') DateTime? expectedDepletionDate,
    @JsonKey(name: 'confidence') double confidenceScore,
    String trend,
    String recommendation,
  });
}

/// @nodoc
class __$$PredictionDataImplCopyWithImpl<$Res>
    extends _$PredictionDataCopyWithImpl<$Res, _$PredictionDataImpl>
    implements _$$PredictionDataImplCopyWith<$Res> {
  __$$PredictionDataImplCopyWithImpl(
    _$PredictionDataImpl _value,
    $Res Function(_$PredictionDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PredictionData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? daysRemaining = null,
    Object? expectedDepletionDate = freezed,
    Object? confidenceScore = null,
    Object? trend = null,
    Object? recommendation = null,
  }) {
    return _then(
      _$PredictionDataImpl(
        daysRemaining: null == daysRemaining
            ? _value.daysRemaining
            : daysRemaining // ignore: cast_nullable_to_non_nullable
                  as double,
        expectedDepletionDate: freezed == expectedDepletionDate
            ? _value.expectedDepletionDate
            : expectedDepletionDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        confidenceScore: null == confidenceScore
            ? _value.confidenceScore
            : confidenceScore // ignore: cast_nullable_to_non_nullable
                  as double,
        trend: null == trend
            ? _value.trend
            : trend // ignore: cast_nullable_to_non_nullable
                  as String,
        recommendation: null == recommendation
            ? _value.recommendation
            : recommendation // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PredictionDataImpl implements _PredictionData {
  const _$PredictionDataImpl({
    @JsonKey(name: 'projected_days') required this.daysRemaining,
    @JsonKey(name: 'expected_depletion_date') this.expectedDepletionDate,
    @JsonKey(name: 'confidence') required this.confidenceScore,
    required this.trend,
    required this.recommendation,
  });

  factory _$PredictionDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$PredictionDataImplFromJson(json);

  @override
  @JsonKey(name: 'projected_days')
  final double daysRemaining;
  @override
  @JsonKey(name: 'expected_depletion_date')
  final DateTime? expectedDepletionDate;
  @override
  @JsonKey(name: 'confidence')
  final double confidenceScore;
  @override
  final String trend;
  @override
  final String recommendation;

  @override
  String toString() {
    return 'PredictionData(daysRemaining: $daysRemaining, expectedDepletionDate: $expectedDepletionDate, confidenceScore: $confidenceScore, trend: $trend, recommendation: $recommendation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PredictionDataImpl &&
            (identical(other.daysRemaining, daysRemaining) ||
                other.daysRemaining == daysRemaining) &&
            (identical(other.expectedDepletionDate, expectedDepletionDate) ||
                other.expectedDepletionDate == expectedDepletionDate) &&
            (identical(other.confidenceScore, confidenceScore) ||
                other.confidenceScore == confidenceScore) &&
            (identical(other.trend, trend) || other.trend == trend) &&
            (identical(other.recommendation, recommendation) ||
                other.recommendation == recommendation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    daysRemaining,
    expectedDepletionDate,
    confidenceScore,
    trend,
    recommendation,
  );

  /// Create a copy of PredictionData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PredictionDataImplCopyWith<_$PredictionDataImpl> get copyWith =>
      __$$PredictionDataImplCopyWithImpl<_$PredictionDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PredictionDataImplToJson(this);
  }
}

abstract class _PredictionData implements PredictionData {
  const factory _PredictionData({
    @JsonKey(name: 'projected_days') required final double daysRemaining,
    @JsonKey(name: 'expected_depletion_date')
    final DateTime? expectedDepletionDate,
    @JsonKey(name: 'confidence') required final double confidenceScore,
    required final String trend,
    required final String recommendation,
  }) = _$PredictionDataImpl;

  factory _PredictionData.fromJson(Map<String, dynamic> json) =
      _$PredictionDataImpl.fromJson;

  @override
  @JsonKey(name: 'projected_days')
  double get daysRemaining;
  @override
  @JsonKey(name: 'expected_depletion_date')
  DateTime? get expectedDepletionDate;
  @override
  @JsonKey(name: 'confidence')
  double get confidenceScore;
  @override
  String get trend;
  @override
  String get recommendation;

  /// Create a copy of PredictionData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PredictionDataImplCopyWith<_$PredictionDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyConsumption _$DailyConsumptionFromJson(Map<String, dynamic> json) {
  return _DailyConsumption.fromJson(json);
}

/// @nodoc
mixin _$DailyConsumption {
  String get date => throw _privateConstructorUsedError;
  @JsonKey(name: 'consumption_kg')
  double get consumption => throw _privateConstructorUsedError;
  @JsonKey(name: 'avg_remaining_kg')
  double get avgRemaining => throw _privateConstructorUsedError;
  @JsonKey(name: 'gas_percentage')
  double get gasPercentage => throw _privateConstructorUsedError;

  /// Serializes this DailyConsumption to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyConsumption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyConsumptionCopyWith<DailyConsumption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyConsumptionCopyWith<$Res> {
  factory $DailyConsumptionCopyWith(
    DailyConsumption value,
    $Res Function(DailyConsumption) then,
  ) = _$DailyConsumptionCopyWithImpl<$Res, DailyConsumption>;
  @useResult
  $Res call({
    String date,
    @JsonKey(name: 'consumption_kg') double consumption,
    @JsonKey(name: 'avg_remaining_kg') double avgRemaining,
    @JsonKey(name: 'gas_percentage') double gasPercentage,
  });
}

/// @nodoc
class _$DailyConsumptionCopyWithImpl<$Res, $Val extends DailyConsumption>
    implements $DailyConsumptionCopyWith<$Res> {
  _$DailyConsumptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyConsumption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? consumption = null,
    Object? avgRemaining = null,
    Object? gasPercentage = null,
  }) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            consumption: null == consumption
                ? _value.consumption
                : consumption // ignore: cast_nullable_to_non_nullable
                      as double,
            avgRemaining: null == avgRemaining
                ? _value.avgRemaining
                : avgRemaining // ignore: cast_nullable_to_non_nullable
                      as double,
            gasPercentage: null == gasPercentage
                ? _value.gasPercentage
                : gasPercentage // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyConsumptionImplCopyWith<$Res>
    implements $DailyConsumptionCopyWith<$Res> {
  factory _$$DailyConsumptionImplCopyWith(
    _$DailyConsumptionImpl value,
    $Res Function(_$DailyConsumptionImpl) then,
  ) = __$$DailyConsumptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String date,
    @JsonKey(name: 'consumption_kg') double consumption,
    @JsonKey(name: 'avg_remaining_kg') double avgRemaining,
    @JsonKey(name: 'gas_percentage') double gasPercentage,
  });
}

/// @nodoc
class __$$DailyConsumptionImplCopyWithImpl<$Res>
    extends _$DailyConsumptionCopyWithImpl<$Res, _$DailyConsumptionImpl>
    implements _$$DailyConsumptionImplCopyWith<$Res> {
  __$$DailyConsumptionImplCopyWithImpl(
    _$DailyConsumptionImpl _value,
    $Res Function(_$DailyConsumptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyConsumption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? consumption = null,
    Object? avgRemaining = null,
    Object? gasPercentage = null,
  }) {
    return _then(
      _$DailyConsumptionImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        consumption: null == consumption
            ? _value.consumption
            : consumption // ignore: cast_nullable_to_non_nullable
                  as double,
        avgRemaining: null == avgRemaining
            ? _value.avgRemaining
            : avgRemaining // ignore: cast_nullable_to_non_nullable
                  as double,
        gasPercentage: null == gasPercentage
            ? _value.gasPercentage
            : gasPercentage // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyConsumptionImpl implements _DailyConsumption {
  const _$DailyConsumptionImpl({
    required this.date,
    @JsonKey(name: 'consumption_kg') required this.consumption,
    @JsonKey(name: 'avg_remaining_kg') required this.avgRemaining,
    @JsonKey(name: 'gas_percentage') required this.gasPercentage,
  });

  factory _$DailyConsumptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyConsumptionImplFromJson(json);

  @override
  final String date;
  @override
  @JsonKey(name: 'consumption_kg')
  final double consumption;
  @override
  @JsonKey(name: 'avg_remaining_kg')
  final double avgRemaining;
  @override
  @JsonKey(name: 'gas_percentage')
  final double gasPercentage;

  @override
  String toString() {
    return 'DailyConsumption(date: $date, consumption: $consumption, avgRemaining: $avgRemaining, gasPercentage: $gasPercentage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyConsumptionImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.consumption, consumption) ||
                other.consumption == consumption) &&
            (identical(other.avgRemaining, avgRemaining) ||
                other.avgRemaining == avgRemaining) &&
            (identical(other.gasPercentage, gasPercentage) ||
                other.gasPercentage == gasPercentage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, date, consumption, avgRemaining, gasPercentage);

  /// Create a copy of DailyConsumption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyConsumptionImplCopyWith<_$DailyConsumptionImpl> get copyWith =>
      __$$DailyConsumptionImplCopyWithImpl<_$DailyConsumptionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyConsumptionImplToJson(this);
  }
}

abstract class _DailyConsumption implements DailyConsumption {
  const factory _DailyConsumption({
    required final String date,
    @JsonKey(name: 'consumption_kg') required final double consumption,
    @JsonKey(name: 'avg_remaining_kg') required final double avgRemaining,
    @JsonKey(name: 'gas_percentage') required final double gasPercentage,
  }) = _$DailyConsumptionImpl;

  factory _DailyConsumption.fromJson(Map<String, dynamic> json) =
      _$DailyConsumptionImpl.fromJson;

  @override
  String get date;
  @override
  @JsonKey(name: 'consumption_kg')
  double get consumption;
  @override
  @JsonKey(name: 'avg_remaining_kg')
  double get avgRemaining;
  @override
  @JsonKey(name: 'gas_percentage')
  double get gasPercentage;

  /// Create a copy of DailyConsumption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyConsumptionImplCopyWith<_$DailyConsumptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
