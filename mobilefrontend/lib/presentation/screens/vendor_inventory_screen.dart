import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/vendor_models.dart';
import '../../domain/providers/auth_provider.dart';
import '../../domain/providers/vendor_provider.dart';
import '../widgets/vendor_bottle_card.dart';

class VendorInventoryScreen extends ConsumerStatefulWidget {
  const VendorInventoryScreen({super.key});

  @override
  ConsumerState<VendorInventoryScreen> createState() =>
      _VendorInventoryScreenState();
}

class _VendorInventoryScreenState extends ConsumerState<VendorInventoryScreen> {
  bool _loading = true;
  bool _saving = false;
  String _applicationStatus = 'pending';
  String _rejectionReason = '';
  String? _error;
  List<GasBottle> _inventory = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repository = ref.read(vendorRepositoryProvider);
      final profile = await repository.getMySupplierProfile();
      _applicationStatus =
          profile['application_status']?.toString().toLowerCase() ?? 'pending';
      _rejectionReason = profile['rejection_reason']?.toString() ?? '';
      _inventory = _applicationStatus == 'approved'
          ? (await repository.getMyInventory()).map(GasBottle.fromJson).toList()
          : [];
    } catch (_) {
      _error =
          'Could not load supplier details. Check your connection and account status.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addBottle() async {
    final values = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const _BottleInventoryDialog(),
    );
    if (values == null) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(vendorRepositoryProvider)
          .addBottle(
            brand: values['brand'],
            size: values['size'],
            price: values['price'],
            stock: values['stock'],
          );
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not add inventory. Check that the brand and size combination is not already listed.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _manageBottle(GasBottle bottle) async {
    final values = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _BottleInventoryDialog(bottle: bottle),
    );
    if (values == null) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(vendorRepositoryProvider)
          .updateBottle(
            id: bottle.id,
            price: values['price'],
            stock: values['stock'],
          );
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update this bottle stock.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SUPPLIER INVENTORY',
          style: TextStyle(
            letterSpacing: 1.4,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
        backgroundColor: Colors.transparent,
        actions: [
          if (_applicationStatus == 'approved')
            IconButton(
              onPressed: _saving ? null : _addBottle,
              icon: const Icon(Icons.add, color: AppTheme.accentTeal),
            ),
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_error!, textAlign: TextAlign.center),
              ),
            )
          : _applicationStatus != 'approved'
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      color: Colors.amber,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'APPLICATION ${_applicationStatus.toUpperCase()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _applicationStatus == 'rejected' &&
                              _rejectionReason.isNotEmpty
                          ? _rejectionReason
                          : 'The administrator will review your ID, tax receipt, business location, and supporting document. Inventory opens after approval.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white54),
                    ),
                    if (user?.applicationStatus == 'pending')
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          'Your documents are in the review queue.',
                          style: TextStyle(color: Colors.amber),
                        ),
                      ),
                  ],
                ),
              ),
            )
          : _inventory.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No inventory added yet.'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _saving ? null : _addBottle,
                    icon: const Icon(Icons.add),
                    label: const Text('Add a bottle'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: .8,
                ),
                itemCount: _inventory.length,
                itemBuilder: (context, index) => VendorBottleCard(
                  bottle: _inventory[index],
                  onManage: () => _manageBottle(_inventory[index]),
                ),
              ),
            ),
    );
  }
}

class _BottleInventoryDialog extends StatefulWidget {
  const _BottleInventoryDialog({this.bottle});

  final GasBottle? bottle;

  @override
  State<_BottleInventoryDialog> createState() => _BottleInventoryDialogState();
}

class _BottleInventoryDialogState extends State<_BottleInventoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late String _brand;
  late String _size;

  bool get _isEditing => widget.bottle != null;

  @override
  void initState() {
    super.initState();
    final bottle = widget.bottle;
    _priceController = TextEditingController(
      text: bottle?.price.toStringAsFixed(0) ?? '',
    );
    _stockController = TextEditingController(
      text: bottle?.stock.toString() ?? '1',
    );
    _brand = bottle?.brandCode ?? 'TOTAL_ENERGIES';
    _size = bottle?.sizeCode ?? 'MEDIUM_12_5KG';
  }

  @override
  void dispose() {
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop({
      if (!_isEditing) 'brand': _brand,
      if (!_isEditing) 'size': _size,
      'price': double.parse(_priceController.text),
      'stock': int.parse(_stockController.text),
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottle = widget.bottle;
    return AlertDialog(
      title: Text(_isEditing ? 'Manage bottle stock' : 'Add bottle variant'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isEditing) ...[
                Text(
                  '${bottle!.brand} · ${bottle.size}',
                  style: const TextStyle(
                    color: AppTheme.accentTeal,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
              ] else ...[
                const Text(
                  'Add one brand and size combination at a time. Add another variant to list more bottle types.',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _brand,
                  decoration: const InputDecoration(labelText: 'Brand'),
                  items: const [
                    DropdownMenuItem(value: 'SCTM', child: Text('SCTM')),
                    DropdownMenuItem(
                      value: 'TOTAL_ENERGIES',
                      child: Text('TotalEnergies'),
                    ),
                    DropdownMenuItem(value: 'TRADEX', child: Text('Tradex')),
                    DropdownMenuItem(value: 'STAR_GAS', child: Text('StarGas')),
                    DropdownMenuItem(
                      value: 'AZA_MRS',
                      child: Text('Aza Gas / MRS'),
                    ),
                    DropdownMenuItem(
                      value: 'GLOCAL_GAS',
                      child: Text('Glocal Gas'),
                    ),
                    DropdownMenuItem(value: 'BOCOM', child: Text('Bocom')),
                    DropdownMenuItem(value: 'TOTAL', child: Text('Total')),
                    DropdownMenuItem(
                      value: 'GREEN_OIL',
                      child: Text('Green Oil'),
                    ),
                    DropdownMenuItem(value: 'CAMGAZ', child: Text('Camgaz')),
                    DropdownMenuItem(value: 'MRS', child: Text('MRS')),
                    DropdownMenuItem(value: 'AFT', child: Text('AFT')),
                    DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                  ],
                  // The form field updates its own selected value. Avoid rebuilding
                  // the whole dialog while its dropdown route is closing.
                  onChanged: (value) {
                    if (value != null) _brand = value;
                  },
                ),
                DropdownButtonFormField<String>(
                  initialValue: _size,
                  decoration: const InputDecoration(labelText: 'Bottle size'),
                  items: const [
                    DropdownMenuItem(
                      value: 'SMALL_6KG',
                      child: Text('Small · 6 kg'),
                    ),
                    DropdownMenuItem(
                      value: 'MEDIUM_12_5KG',
                      child: Text('Medium · 12.5 kg'),
                    ),
                    DropdownMenuItem(
                      value: 'BIG_50KG',
                      child: Text('Big · 50 kg'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) _size = value;
                  },
                ),
              ],
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Price (FCFA)'),
                validator: (value) {
                  final amount = double.tryParse(value ?? '');
                  return amount == null || amount < 0
                      ? 'Enter a valid price.'
                      : null;
                },
              ),
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _isEditing
                      ? 'Units in stock'
                      : 'Units in stock for this variant',
                ),
                validator: (value) {
                  final quantity = int.tryParse(value ?? '');
                  return quantity == null || quantity < 0
                      ? 'Enter a quantity of zero or more.'
                      : null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
