// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserAccount _$UserAccountFromJson(Map<String, dynamic> json) {
  return _UserAccount.fromJson(json);
}

/// @nodoc
mixin _$UserAccount {
  int get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'first_name')
  String get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_name')
  String get lastName => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  @JsonKey(name: 'application_status')
  String get applicationStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_image')
  String? get profileImage => throw _privateConstructorUsedError;
  @JsonKey(name: 'preferred_bottle_size')
  String get preferredBottleSize => throw _privateConstructorUsedError;
  @JsonKey(name: 'preferred_bottle_brand')
  String get preferredBottleBrand => throw _privateConstructorUsedError;
  @JsonKey(name: 'tare_weight')
  String get tareWeight => throw _privateConstructorUsedError;
  @JsonKey(name: 'gas_capacity')
  String get gasCapacity => throw _privateConstructorUsedError;

  /// Serializes this UserAccount to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserAccount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserAccountCopyWith<UserAccount> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserAccountCopyWith<$Res> {
  factory $UserAccountCopyWith(
    UserAccount value,
    $Res Function(UserAccount) then,
  ) = _$UserAccountCopyWithImpl<$Res, UserAccount>;
  @useResult
  $Res call({
    int id,
    String email,
    @JsonKey(name: 'first_name') String firstName,
    @JsonKey(name: 'last_name') String lastName,
    String role,
    @JsonKey(name: 'application_status') String applicationStatus,
    @JsonKey(name: 'profile_image') String? profileImage,
    @JsonKey(name: 'preferred_bottle_size') String preferredBottleSize,
    @JsonKey(name: 'preferred_bottle_brand') String preferredBottleBrand,
    @JsonKey(name: 'tare_weight') String tareWeight,
    @JsonKey(name: 'gas_capacity') String gasCapacity,
  });
}

/// @nodoc
class _$UserAccountCopyWithImpl<$Res, $Val extends UserAccount>
    implements $UserAccountCopyWith<$Res> {
  _$UserAccountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserAccount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? role = null,
    Object? applicationStatus = null,
    Object? profileImage = freezed,
    Object? preferredBottleSize = null,
    Object? preferredBottleBrand = null,
    Object? tareWeight = null,
    Object? gasCapacity = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            firstName: null == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                      as String,
            lastName: null == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            applicationStatus: null == applicationStatus
                ? _value.applicationStatus
                : applicationStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            profileImage: freezed == profileImage
                ? _value.profileImage
                : profileImage // ignore: cast_nullable_to_non_nullable
                      as String?,
            preferredBottleSize: null == preferredBottleSize
                ? _value.preferredBottleSize
                : preferredBottleSize // ignore: cast_nullable_to_non_nullable
                      as String,
            preferredBottleBrand: null == preferredBottleBrand
                ? _value.preferredBottleBrand
                : preferredBottleBrand // ignore: cast_nullable_to_non_nullable
                      as String,
            tareWeight: null == tareWeight
                ? _value.tareWeight
                : tareWeight // ignore: cast_nullable_to_non_nullable
                      as String,
            gasCapacity: null == gasCapacity
                ? _value.gasCapacity
                : gasCapacity // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserAccountImplCopyWith<$Res>
    implements $UserAccountCopyWith<$Res> {
  factory _$$UserAccountImplCopyWith(
    _$UserAccountImpl value,
    $Res Function(_$UserAccountImpl) then,
  ) = __$$UserAccountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String email,
    @JsonKey(name: 'first_name') String firstName,
    @JsonKey(name: 'last_name') String lastName,
    String role,
    @JsonKey(name: 'application_status') String applicationStatus,
    @JsonKey(name: 'profile_image') String? profileImage,
    @JsonKey(name: 'preferred_bottle_size') String preferredBottleSize,
    @JsonKey(name: 'preferred_bottle_brand') String preferredBottleBrand,
    @JsonKey(name: 'tare_weight') String tareWeight,
    @JsonKey(name: 'gas_capacity') String gasCapacity,
  });
}

