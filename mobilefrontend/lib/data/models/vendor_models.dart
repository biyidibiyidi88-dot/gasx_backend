import 'package:freezed_annotation/freezed_annotation.dart';

part 'vendor_models.freezed.dart';
part 'vendor_models.g.dart';

double _parseDouble(dynamic value) {
  if (value is String) return double.parse(value);
  return (value as num).toDouble();
}

@freezed
class GasBottle with _$GasBottle {
  const factory GasBottle({
    required int id,
    @JsonKey(name: 'size') required String sizeCode,
    @JsonKey(name: 'size_display') required String size,
    @JsonKey(name: 'brand') required String brandCode,
    @JsonKey(name: 'brand_display') required String brand,
    @JsonKey(fromJson: _parseDouble) required double price,
    @JsonKey(name: 'stock_quantity') required int stock,
  }) = _GasBottle;

  factory GasBottle.fromJson(Map<String, dynamic> json) =>
      _$GasBottleFromJson(json);
}

@freezed
class Vendor with _$Vendor {
  const factory Vendor({
    required int id,
    @JsonKey(name: 'user_name') required String userName,
    @JsonKey(name: 'store_name') required String storeName,
    required String address,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'gas_bottles') List<GasBottle>? gasBottles,
  }) = _Vendor;

  factory Vendor.fromJson(Map<String, dynamic> json) => _$VendorFromJson(json);
}
