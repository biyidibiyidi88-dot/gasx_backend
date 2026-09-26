// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vendor_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GasBottle _$GasBottleFromJson(Map<String, dynamic> json) {
  return _GasBottle.fromJson(json);
}

/// @nodoc
mixin _$GasBottle {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'size')
  String get sizeCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'size_display')
  String get size => throw _privateConstructorUsedError;
  @JsonKey(name: 'brand')
  String get brandCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'brand_display')
  String get brand => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseDouble)
  double get price => throw _privateConstructorUsedError;
  @JsonKey(name: 'stock_quantity')
  int get stock => throw _privateConstructorUsedError;

  /// Serializes this GasBottle to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GasBottle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GasBottleCopyWith<GasBottle> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GasBottleCopyWith<$Res> {
  factory $GasBottleCopyWith(GasBottle value, $Res Function(GasBottle) then) =
      _$GasBottleCopyWithImpl<$Res, GasBottle>;
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'size') String sizeCode,
    @JsonKey(name: 'size_display') String size,
    @JsonKey(name: 'brand') String brandCode,
    @JsonKey(name: 'brand_display') String brand,
    @JsonKey(fromJson: _parseDouble) double price,
    @JsonKey(name: 'stock_quantity') int stock,
  });
}

/// @nodoc
class _$GasBottleCopyWithImpl<$Res, $Val extends GasBottle>
    implements $GasBottleCopyWith<$Res> {
  _$GasBottleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GasBottle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sizeCode = null,
    Object? size = null,
    Object? brandCode = null,
    Object? brand = null,
    Object? price = null,
    Object? stock = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            sizeCode: null == sizeCode
                ? _value.sizeCode
                : sizeCode // ignore: cast_nullable_to_non_nullable
                      as String,
            size: null == size
                ? _value.size
                : size // ignore: cast_nullable_to_non_nullable
                      as String,
            brandCode: null == brandCode
                ? _value.brandCode
                : brandCode // ignore: cast_nullable_to_non_nullable
                      as String,
            brand: null == brand
                ? _value.brand
                : brand // ignore: cast_nullable_to_non_nullable
                      as String,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            stock: null == stock
                ? _value.stock
                : stock // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GasBottleImplCopyWith<$Res>
    implements $GasBottleCopyWith<$Res> {
  factory _$$GasBottleImplCopyWith(
    _$GasBottleImpl value,
    $Res Function(_$GasBottleImpl) then,
  ) = __$$GasBottleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'size') String sizeCode,
    @JsonKey(name: 'size_display') String size,
    @JsonKey(name: 'brand') String brandCode,
    @JsonKey(name: 'brand_display') String brand,
    @JsonKey(fromJson: _parseDouble) double price,
    @JsonKey(name: 'stock_quantity') int stock,
  });
}

