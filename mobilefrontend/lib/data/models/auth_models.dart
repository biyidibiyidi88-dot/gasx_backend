import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

@freezed
class UserAccount with _$UserAccount {
  const factory UserAccount({
    required int id,
    required String email,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    @Default('client') String role,
    @JsonKey(name: 'application_status')
    @Default('approved')
    String applicationStatus,
    @JsonKey(name: 'profile_image') String? profileImage,
    @Default('MEDIUM_12_5KG')
    @JsonKey(name: 'preferred_bottle_size')
    String preferredBottleSize,
    @Default('TOTAL_ENERGIES')
    @JsonKey(name: 'preferred_bottle_brand')
    String preferredBottleBrand,
    @Default('12.50') @JsonKey(name: 'tare_weight') String tareWeight,
    @Default('12.50') @JsonKey(name: 'gas_capacity') String gasCapacity,
  }) = _UserAccount;

  factory UserAccount.fromJson(Map<String, dynamic> json) =>
      _$UserAccountFromJson(json);
}

@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required String token,
    required UserAccount user,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}
