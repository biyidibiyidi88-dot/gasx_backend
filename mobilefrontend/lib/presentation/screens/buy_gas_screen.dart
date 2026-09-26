import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/auth_models.dart';
import '../../domain/providers/vendor_provider.dart';
import '../../data/models/vendor_models.dart';
import '../../domain/providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/location/current_device_location.dart';
import '../../domain/providers/chat_provider.dart';

class BuyGasScreen extends ConsumerStatefulWidget {
  const BuyGasScreen({super.key});

  @override
  ConsumerState<BuyGasScreen> createState() => _BuyGasScreenState();
}

class _BuyGasScreenState extends ConsumerState<BuyGasScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _radarController;
  final _deliveryAddress = TextEditingController();
  Position? _deliveryPosition;
  bool _gettingDeliveryLocation = false;
  String _fulfillmentMethod = 'PICKUP';
  int? _orderingBottleId;
  int? _selectedBottleId;
  int? _selectedBottleVendorId;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    _deliveryAddress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vendorsAsync = ref.watch(vendorsProvider);
    final selectedVendor = ref.watch(selectedVendorProvider);
    final user = ref.watch(authStateProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LOGISTICS',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Colors.white24,
              ),
            ),
            Text(
              'NODE SUPPLY MATRIX',
              style: TextStyle(
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.accentTeal.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.accentTeal.withOpacity(0.1)),
            ),
            alignment: Alignment.center,
            child: const Text(
              'GRID_ACTIVE: DOUALA_CENTRAL',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: AppTheme.accentTeal,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 1. Regional Nodes List
            _buildVendorList(vendorsAsync, selectedVendor),
            const SizedBox(height: 32),

            // 3. Volumetric Inventory Table
            if (selectedVendor != null) ...[
              _buildFulfillmentChoice(),
              const SizedBox(height: 16),
              _buildInventoryMatrix(selectedVendor, user),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVendorList(
    AsyncValue<List<Vendor>> vendorsAsync,
    Vendor? selected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'REGIONAL NODES',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Colors.white24,
              ),
            ),
            if (vendorsAsync.value != null && vendorsAsync.value!.isNotEmpty)
              TextButton.icon(
                onPressed: () => _getAIRecommendation(vendorsAsync.value!),
                icon: const Icon(
                  Icons.auto_awesome,
                  size: 12,
                  color: AppTheme.accentTeal,
                ),
                label: const Text(
                  'AI RECOMMENDATION',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: AppTheme.accentTeal,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: vendorsAsync.when(
            data: (vendors) => ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: vendors.length,
              itemBuilder: (context, index) {
                final v = vendors[index];
                final isSelected = selected?.id == v.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: InkWell(
                    onTap: () => _selectVendor(v),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.accentTeal.withOpacity(0.05)
                            : Colors.white.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.accentTeal.withOpacity(0.3)
                              : Colors.white.withOpacity(0.05),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            v.storeName.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            v.address,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.white24,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }

  GasBottle? _preferredBottle(Vendor vendor, UserAccount? user) {
    final available = (vendor.gasBottles ?? [])
        .where((bottle) => bottle.stock > 0)
        .toList();
    if (available.isEmpty) return null;

    if (_selectedBottleVendorId == vendor.id && _selectedBottleId != null) {
      for (final bottle in available) {
        if (bottle.id == _selectedBottleId) return bottle;
      }
    }

    for (final bottle in available) {
      if (bottle.brandCode == user?.preferredBottleBrand &&
          bottle.sizeCode == user?.preferredBottleSize) {
        return bottle;
      }
    }
    return available.first;
  }

  void _selectVendor(Vendor vendor) {
    final preferred = _preferredBottle(
      vendor,
      ref.read(authStateProvider).user,
    );
    setState(() {
      _selectedBottleVendorId = vendor.id;
      _selectedBottleId = preferred?.id;
    });
    ref.read(selectedVendorProvider.notifier).state = vendor;
  }

  Widget _buildInventoryMatrix(Vendor selected, UserAccount? user) {
    final items = selected.gasBottles ?? [];
    final available = items.where((bottle) => bottle.stock > 0).toList();
    final selectedBottle = _preferredBottle(selected, user);
    final hasPreferredBottle = available.any(
      (bottle) =>
          bottle.brandCode == user?.preferredBottleBrand &&
          bottle.sizeCode == user?.preferredBottleSize,
    );
    final selectedMatchesPreference =
        selectedBottle != null &&
        selectedBottle.brandCode == user?.preferredBottleBrand &&
        selectedBottle.sizeCode == user?.preferredBottleSize;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${selected.storeName.toUpperCase()} MATRIX',
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Colors.white24,
              ),
            ),
            TextButton.icon(
              onPressed: () => _launchNavigation(selected),
              icon: const Icon(
                Icons.directions,
                color: AppTheme.accentTeal,
                size: 16,
              ),
              label: const Text(
                'TRACE ROUTE',
                style: TextStyle(
                  color: AppTheme.accentTeal,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          padding: const EdgeInsets.all(24),
          child: items.isEmpty
              ? const Center(
                  child: Text(
                    'No bottle variants are listed yet.',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : available.isEmpty
              ? const Center(
                  child: Text(
                    'All bottle variants are currently out of stock.',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CHOOSE A BOTTLE BRAND AND SIZE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      value: selectedBottle?.id,
                      dropdownColor: AppTheme.secondaryBg,
                      isExpanded: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: available
                          .map(
                            (bottle) => DropdownMenuItem<int>(
                              value: bottle.id,
                              child: Text(
                                '${bottle.brand} · ${bottle.size} · ${bottle.price.toStringAsFixed(0)} FCFA',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (id) {
                        if (id == null) return;
                        setState(() {
                          _selectedBottleVendorId = selected.id;
                          _selectedBottleId = id;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      selectedMatchesPreference
                          ? 'Your saved brand and size were selected. You can change them above.'
                          : hasPreferredBottle
                          ? 'Your saved bottle is in stock, and you selected a different variant. You can switch back above.'
                          : 'Your saved bottle is not in stock here. Choose any available brand and size above.',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                    if (selectedBottle != null) ...[
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${selectedBottle.brand} · ${selectedBottle.size}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            '${selectedBottle.stock} available',
                            style: const TextStyle(
                              color: AppTheme.accentTeal,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${selectedBottle.price.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(
                          color: AppTheme.accentTeal,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _orderingBottleId != null
                              ? null
                              : () => _placeOrder(selectedBottle),
                          child: Text(
                            _orderingBottleId == selectedBottle.id
                                ? 'ORDERING…'
                                : 'ORDER SELECTED BOTTLE',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildFulfillmentChoice() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HOW DO YOU WANT TO GET YOUR GAS?',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _fulfillmentMethod,
            dropdownColor: const Color(0xFF101827),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: 'PICKUP',
                child: Text('I will pick it up myself'),
              ),
              DropdownMenuItem(
                value: 'DELIVERY',
                child: Text('Book a delivery person'),
              ),
            ],
            onChanged: _orderingBottleId == null
                ? (value) =>
                      setState(() => _fulfillmentMethod = value ?? 'PICKUP')
                : null,
          ),
          if (_fulfillmentMethod == 'DELIVERY') ...[
            const SizedBox(height: 12),
            TextField(
              controller: _deliveryAddress,
              onChanged: (_) {
                if (_deliveryPosition != null) {
                  setState(() => _deliveryPosition = null);
                }
              },
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Delivery address',
                hintText: 'Enter your delivery location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _gettingDeliveryLocation
                    ? null
                    : _syncDeliveryLocation,
                icon: _gettingDeliveryLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: Text(
                  _gettingDeliveryLocation
                      ? 'GETTING LOCATION…'
                      : _deliveryPosition == null
                      ? 'USE MY CURRENT LOCATION'
                      : 'UPDATE CURRENT LOCATION',
                ),
              ),
            ),
            if (_deliveryPosition != null)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'Your GPS location will be shared with the assigned delivery person.',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _syncDeliveryLocation() async {
    setState(() => _gettingDeliveryLocation = true);
    try {
      final position = await getCurrentDevicePosition();
      if (!mounted) return;
      setState(() {
        _deliveryPosition = position;
        _deliveryAddress.text =
            'Current GPS location (${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)})';
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _gettingDeliveryLocation = false);
    }
  }

  Future<void> _placeOrder(GasBottle bottle) async {
    if (_fulfillmentMethod == 'DELIVERY' &&
        _deliveryAddress.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a delivery address to book a delivery.'),
        ),
      );
      return;
    }
    setState(() => _orderingBottleId = bottle.id);
    try {
      final paidOrder = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: AppTheme.secondaryBg,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        builder: (context) => _PaymentFormSheet(
          bottleName: '${bottle.brand} ${bottle.size}',
          fulfillmentMethod: _fulfillmentMethod,
          supplierPrice: bottle.price,
          deliveryFee: _fulfillmentMethod == 'DELIVERY' ? 25 : 0,
          onInitiatePayment:
              ({required paymentOperator, required payerPhone}) => ref
                  .read(vendorRepositoryProvider)
                  .initiatePayment(
                    bottleId: bottle.id,
                    fulfillmentMethod: _fulfillmentMethod,
                    deliveryAddress: _deliveryAddress.text.trim(),
                    latitude: _deliveryPosition?.latitude,
                    longitude: _deliveryPosition?.longitude,
                    paymentOperator: paymentOperator,
                    payerPhone: payerPhone,
                  ),
          onCheckStatus: (orderId) =>
              ref.read(vendorRepositoryProvider).checkPaymentStatus(orderId),
        ),
      );
      if (paidOrder != null && mounted) {
        final selected = ref.read(selectedVendorProvider);
        if (selected != null) {
          final updatedBottles = (selected.gasBottles ?? [])
              .map(
                (item) => item.id == bottle.id
                    ? item.copyWith(stock: item.stock - 1)
                    : item,
              )
              .toList();
          ref.read(selectedVendorProvider.notifier).state = selected.copyWith(
            gasBottles: updatedBottles,
          );
        }
        ref.invalidate(vendorsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment confirmed for order #${paidOrder['id']}.'),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        final message = error is DioException
            ? (error.response?.data?['error'] ??
                  error.response?.data?['detail'] ??
                  'Could not place this order.')
            : 'Could not place this order.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message.toString())));
      }
    } finally {
      if (mounted) setState(() => _orderingBottleId = null);
    }
  }

  Future<void> _launchNavigation(Vendor v) async {
    if (v.latitude == null || v.longitude == null) return;
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${v.latitude},${v.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> _getAIRecommendation(List<Vendor> vendors) async {
    try {
      // 1. Pre-flight checks (no UI impact yet)
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      // 2. Show Loading Node (Top Level)
      if (!mounted) return;
      showDialog(
        context: context,
        useRootNavigator: true,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppTheme.accentTeal),
        ),
      );

      String recommendation;
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        final chatRepo = ref.read(chatRepositoryProvider);
        recommendation = await chatRepo.getVendorRecommendation(
          position,
          vendors,
        );
      } finally {
        // 3. SECURE POP: Always remove the loader before showing results or errors
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      }

      if (mounted) {
        _showRecommendationDialog(recommendation);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('INTELLIGENCE UPLINK FAILED: $e')),
        );
      }
    }
  }

  void _showRecommendationDialog(String recommendation) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppTheme.accentTeal, size: 20),
            SizedBox(width: 8),
            Text(
              'AI RECOMMENDATION',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppTheme.accentTeal,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            recommendation,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'DISMISS',
              style: TextStyle(
                color: AppTheme.accentTeal,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentFormSheet extends StatefulWidget {
  const _PaymentFormSheet({
    required this.bottleName,
    required this.fulfillmentMethod,
    required this.supplierPrice,
    required this.deliveryFee,
    required this.onInitiatePayment,
    required this.onCheckStatus,
  });

  final String bottleName;
  final String fulfillmentMethod;
  final double supplierPrice;
  final double deliveryFee;
  final Future<Map<String, dynamic>> Function({
    required String paymentOperator,
    required String payerPhone,
  })
  onInitiatePayment;
  final Future<Map<String, dynamic>> Function(int orderId) onCheckStatus;

  @override
  State<_PaymentFormSheet> createState() => _PaymentFormSheetState();
}

class _PaymentFormSheetState extends State<_PaymentFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String? _paymentMethod;
  int? _orderId;
  String? _transactionId;
  String? _paymentMessage;
  double? _serverAmount;
  bool _submitting = false;
  bool _checking = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = _serverAmount ?? widget.supplierPrice + widget.deliveryFee;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'CHECKOUT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close payment form',
                  onPressed: _submitting || _checking
                      ? null
                      : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
            Text(
              '${_orderId == null ? 'New order' : 'Order #$_orderId'} · ${widget.bottleName}',
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 20),
            _priceRow('Supplier price', widget.supplierPrice),
            const SizedBox(height: 8),
            _priceRow(
              widget.fulfillmentMethod == 'DELIVERY'
                  ? 'Delivery fee'
                  : 'Pickup fee',
              widget.deliveryFee,
            ),
            const Divider(height: 24, color: Colors.white24),
            _priceRow('TOTAL', total, isTotal: true),
            const SizedBox(height: 22),
            const Text(
              'PAYMENT METHOD',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _paymentMethodTile(
                    value: 'ORANGE_MONEY',
                    label: 'Orange Money',
                    color: const Color(0xFFFF8A00),
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _paymentMethodTile(
                    value: 'MTN_MOMO',
                    label: 'MTN MoMo',
                    color: const Color(0xFFFFD54F),
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_paymentMethod == null)
              const Text(
                'Choose an operator to enter the wallet number to debit.',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              )
            else
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _paymentMethod == 'ORANGE_MONEY'
                          ? 'ORANGE MONEY NUMBER TO DEBIT'
                          : 'MTN MOMO NUMBER TO DEBIT',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      enabled: _orderId == null && !_submitting,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 9,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Phone number to debit',
                        hintText: '6XX XXX XXX',
                        prefixText: '+237 ',
                        prefixStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                        helperText:
                            'Enter the number registered to this wallet.',
                        counterStyle: TextStyle(color: Colors.white38),
                      ),
                      validator: (value) => (value ?? '').trim().length == 9
                          ? null
                          : 'Enter all 9 digits of the wallet number.',
                    ),
                  ],
                ),
              ),
            if (_paymentMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.teal.withOpacity(.25)),
                ),
                child: Text(
                  _paymentMessage!,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
            if (_transactionId != null) ...[
              const SizedBox(height: 8),
              Text(
                'DigiPay reference: $_transactionId',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: _orderId == null
                  ? FilledButton(
                      onPressed: _submitting || _paymentMethod == null
                          ? null
                          : _startPayment,
                      child: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text('PAY ${total.toStringAsFixed(0)} FCFA'),
                    )
                  : OutlinedButton(
                      onPressed: _checking
                          ? null
                          : () => _checkPayment(poll: false),
                      child: _checking
                          ? const Text('CHECKING PAYMENT…')
                          : const Text('CHECK PAYMENT STATUS'),
                    ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _submitting
                    ? null
                    : () => Navigator.of(context).pop(),
                child: const Text('CLOSE'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startPayment() async {
    if (_paymentMethod == null ||
        !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _submitting = true;
      _paymentMessage = 'Starting secure Mobile Money payment…';
    });
    try {
      final result = await widget.onInitiatePayment(
        paymentOperator: _paymentMethod!,
        payerPhone: '237${_phoneController.text.trim()}',
      );
      if (!mounted) return;
      final id = int.tryParse(result['order_id']?.toString() ?? '');
      final amount = double.tryParse(result['amount']?.toString() ?? '');
      setState(() {
        _orderId = id;
        _transactionId = result['transaction_id']?.toString();
        if (amount != null) _serverAmount = amount;
        _paymentMessage =
            result['message']?.toString() ??
            'Approve the payment prompt on your phone.';
      });
      final state = result['payment_status']?.toString().toUpperCase();
      if (state == 'PAID' && result['order'] is Map) {
        Navigator.of(
          context,
        ).pop(Map<String, dynamic>.from(result['order'] as Map));
        return;
      }
      if (id != null && state != 'FAILED' && state != 'UNKNOWN') {
        if (mounted) setState(() => _submitting = false);
        await _checkPayment(poll: true);
      }
    } catch (error) {
      if (mounted) setState(() => _paymentMessage = _errorMessage(error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _checkPayment({required bool poll}) async {
    final id = _orderId;
    if (id == null) return;
    setState(() {
      _checking = true;
      _paymentMessage = 'Waiting for operator confirmation…';
    });
    try {
      final attempts = poll ? 12 : 1;
      for (var attempt = 0; attempt < attempts; attempt++) {
        if (attempt > 0) await Future<void>.delayed(const Duration(seconds: 5));
        if (!mounted) return;
        final result = await widget.onCheckStatus(id);
        if (!mounted) return;
        final paymentStatus = result['payment_status']
            ?.toString()
            .toUpperCase();
        if (paymentStatus == 'PAID' && result['order'] is Map) {
          Navigator.of(
            context,
          ).pop(Map<String, dynamic>.from(result['order'] as Map));
          return;
        }
        if (paymentStatus == 'FAILED') {
          setState(() {
            _paymentMessage =
                result['message']?.toString() ??
                'Payment was declined. Close this form and try again.';
          });
          return;
        }
        if (paymentStatus == 'UNKNOWN' && _transactionId == null) {
          setState(() {
            _paymentMessage =
                result['message']?.toString() ??
                'The payment request could not be confirmed. Contact support before retrying.';
          });
          return;
        }
        if (!poll) {
          setState(() {
            _paymentMessage =
                result['message']?.toString() ??
                'Payment is still pending. Approve the prompt, then check again.';
          });
        }
      }
      if (poll && mounted) {
        setState(() {
          _paymentMessage =
              'Still waiting for payment. You can check again below.';
        });
      }
    } catch (error) {
      if (mounted) setState(() => _paymentMessage = _errorMessage(error));
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  String _errorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        return (data['message'] ?? data['detail'] ?? data['error'])
                ?.toString() ??
            'Payment could not be started. Please try again.';
      }
    }
    return 'Payment service could not be reached. Check your connection and try again.';
  }

  Widget _paymentMethodTile({
    required String value,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    final selected = _paymentMethod == value;
    return InkWell(
      onTap: _orderId != null || _submitting
          ? null
          : () => setState(() => _paymentMethod = value),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? color.withOpacity(.12)
              : Colors.white.withOpacity(.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color.withOpacity(.65) : Colors.white12,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? color : Colors.white38,
              size: 17,
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, double amount, {bool isTotal = false}) {
    final style = TextStyle(
      color: isTotal ? AppTheme.accentTeal : Colors.white70,
      fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
      fontSize: isTotal ? 15 : 13,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text('${amount.toStringAsFixed(0)} FCFA', style: style),
      ],
    );
  }
}
