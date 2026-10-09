import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/location/current_device_location.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/providers/auth_provider.dart';
import '../../domain/providers/vendor_provider.dart';

class DeliveryWorkspaceScreen extends ConsumerStatefulWidget {
  const DeliveryWorkspaceScreen({super.key});

  @override
  ConsumerState<DeliveryWorkspaceScreen> createState() =>
      _DeliveryWorkspaceScreenState();
}

class _DeliveryWorkspaceScreenState
    extends ConsumerState<DeliveryWorkspaceScreen> {
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;
  String? _error;
  int? _updatingId;
  int? _checkingPaymentId;

  bool get _isSupplier =>
      ref.read(authStateProvider).user?.role == 'gas_supplier';
  bool get _isDriver =>
      ref.read(authStateProvider).user?.role == 'delivery_person';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _orders = await ref.read(vendorRepositoryProvider).getOrders();
    } catch (error) {
      _error = error is DioException
          ? (error.response?.data?['detail'] ??
                    'Could not load orders for this account.')
                .toString()
          : 'Could not load orders for this account.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _update(Map<String, dynamic> order, String status) async {
    final id = order['id'] as int;
    setState(() => _updatingId = id);
    try {
      final updated = await ref
          .read(vendorRepositoryProvider)
          .updateOrder(id, status);
      final index = _orders.indexWhere((item) => item['id'] == id);
      if (index >= 0) _orders[index] = updated;
      if (mounted) setState(() {});
    } catch (error) {
      if (mounted) {
        final message = error is DioException
            ? (error.response?.data?['error'] ?? 'Could not update this order.')
                  .toString()
            : 'Could not update this order.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _updatingId = null);
    }
  }

  Future<void> _checkPayment(Map<String, dynamic> order) async {
    final id = order['id'] as int;
    setState(() => _checkingPaymentId = id);
    try {
      final response = await ref
          .read(vendorRepositoryProvider)
          .checkPaymentStatus(id);
      if (!mounted) return;
      final updatedOrder = response['order'];
      if (updatedOrder is Map) {
        final index = _orders.indexWhere((item) => item['id'] == id);
        if (index >= 0) {
          _orders[index] = Map<String, dynamic>.from(updatedOrder);
        }
        setState(() {});
      } else {
        order['payment_status'] = response['payment_status'];
        if (response['message'] != null) {
          _error = response['message'].toString();
        }
        setState(() {});
        if (response['payment_status'] == 'FAILED') await _loadOrders();
      }
    } catch (error) {
      if (mounted) {
        final data = error is DioException ? error.response?.data : null;
        _error = data is Map
            ? (data['message'] ??
                      data['detail'] ??
                      'Could not check payment status.')
                  .toString()
            : 'Could not check payment status.';
        setState(() {});
      }
    } finally {
      if (mounted) setState(() => _checkingPaymentId = null);
    }
  }

  Future<void> _downloadInvoice(int orderId) async {
    try {
      final bytes = await ref
          .read(vendorRepositoryProvider)
          .downloadInvoice(orderId);
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'GasX-Invoice-$orderId.pdf',
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not download the invoice. Try again.')),
      );
    }
  }

  Future<void> _confirmDelivery(Map<String, dynamic> order, String role) async {
    final id = order['id'] as int;
    setState(() => _updatingId = id);
    try {
      final updated = await ref
          .read(vendorRepositoryProvider)
          .confirmDelivery(id, role);
      final index = _orders.indexWhere((item) => item['id'] == id);
      if (index >= 0) _orders[index] = updated;
      if (mounted) {
        setState(() {});
        if (updated['status'] == 'DELIVERED') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Delivery completed and confirmed by both sides.'),
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        final message = error is DioException
            ? (error.response?.data?['error'] ?? 'Could not confirm delivery.')
                  .toString()
            : 'Could not confirm delivery.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _updatingId = null);
    }
  }

  Future<void> _openCustomerRoute(Map<String, dynamic> order) async {
    final latitude = double.tryParse(order['latitude']?.toString() ?? '');
    final longitude = double.tryParse(order['longitude']?.toString() ?? '');
    final address = order['delivery_address']?.toString().trim() ?? '';
    if ((latitude == null || longitude == null) && address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This order has no GPS coordinates or delivery address.',
          ),
        ),
      );
      return;
    }

    try {
      final current = await getCurrentDevicePosition();
      final uri = Uri.https('www.google.com', '/maps/dir/', {
        'api': '1',
        'origin': '${current.latitude},${current.longitude}',
        'destination': latitude != null && longitude != null
            ? '$latitude,$longitude'
            : address,
        'travelmode': 'driving',
      });
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not open navigation on this device.');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    final applicationStatus =
        user?.applicationStatus.toLowerCase() ?? 'approved';
    final title = _isSupplier
        ? 'SUPPLIER ORDERS'
        : _isDriver
        ? 'DELIVERY ORDERS'
        : 'MY ORDERS';
    if ((_isSupplier || _isDriver) && applicationStatus != 'approved') {
      return Scaffold(
        appBar: AppBar(title: Text(title), backgroundColor: Colors.transparent),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.hourglass_top, size: 44, color: Colors.amber),
                const SizedBox(height: 18),
                Text(
                  'ACCOUNT ${applicationStatus.toUpperCase()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'An admin must approve your account before you can manage orders.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w900,
          ),
        ),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(onPressed: _loadOrders, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!, textAlign: TextAlign.center))
          : _orders.isEmpty
          ? const Center(
              child: Text(
                'No gas orders yet.',
                style: TextStyle(color: Colors.white54),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadOrders,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _orders.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _orderCard(_orders[index]),
              ),
            ),
    );
  }

  Widget _orderCard(Map<String, dynamic> order) {
    final status = order['status']?.toString() ?? '';
    final fulfillment = order['fulfillment_method']?.toString() ?? 'DELIVERY';
    final isPickup = fulfillment == 'PICKUP';
    final paymentStatus = order['payment_status']?.toString() ?? 'PAID';
    final hasProviderTransaction =
        (order['payment_transaction_id']?.toString() ?? '').isNotEmpty;
    final paymentAmount = double.tryParse(
      order['payment_amount']?.toString() ?? '',
    );
    final totalPrice = paymentAmount != null && paymentAmount > 0
        ? paymentAmount.toStringAsFixed(0)
        : order['unit_price']?.toString() ?? '';
    String? nextStatus;
    String action = '';
    if (_isDriver &&
        !isPickup &&
        status == 'PENDING' &&
        order['delivery_person'] == null) {
      nextStatus = 'ASSIGNED';
      action = 'ACCEPT ORDER';
    }
    if (_isDriver && !isPickup && status == 'ASSIGNED') {
      nextStatus = 'OUT_FOR_DELIVERY';
      action = 'START DELIVERY';
    }
    if (_isSupplier && isPickup && status == 'PENDING') {
      nextStatus = 'READY_FOR_PICKUP';
      action = 'MARK READY FOR PICKUP';
    }
    if (_isSupplier && isPickup && status == 'READY_FOR_PICKUP') {
      nextStatus = 'PICKED_UP';
      action = 'CONFIRM PICKUP';
    }
    if (!_isSupplier &&
        !_isDriver &&
        status == 'PENDING' &&
        paymentStatus == 'PAID' &&
        !hasProviderTransaction) {
      nextStatus = 'CANCELLED';
      action = 'CANCEL ORDER';
    }
    final busy = _updatingId == order['id'];
    final driverConfirmed = order['driver_confirmed_delivery'] == true;
    final clientConfirmed = order['client_confirmed_delivery'] == true;
    final isActiveDelivery = !isPickup && status == 'OUT_FOR_DELIVERY';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order['bottle_detail']?.toString() ?? 'Gas bottle',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.accentTeal.withOpacity(.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.replaceAll('_', ' '),
                  style: const TextStyle(
                    color: AppTheme.accentTeal,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Order #${order['id']} · ${isPickup ? 'Customer pickup' : 'Delivery'}',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            _isSupplier
                ? 'Customer: ${order['client_name'] ?? 'Customer'}'
                : _isDriver
                ? 'Customer: ${order['client_name'] ?? 'Customer'}'
                : 'Supplier: ${order['vendor_name'] ?? 'Supplier'}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          if ((order['delivery_address'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Location: ${order['delivery_address']}',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
          if (_isDriver &&
              !isPickup &&
              (status == 'ASSIGNED' || status == 'OUT_FOR_DELIVERY')) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: busy ? null : () => _openCustomerRoute(order),
                icon: const Icon(Icons.directions),
                label: const Text('GET DIRECTIONS TO CUSTOMER'),
              ),
            ),
          ],
          if (isActiveDelivery) ...[
            const SizedBox(height: 12),
            _confirmationProgress(
              driverConfirmed: driverConfirmed,
              clientConfirmed: clientConfirmed,
            ),
            if (_isDriver && !driverConfirmed) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: busy
                      ? null
                      : () => _confirmDelivery(order, 'DRIVER'),
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(busy ? 'SAVING…' : 'MARK AS DELIVERED'),
                ),
              ),
            ],
            if (!_isDriver &&
                !_isSupplier &&
                driverConfirmed &&
                !clientConfirmed) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: busy
                      ? null
                      : () => _confirmDelivery(order, 'CLIENT'),
                  icon: const Icon(Icons.task_alt),
                  label: Text(busy ? 'SAVING…' : 'CONFIRM GAS RECEIVED'),
                ),
              ),
            ],
          ],
          const SizedBox(height: 8),
          Text(
            'Total: $totalPrice FCFA',
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (!_isSupplier && !_isDriver && paymentStatus != 'PAID') ...[
            const SizedBox(height: 6),
            Text(
              'Payment: ${paymentStatus.replaceAll('_', ' ')}${order['payment_amount'] == null ? '' : ' · ${order['payment_amount']} FCFA'}',
              style: TextStyle(
                color: paymentStatus == 'FAILED'
                    ? Colors.redAccent
                    : Colors.amber,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            if ((paymentStatus == 'PENDING' || paymentStatus == 'UNKNOWN') &&
                hasProviderTransaction) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _checkingPaymentId == order['id']
                      ? null
                      : () => _checkPayment(order),
                  child: Text(
                    _checkingPaymentId == order['id']
                        ? 'CHECKING PAYMENT…'
                        : 'CHECK PAYMENT',
                  ),
                ),
              ),
            ],
            if (paymentStatus == 'UNKNOWN')
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'We could not confirm this payment. Contact support before paying again.',
                  style: TextStyle(color: Colors.amber, fontSize: 11),
                ),
              ),
          ],
          if (!_isSupplier && !_isDriver && paymentStatus == 'PAID') ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _checkingPaymentId == order['id']
                    ? null
                    : () {
                        final orderId = int.tryParse(
                          order['id']?.toString() ?? '',
                        );
                        if (orderId != null) _downloadInvoice(orderId);
                      },
                icon: const Icon(Icons.download_outlined),
                label: const Text('DOWNLOAD INVOICE PDF'),
              ),
            ),
          ],
          if (nextStatus != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: busy ? null : () => _update(order, nextStatus!),
                child: Text(busy ? 'UPDATING…' : action),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _confirmationProgress({
    required bool driverConfirmed,
    required bool clientConfirmed,
  }) {
    Widget confirmationLine(String label, bool confirmed) => Row(
      children: [
        Icon(
          confirmed ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: confirmed ? AppTheme.accentTeal : Colors.white38,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ${confirmed ? 'confirmed' : 'waiting'}',
          style: TextStyle(
            color: confirmed ? AppTheme.accentTeal : Colors.white54,
            fontSize: 11,
          ),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DELIVERY STATUS',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          confirmationLine('Delivery person', driverConfirmed),
          const SizedBox(height: 5),
          confirmationLine('Customer', clientConfirmed),
        ],
      ),
    );
  }
}