/// @nodoc
class __$$UserAccountImplCopyWithImpl<$Res>
    extends _$UserAccountCopyWithImpl<$Res, _$UserAccountImpl>
    implements _$$UserAccountImplCopyWith<$Res> {
  __$$UserAccountImplCopyWithImpl(
    _$UserAccountImpl _value,
    $Res Function(_$UserAccountImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserAccount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? role = null,
    Object? applicationStatus = null,
    Object? profileImage = freezed,
    Object? preferredBottleSize = null,
    Object? preferredBottleBrand = null,
    Object? tareWeight = null,
    Object? gasCapacity = null,
  }) {
    return _then(
      _$UserAccountImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        firstName: null == firstName
            ? _value.firstName
            : firstName // ignore: cast_nullable_to_non_nullable
                  as String,
        lastName: null == lastName
            ? _value.lastName
            : lastName // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        applicationStatus: null == applicationStatus
            ? _value.applicationStatus
            : applicationStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        profileImage: freezed == profileImage
            ? _value.profileImage
            : profileImage // ignore: cast_nullable_to_non_nullable
                  as String?,
        preferredBottleSize: null == preferredBottleSize
            ? _value.preferredBottleSize
            : preferredBottleSize // ignore: cast_nullable_to_non_nullable
                  as String,
        preferredBottleBrand: null == preferredBottleBrand
            ? _value.preferredBottleBrand
            : preferredBottleBrand // ignore: cast_nullable_to_non_nullable
                  as String,
        tareWeight: null == tareWeight
            ? _value.tareWeight
            : tareWeight // ignore: cast_nullable_to_non_nullable
                  as String,
        gasCapacity: null == gasCapacity
            ? _value.gasCapacity
            : gasCapacity // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserAccountImpl implements _UserAccount {
  const _$UserAccountImpl({
    required this.id,
    required this.email,
    @JsonKey(name: 'first_name') required this.firstName,
    @JsonKey(name: 'last_name') required this.lastName,
    this.role = 'client',
    @JsonKey(name: 'application_status') this.applicationStatus = 'approved',
    @JsonKey(name: 'profile_image') this.profileImage,
    @JsonKey(name: 'preferred_bottle_size')
    this.preferredBottleSize = 'MEDIUM_12_5KG',
    @JsonKey(name: 'preferred_bottle_brand')
    this.preferredBottleBrand = 'TOTAL_ENERGIES',
    @JsonKey(name: 'tare_weight') this.tareWeight = '12.50',
    @JsonKey(name: 'gas_capacity') this.gasCapacity = '12.50',
  });

  factory _$UserAccountImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserAccountImplFromJson(json);

  @override
  final int id;
  @override
  final String email;
  @override
  @JsonKey(name: 'first_name')
  final String firstName;
  @override
  @JsonKey(name: 'last_name')
  final String lastName;
  @override
  @JsonKey()
  final String role;
  @override
  @JsonKey(name: 'application_status')
  final String applicationStatus;
  @override
  @JsonKey(name: 'profile_image')
  final String? profileImage;
  @override
  @JsonKey(name: 'preferred_bottle_size')
  final String preferredBottleSize;
  @override
  @JsonKey(name: 'preferred_bottle_brand')
  final String preferredBottleBrand;
  @override
  @JsonKey(name: 'tare_weight')
  final String tareWeight;
  @override
  @JsonKey(name: 'gas_capacity')
  final String gasCapacity;

  @override
  String toString() {
    return 'UserAccount(id: $id, email: $email, firstName: $firstName, lastName: $lastName, role: $role, applicationStatus: $applicationStatus, profileImage: $profileImage, preferredBottleSize: $preferredBottleSize, preferredBottleBrand: $preferredBottleBrand, tareWeight: $tareWeight, gasCapacity: $gasCapacity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserAccountImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.applicationStatus, applicationStatus) ||
                other.applicationStatus == applicationStatus) &&
            (identical(other.profileImage, profileImage) ||
                other.profileImage == profileImage) &&
            (identical(other.preferredBottleSize, preferredBottleSize) ||
                other.preferredBottleSize == preferredBottleSize) &&
            (identical(other.preferredBottleBrand, preferredBottleBrand) ||
                other.preferredBottleBrand == preferredBottleBrand) &&
            (identical(other.tareWeight, tareWeight) ||
                other.tareWeight == tareWeight) &&
            (identical(other.gasCapacity, gasCapacity) ||
                other.gasCapacity == gasCapacity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    email,
    firstName,
    lastName,
    role,
    applicationStatus,
    profileImage,
    preferredBottleSize,
    preferredBottleBrand,
    tareWeight,
    gasCapacity,
  );

  /// Create a copy of UserAccount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserAccountImplCopyWith<_$UserAccountImpl> get copyWith =>
      __$$UserAccountImplCopyWithImpl<_$UserAccountImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserAccountImplToJson(this);
  }
}

abstract class _UserAccount implements UserAccount {
  const factory _UserAccount({
    required final int id,
    required final String email,
    @JsonKey(name: 'first_name') required final String firstName,
    @JsonKey(name: 'last_name') required final String lastName,
    final String role,
    @JsonKey(name: 'application_status') final String applicationStatus,
    @JsonKey(name: 'profile_image') final String? profileImage,
    @JsonKey(name: 'preferred_bottle_size') final String preferredBottleSize,
    @JsonKey(name: 'preferred_bottle_brand') final String preferredBottleBrand,
    @JsonKey(name: 'tare_weight') final String tareWeight,
    @JsonKey(name: 'gas_capacity') final String gasCapacity,
  }) = _$UserAccountImpl;

  factory _UserAccount.fromJson(Map<String, dynamic> json) =
      _$UserAccountImpl.fromJson;

  @override
  int get id;
  @override
  String get email;
  @override
  @JsonKey(name: 'first_name')
  String get firstName;
  @override
  @JsonKey(name: 'last_name')
  String get lastName;
  @override
  String get role;
  @override
  @JsonKey(name: 'application_status')
  String get applicationStatus;
  @override
  @JsonKey(name: 'profile_image')
  String? get profileImage;
  @override
  @JsonKey(name: 'preferred_bottle_size')
  String get preferredBottleSize;
  @override
  @JsonKey(name: 'preferred_bottle_brand')
  String get preferredBottleBrand;
  @override
  @JsonKey(name: 'tare_weight')
  String get tareWeight;
  @override
  @JsonKey(name: 'gas_capacity')
  String get gasCapacity;

  /// Create a copy of UserAccount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserAccountImplCopyWith<_$UserAccountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) {
  return _AuthResponse.fromJson(json);
}

/// @nodoc
mixin _$AuthResponse {
  String get token => throw _privateConstructorUsedError;
  UserAccount get user => throw _privateConstructorUsedError;

  /// Serializes this AuthResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthResponseCopyWith<AuthResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthResponseCopyWith<$Res> {
  factory $AuthResponseCopyWith(
    AuthResponse value,
    $Res Function(AuthResponse) then,
  ) = _$AuthResponseCopyWithImpl<$Res, AuthResponse>;
  @useResult
  $Res call({String token, UserAccount user});

  $UserAccountCopyWith<$Res> get user;
}

/// @nodoc
class _$AuthResponseCopyWithImpl<$Res, $Val extends AuthResponse>
    implements $AuthResponseCopyWith<$Res> {
  _$AuthResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? token = null, Object? user = null}) {
    return _then(
      _value.copyWith(
            token: null == token
                ? _value.token
                : token // ignore: cast_nullable_to_non_nullable
                      as String,
            user: null == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as UserAccount,
          )
          as $Val,
    );
  }

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserAccountCopyWith<$Res> get user {
    return $UserAccountCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AuthResponseImplCopyWith<$Res>
    implements $AuthResponseCopyWith<$Res> {
  factory _$$AuthResponseImplCopyWith(
    _$AuthResponseImpl value,
    $Res Function(_$AuthResponseImpl) then,
  ) = __$$AuthResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String token, UserAccount user});

  @override
  $UserAccountCopyWith<$Res> get user;
}

