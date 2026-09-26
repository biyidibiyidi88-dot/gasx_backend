// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserAccountImpl _$$UserAccountImplFromJson(Map<String, dynamic> json) =>
    _$UserAccountImpl(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      role: json['role'] as String? ?? 'client',
      applicationStatus: json['application_status'] as String? ?? 'approved',
      profileImage: json['profile_image'] as String?,
      preferredBottleSize:
          json['preferred_bottle_size'] as String? ?? 'MEDIUM_12_5KG',
      preferredBottleBrand:
          json['preferred_bottle_brand'] as String? ?? 'TOTAL_ENERGIES',
      tareWeight: json['tare_weight'] as String? ?? '12.50',
      gasCapacity: json['gas_capacity'] as String? ?? '12.50',
    );

Map<String, dynamic> _$$UserAccountImplToJson(_$UserAccountImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'role': instance.role,
      'application_status': instance.applicationStatus,
      'profile_image': instance.profileImage,
      'preferred_bottle_size': instance.preferredBottleSize,
      'preferred_bottle_brand': instance.preferredBottleBrand,
      'tare_weight': instance.tareWeight,
      'gas_capacity': instance.gasCapacity,
    };

_$AuthResponseImpl _$$AuthResponseImplFromJson(Map<String, dynamic> json) =>
    _$AuthResponseImpl(
      token: json['token'] as String,
      user: UserAccount.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AuthResponseImplToJson(_$AuthResponseImpl instance) =>
    <String, dynamic>{'token': instance.token, 'user': instance.user};