/// @nodoc
class __$$GasBottleImplCopyWithImpl<$Res>
    extends _$GasBottleCopyWithImpl<$Res, _$GasBottleImpl>
    implements _$$GasBottleImplCopyWith<$Res> {
  __$$GasBottleImplCopyWithImpl(
    _$GasBottleImpl _value,
    $Res Function(_$GasBottleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GasBottle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sizeCode = null,
    Object? size = null,
    Object? brandCode = null,
    Object? brand = null,
    Object? price = null,
    Object? stock = null,
  }) {
    return _then(
      _$GasBottleImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        sizeCode: null == sizeCode
            ? _value.sizeCode
            : sizeCode // ignore: cast_nullable_to_non_nullable
                  as String,
        size: null == size
            ? _value.size
            : size // ignore: cast_nullable_to_non_nullable
                  as String,
        brandCode: null == brandCode
            ? _value.brandCode
            : brandCode // ignore: cast_nullable_to_non_nullable
                  as String,
        brand: null == brand
            ? _value.brand
            : brand // ignore: cast_nullable_to_non_nullable
                  as String,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        stock: null == stock
            ? _value.stock
            : stock // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GasBottleImpl implements _GasBottle {
  const _$GasBottleImpl({
    required this.id,
    @JsonKey(name: 'size') required this.sizeCode,
    @JsonKey(name: 'size_display') required this.size,
    @JsonKey(name: 'brand') required this.brandCode,
    @JsonKey(name: 'brand_display') required this.brand,
    @JsonKey(fromJson: _parseDouble) required this.price,
    @JsonKey(name: 'stock_quantity') required this.stock,
  });

  factory _$GasBottleImpl.fromJson(Map<String, dynamic> json) =>
      _$$GasBottleImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'size')
  final String sizeCode;
  @override
  @JsonKey(name: 'size_display')
  final String size;
  @override
  @JsonKey(name: 'brand')
  final String brandCode;
  @override
  @JsonKey(name: 'brand_display')
  final String brand;
  @override
  @JsonKey(fromJson: _parseDouble)
  final double price;
  @override
  @JsonKey(name: 'stock_quantity')
  final int stock;

  @override
  String toString() {
    return 'GasBottle(id: $id, sizeCode: $sizeCode, size: $size, brandCode: $brandCode, brand: $brand, price: $price, stock: $stock)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GasBottleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sizeCode, sizeCode) ||
                other.sizeCode == sizeCode) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.brandCode, brandCode) ||
                other.brandCode == brandCode) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.stock, stock) || other.stock == stock));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    sizeCode,
    size,
    brandCode,
    brand,
    price,
    stock,
  );

  /// Create a copy of GasBottle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GasBottleImplCopyWith<_$GasBottleImpl> get copyWith =>
      __$$GasBottleImplCopyWithImpl<_$GasBottleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GasBottleImplToJson(this);
  }
}

abstract class _GasBottle implements GasBottle {
  const factory _GasBottle({
    required final int id,
    @JsonKey(name: 'size') required final String sizeCode,
    @JsonKey(name: 'size_display') required final String size,
    @JsonKey(name: 'brand') required final String brandCode,
    @JsonKey(name: 'brand_display') required final String brand,
    @JsonKey(fromJson: _parseDouble) required final double price,
    @JsonKey(name: 'stock_quantity') required final int stock,
  }) = _$GasBottleImpl;

  factory _GasBottle.fromJson(Map<String, dynamic> json) =
      _$GasBottleImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'size')
  String get sizeCode;
  @override
  @JsonKey(name: 'size_display')
  String get size;
  @override
  @JsonKey(name: 'brand')
  String get brandCode;
  @override
  @JsonKey(name: 'brand_display')
  String get brand;
  @override
  @JsonKey(fromJson: _parseDouble)
  double get price;
  @override
  @JsonKey(name: 'stock_quantity')
  int get stock;

  /// Create a copy of GasBottle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GasBottleImplCopyWith<_$GasBottleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Vendor _$VendorFromJson(Map<String, dynamic> json) {
  return _Vendor.fromJson(json);
}

/// @nodoc
mixin _$Vendor {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_name')
  String get userName => throw _privateConstructorUsedError;
  @JsonKey(name: 'store_name')
  String get storeName => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'gas_bottles')
  List<GasBottle>? get gasBottles => throw _privateConstructorUsedError;

  /// Serializes this Vendor to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Vendor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VendorCopyWith<Vendor> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VendorCopyWith<$Res> {
  factory $VendorCopyWith(Vendor value, $Res Function(Vendor) then) =
      _$VendorCopyWithImpl<$Res, Vendor>;
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'user_name') String userName,
    @JsonKey(name: 'store_name') String storeName,
    String address,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'gas_bottles') List<GasBottle>? gasBottles,
  });
}