/// @nodoc
class __$$AuthResponseImplCopyWithImpl<$Res>
    extends _$AuthResponseCopyWithImpl<$Res, _$AuthResponseImpl>
    implements _$$AuthResponseImplCopyWith<$Res> {
  __$$AuthResponseImplCopyWithImpl(
    _$AuthResponseImpl _value,
    $Res Function(_$AuthResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? token = null, Object? user = null}) {
    return _then(
      _$AuthResponseImpl(
        token: null == token
            ? _value.token
            : token // ignore: cast_nullable_to_non_nullable
                  as String,
        user: null == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as UserAccount,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthResponseImpl implements _AuthResponse {
  const _$AuthResponseImpl({required this.token, required this.user});

  factory _$AuthResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthResponseImplFromJson(json);

  @override
  final String token;
  @override
  final UserAccount user;

  @override
  String toString() {
    return 'AuthResponse(token: $token, user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthResponseImpl &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.user, user) || other.user == user));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, token, user);

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthResponseImplCopyWith<_$AuthResponseImpl> get copyWith =>
      __$$AuthResponseImplCopyWithImpl<_$AuthResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthResponseImplToJson(this);
  }
}

abstract class _AuthResponse implements AuthResponse {
  const factory _AuthResponse({
    required final String token,
    required final UserAccount user,
  }) = _$AuthResponseImpl;

  factory _AuthResponse.fromJson(Map<String, dynamic> json) =
      _$AuthResponseImpl.fromJson;

  @override
  String get token;
  @override
  UserAccount get user;

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthResponseImplCopyWith<_$AuthResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
