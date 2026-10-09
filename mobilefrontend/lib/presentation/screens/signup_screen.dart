import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _supplierName = TextEditingController();
  final _supplierAddress = TextEditingController();
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();
  String _accountType = 'client';
  bool _showPassword = false;
  bool _submitting = false;
  bool _locating = false;
  PlatformFile? _identityCard;
  PlatformFile? _taxPaymentProof;
  PlatformFile? _supportingDocument;

  bool get _needsVerification => _accountType != 'client';

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _supplierName.dispose();
    _supplierAddress.dispose();
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  Future<PlatformFile?> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    return result?.files.single;
  }

  Future<void> _chooseDocument(String kind) async {
    try {
      final file = await _pickFile();
      if (file == null) return;
      setState(() {
        if (kind == 'identity') _identityCard = file;
        if (kind == 'tax') _taxPaymentProof = file;
        if (kind == 'support') _supportingDocument = file;
      });
    } catch (_) {
      _showMessage('Could not open the document picker. Please try again.');
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permission is needed to add the supplier location.',
        );
      }
      final position = await Geolocator.getCurrentPosition();
      _latitude.text = position.latitude.toStringAsFixed(6);
      _longitude.text = position.longitude.toStringAsFixed(6);
    } catch (error) {
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  List<String> _missingSupplierFields() {
    final missing = <String>[];
    if (_supplierName.text.trim().isEmpty) missing.add('business name');
    final hasAddress = _supplierAddress.text.trim().isNotEmpty;
    final latitudeText = _latitude.text.trim();
    final longitudeText = _longitude.text.trim();
    final hasLatitude = latitudeText.isNotEmpty;
    final hasLongitude = longitudeText.isNotEmpty;
    final hasCoordinates = hasLatitude && hasLongitude;

    if (hasLatitude != hasLongitude) {
      missing.add('both map coordinates, or clear the one entered');
    } else if (hasCoordinates) {
      final latitude = double.tryParse(latitudeText);
      final longitude = double.tryParse(longitudeText);
      if (latitude == null ||
          !latitude.isFinite ||
          latitude < -90 ||
          latitude > 90 ||
          longitude == null ||
          !longitude.isFinite ||
          longitude < -180 ||
          longitude > 180) {
        missing.add('valid map coordinates');
      }
    }
    if (!hasAddress && !hasCoordinates) {
      missing.add('business address or both map coordinates');
    }

    if (_taxPaymentProof == null) missing.add('tax payment receipt');
    if (_identityCard == null) missing.add('identity card');
    if (_supportingDocument == null) missing.add('authenticity document');
    return missing;
  }

  Future<void> _handleSignup() async {
    if (_submitting) return;
    if (_firstName.text.trim().isEmpty ||
        _lastName.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _password.text.isEmpty) {
      _showMessage('Please enter your name, email, and password.');
      return;
    }
    if (_accountType == 'gas_supplier') {
      final missing = _missingSupplierFields();
      if (missing.isNotEmpty) {
        _showMessage('Complete these supplier fields: ${missing.join(', ')}.');
        return;
      }
    } else if (_needsVerification && _identityCard == null) {
      _showMessage('Upload your ID card to apply.');
      return;
    }

    final data = <String, dynamic>{
      'email': _email.text.trim(),
      'password': _password.text,
      'first_name': _firstName.text.trim(),
      'last_name': _lastName.text.trim(),
      'phone_number': _phone.text.trim(),
      'accept_terms': true,
      'account_type': _accountType,
    };
    if (_needsVerification) {
      data['identity_card'] = _identityCard;
      data['supporting_document'] = _supportingDocument;
    }
    if (_accountType == 'gas_supplier') {
      data.addAll({
        'supplier_name': _supplierName.text.trim(),
        'supplier_address': _supplierAddress.text.trim(),
        'tax_payment_document': _taxPaymentProof,
      });
      if (_latitude.text.trim().isNotEmpty &&
          _longitude.text.trim().isNotEmpty) {
        data['supplier_latitude'] = _latitude.text.trim();
        data['supplier_longitude'] = _longitude.text.trim();
      }
    }

    setState(() => _submitting = true);
    await ref.read(authStateProvider.notifier).register(data);
    final state = ref.read(authStateProvider);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (state.error != null) {
      _showMessage(state.error!);
      return;
    }
    if (_needsVerification) {
      _showMessage(
        'Application submitted. Your account is pending administrator review.',
      );
    }
    context.go('/dashboard');
  }

  Widget _documentPicker(
    String title,
    PlatformFile? file,
    VoidCallback onTap, {
    bool required = true,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(file == null ? Icons.upload_file : Icons.check_circle_outline),
      label: Text(
        file?.name ?? '$title${required ? ' *' : ''}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: file == null ? Colors.white70 : AppTheme.accentTeal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        side: BorderSide(
          color: file == null
              ? Colors.white24
              : AppTheme.accentTeal.withOpacity(.5),
        ),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Widget _input(
    String label,
    TextEditingController controller, {
    String? hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(.12)),
        ),
        labelStyle: const TextStyle(color: Colors.white60),
        hintStyle: const TextStyle(color: Colors.white24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentBlue.withOpacity(0.1),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    children: [
                      Text(
                        'NEW ACCOUNT',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'SIGN UP',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      const SizedBox(height: 32),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.03),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withOpacity(.08),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                DropdownButtonFormField<String>(
                                  value: _accountType,
                                  decoration: const InputDecoration(
                                    labelText: 'Account type',
                                    border: OutlineInputBorder(),
                                  ),
                                  dropdownColor: const Color(0xFF101827),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'client',
                                      child: Text('Client'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'delivery_person',
                                      child: Text('Delivery person'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'gas_supplier',
                                      child: Text('Gas supplier'),
                                    ),
                                  ],
                                  onChanged: (value) => setState(
                                    () => _accountType = value ?? 'client',
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _input('First name', _firstName),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _input('Last name', _lastName),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _input(
                                  'Email address',
                                  _email,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 16),
                                _input(
                                  'Phone number',
                                  _phone,
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _password,
                                  obscureText: !_showPassword,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    border: const OutlineInputBorder(),
                                    labelStyle: const TextStyle(
                                      color: Colors.white60,
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () => setState(
                                        () => _showPassword = !_showPassword,
                                      ),
                                      icon: Icon(
                                        _showPassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ),
                                ),
                                if (_needsVerification) ...[
                                  const SizedBox(height: 24),
                                  Text(
                                    _accountType == 'gas_supplier'
                                        ? 'SUPPLIER ACCOUNT REVIEW'
                                        : 'DELIVERY ACCOUNT REVIEW',
                                    style: const TextStyle(
                                      color: AppTheme.accentTeal,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'An admin must check your documents before approving this account.',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _documentPicker(
                                    'ID card (PDF or image)',
                                    _identityCard,
                                    () => _chooseDocument('identity'),
                                  ),
                                  const SizedBox(height: 10),
                                  _documentPicker(
                                    _accountType == 'gas_supplier'
                                        ? 'Business proof document'
                                        : 'Extra document (optional)',
                                    _supportingDocument,
                                    () => _chooseDocument('support'),
                                    required: _accountType == 'gas_supplier',
                                  ),
                                  if (_accountType == 'gas_supplier') ...[
                                    const SizedBox(height: 20),
                                    _input(
                                      'Supplier / business name',
                                      _supplierName,
                                    ),
                                    const SizedBox(height: 14),
                                    _input(
                                      'Business location / address',
                                      _supplierAddress,
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _input(
                                            'Latitude',
                                            _latitude,
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                  signed: true,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: _input(
                                            'Longitude',
                                            _longitude,
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                  signed: true,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Text(
                                        'Enter the business address. You can also use your current location to show customers where the shop is.',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: TextButton.icon(
                                        onPressed: _locating
                                            ? null
                                            : _useCurrentLocation,
                                        icon: _locating
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : const Icon(Icons.my_location),
                                        label: const Text(
                                          'Use current location',
                                        ),
                                      ),
                                    ),
                                    _documentPicker(
                                      'Tax payment receipt',
                                      _taxPaymentProof,
                                      () => _chooseDocument('tax'),
                                    ),
                                  ],
                                ],
                                const SizedBox(height: 24),
                                SizedBox(
                                  height: 52,
                                  child: FilledButton(
                                    onPressed: _submitting
                                        ? null
                                        : _handleSignup,
                                    child: Text(
                                      _submitting
                                          ? 'SAVING…'
                                          : 'CREATE ACCOUNT',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ALREADY HAVE AN ACCOUNT? ',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          TextButton(
                            onPressed: () => context.go('/login'),
                            child: Text(
                              'SIGN IN',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: AppTheme.accentTeal),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