/// @nodoc
class _$VendorCopyWithImpl<$Res, $Val extends Vendor>
    implements $VendorCopyWith<$Res> {
  _$VendorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Vendor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userName = null,
    Object? storeName = null,
    Object? address = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? gasBottles = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            storeName: null == storeName
                ? _value.storeName
                : storeName // ignore: cast_nullable_to_non_nullable
                      as String,
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            gasBottles: freezed == gasBottles
                ? _value.gasBottles
                : gasBottles // ignore: cast_nullable_to_non_nullable
                      as List<GasBottle>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VendorImplCopyWith<$Res> implements $VendorCopyWith<$Res> {
  factory _$$VendorImplCopyWith(
    _$VendorImpl value,
    $Res Function(_$VendorImpl) then,
  ) = __$$VendorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'user_name') String userName,
    @JsonKey(name: 'store_name') String storeName,
    String address,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'gas_bottles') List<GasBottle>? gasBottles,
  });
}

/// @nodoc
class __$$VendorImplCopyWithImpl<$Res>
    extends _$VendorCopyWithImpl<$Res, _$VendorImpl>
    implements _$$VendorImplCopyWith<$Res> {
  __$$VendorImplCopyWithImpl(
    _$VendorImpl _value,
    $Res Function(_$VendorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Vendor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userName = null,
    Object? storeName = null,
    Object? address = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? gasBottles = freezed,
  }) {
    return _then(
      _$VendorImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        storeName: null == storeName
            ? _value.storeName
            : storeName // ignore: cast_nullable_to_non_nullable
                  as String,
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        gasBottles: freezed == gasBottles
            ? _value._gasBottles
            : gasBottles // ignore: cast_nullable_to_non_nullable
                  as List<GasBottle>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VendorImpl implements _Vendor {
  const _$VendorImpl({
    required this.id,
    @JsonKey(name: 'user_name') required this.userName,
    @JsonKey(name: 'store_name') required this.storeName,
    required this.address,
    this.latitude,
    this.longitude,
    @JsonKey(name: 'gas_bottles') final List<GasBottle>? gasBottles,
  }) : _gasBottles = gasBottles;

  factory _$VendorImpl.fromJson(Map<String, dynamic> json) =>
      _$$VendorImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'user_name')
  final String userName;
  @override
  @JsonKey(name: 'store_name')
  final String storeName;
  @override
  final String address;
  @override
  final double? latitude;
  @override
  final double? longitude;
  final List<GasBottle>? _gasBottles;
  @override
  @JsonKey(name: 'gas_bottles')
  List<GasBottle>? get gasBottles {
    final value = _gasBottles;
    if (value == null) return null;
    if (_gasBottles is EqualUnmodifiableListView) return _gasBottles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'Vendor(id: $id, userName: $userName, storeName: $storeName, address: $address, latitude: $latitude, longitude: $longitude, gasBottles: $gasBottles)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VendorImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.storeName, storeName) ||
                other.storeName == storeName) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            const DeepCollectionEquality().equals(
              other._gasBottles,
              _gasBottles,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userName,
    storeName,
    address,
    latitude,
    longitude,
    const DeepCollectionEquality().hash(_gasBottles),
  );

  /// Create a copy of Vendor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VendorImplCopyWith<_$VendorImpl> get copyWith =>
      __$$VendorImplCopyWithImpl<_$VendorImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VendorImplToJson(this);
  }
}

abstract class _Vendor implements Vendor {
  const factory _Vendor({
    required final int id,
    @JsonKey(name: 'user_name') required final String userName,
    @JsonKey(name: 'store_name') required final String storeName,
    required final String address,
    final double? latitude,
    final double? longitude,
    @JsonKey(name: 'gas_bottles') final List<GasBottle>? gasBottles,
  }) = _$VendorImpl;

  factory _Vendor.fromJson(Map<String, dynamic> json) = _$VendorImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'user_name')
  String get userName;
  @override
  @JsonKey(name: 'store_name')
  String get storeName;
  @override
  String get address;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  @JsonKey(name: 'gas_bottles')
  List<GasBottle>? get gasBottles;

  /// Create a copy of Vendor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VendorImplCopyWith<_$VendorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
