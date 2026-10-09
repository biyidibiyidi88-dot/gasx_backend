import 'dart:typed_data';

import 'package:dio/dio.dart';
import '../models/vendor_models.dart';

class VendorRepository {
  final Dio _dio;

  VendorRepository(this._dio);

  Future<List<Vendor>> getVendors() async {
    try {
      final response = await _dio.get('public/vendors/');
      return (response.data as List)
          .map((v) => Vendor.fromJson(Map<String, dynamic>.from(v)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> initiatePayment({
    required int bottleId,
    required String fulfillmentMethod,
    required String paymentOperator,
    required String payerPhone,
    String? deliveryAddress,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _dio.post(
      'payments/initiate/',
      data: {
        'gas_bottle': bottleId,
        'fulfillment_method': fulfillmentMethod,
        'payment_operator': paymentOperator,
        'payer_phone': payerPhone,
        if (fulfillmentMethod == 'DELIVERY')
          'delivery_address': deliveryAddress,
        if (fulfillmentMethod == 'DELIVERY' && latitude != null)
          'latitude': latitude,
        if (fulfillmentMethod == 'DELIVERY' && longitude != null)
          'longitude': longitude,
      },
    );
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> checkPaymentStatus(int orderId) async {
    final response = await _dio.post('payments/$orderId/status/');
    return Map<String, dynamic>.from(response.data);
  }

  Future<Uint8List> downloadInvoice(int orderId) async {
    final response = await _dio.get(
      'payments/$orderId/invoice/',
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(List<int>.from(response.data as List));
  }

  Future<List<Map<String, dynamic>>> getMyInventory() async {
    final response = await _dio.get('vendor/gas-bottles/');
    return (response.data as List)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<Map<String, dynamic>> getMySupplierProfile() async {
    final response = await _dio.get('vendor/profile/');
    return Map<String, dynamic>.from(response.data);
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    final response = await _dio.get('deliveries/');
    return (response.data as List)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<Map<String, dynamic>> updateOrder(int id, String status) async {
    final response = await _dio.patch(
      'deliveries/$id/',
      data: {'status': status},
    );
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> confirmDelivery(int id, String role) async {
    final response = await _dio.patch(
      'deliveries/$id/',
      data: {'completion_confirmation': role},
    );
    return Map<String, dynamic>.from(response.data);
  }

  Future<void> addBottle({
    required String brand,
    required String size,
    required double price,
    required int stock,
  }) async {
    await _dio.post(
      'vendor/gas-bottles/',
      data: {
        'brand': brand,
        'size': size,
        'price': price,
        'stock_quantity': stock,
      },
    );
  }

  Future<void> updateBottle({
    required int id,
    required double price,
    required int stock,
  }) async {
    await _dio.patch(
      'vendor/gas-bottles/$id/',
      data: {'price': price, 'stock_quantity': stock},
    );
  }
}
