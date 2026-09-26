// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GasBottleImpl _$$GasBottleImplFromJson(Map<String, dynamic> json) =>
    _$GasBottleImpl(
      id: (json['id'] as num).toInt(),
      sizeCode: json['size'] as String,
      size: json['size_display'] as String,
      brandCode: json['brand'] as String,
      brand: json['brand_display'] as String,
      price: _parseDouble(json['price']),
      stock: (json['stock_quantity'] as num).toInt(),
    );

Map<String, dynamic> _$$GasBottleImplToJson(_$GasBottleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'size': instance.sizeCode,
      'size_display': instance.size,
      'brand': instance.brandCode,
      'brand_display': instance.brand,
      'price': instance.price,
      'stock_quantity': instance.stock,
    };

_$VendorImpl _$$VendorImplFromJson(Map<String, dynamic> json) => _$VendorImpl(
  id: (json['id'] as num).toInt(),
  userName: json['user_name'] as String,
  storeName: json['store_name'] as String,
  address: json['address'] as String,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  gasBottles: (json['gas_bottles'] as List<dynamic>?)
      ?.map((e) => GasBottle.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$VendorImplToJson(_$VendorImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_name': instance.userName,
      'store_name': instance.storeName,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'gas_bottles': instance.gasBottles,
    };
