import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/bottle_profiles.dart';
import '../../domain/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    if (user == null) return const Center(child: Text('LOGGED OUT'));

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'IDENTITY',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Colors.white24,
              ),
            ),
            Text(
              'NODE CONFIGURATION',
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
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white70),
            onPressed: () => _showSettings(user),
          ),
          TextButton(
            onPressed: _isUpdating ? null : () => _handleUpdate(user),
            child: Text(
              _isUpdating ? 'PROCESSING...' : 'COMMIT_CHANGES',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: AppTheme.accentTeal,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Identity Overview
            _buildIdentityHeader(user),
            const SizedBox(height: 32),

            // 2. Attribute Modification
            _buildAttributeSection(user),
            const SizedBox(height: 32),

            // 2.5 App Settings Section
            _buildAppSettingsSection(context),
            const SizedBox(height: 32),

            // 3. Terminal Commands (Danger Zone)
            _buildDangerZone(),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentityHeader(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              image: user.profileImage != null
                  ? DecorationImage(
                      image: NetworkImage(user.profileImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: user.profileImage == null
                ? const Icon(
                    Icons.person_outline,
                    size: 40,
                    color: Colors.white24,
                  )
                : null,
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.firstName} ${user.lastName}'.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'AUTHORIZED NODE MEMBER',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.accentTeal,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributeSection(dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ATTRIBUTE MODIFICATION',
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: Colors.white24,
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField('FORENAME IDENTIFIER', user.firstName),
        const SizedBox(height: 16),
        _buildTextField('SURNAME EXTENSION', user.lastName),
        const SizedBox(height: 16),
        _buildTextField(
          'ENCRYPTED UPLINK (READ-ONLY)',
          user.email,
          enabled: false,
        ),
        const SizedBox(height: 16),
        _buildTextField('COMMUNICATION LINK', '+237 6XX XXX XXX'),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String initialValue, {
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: Colors.white24,
              letterSpacing: 1,
            ),
          ),
        ),
        TextFormField(
          initialValue: initialValue,
          enabled: enabled,
          style: TextStyle(
            fontSize: 13,
            color: enabled ? Colors.white : Colors.white24,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.01),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.02)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDangerZone() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.02),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.redAccent.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TERMINAL COMMANDS',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'ATTENTION: NODE TERMINATION WILL PERMANENTLY ERASE ALL REGISTRY DATA AND AUTHORIZED ACCESS.',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.white12,
              letterSpacing: 1,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _confirmDelete(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'PURGE_IDENTITY_NODE',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleUpdate(dynamic user) async {
    setState(() => _isUpdating = true);
    try {
      await ref.read(authStateProvider.notifier).updateProfile({
        'first_name':
            user.firstName, // Note: You'd ideally have controllers for these
        'last_name': user.lastName,
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('NODE LOGIC UPDATED')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('UPDATE FAILED: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  void _showSettings(dynamic user) {
    // Local controllers for the modal
    final tareController = TextEditingController(
      text: user.tareWeight.toString(),
    );
    final capacityController = TextEditingController(
      text: user.gasCapacity.toString(),
    );
    String localSize =
        BottleProfiles.capacitiesKg.containsKey(user.preferredBottleSize)
        ? user.preferredBottleSize
        : 'MEDIUM_12_5KG';
    const supportedBrands = {
      'SCTM',
      'TOTAL_ENERGIES',
      'TRADEX',
      'STAR_GAS',
      'AZA_MRS',
      'GLOCAL_GAS',
      'BOCOM',
      'TOTAL',
      'GREEN_OIL',
      'CAMGAZ',
      'MRS',
      'AFT',
      'OTHER',
    };
    String localBrand = supportedBrands.contains(user.preferredBottleBrand)
        ? user.preferredBottleBrand
        : 'TOTAL_ENERGIES';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NODE CONFIGURATION SETTINGS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: Colors.white24,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Bottle Size Dropdown
                    _buildDropdown(
                      'BOTTLE_SIZE (FIXES CAPACITY)',
                      localSize,
                      ['SMALL_6KG', 'MEDIUM_12_5KG', 'BIG_50KG'],
                      (val) {
                        setModalState(() {
                          localSize = val;
                          // Auto-fix capacity based on size
                          capacityController.text = BottleProfiles.capacityFor(
                            val,
                          ).toStringAsFixed(2);

                          // Smart tare default for size
                          tareController.text = _calculateTare(
                            localSize,
                            localBrand,
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Bottle Brand Dropdown
                    _buildDropdown(
                      'PREFERRED_BOTTLE_BRAND',
                      localBrand,
                      [
                        'SCTM',
                        'TOTAL_ENERGIES',
                        'TRADEX',
                        'STAR_GAS',
                        'AZA_MRS',
                        'GLOCAL_GAS',
                        'BOCOM',
                        'TOTAL',
                        'GREEN_OIL',
                        'CAMGAZ',
                        'MRS',
                        'AFT',
                        'OTHER',
                      ],
                      (val) {
                        setModalState(() {
                          localBrand = val;
                          // Smart tare default for brand (keeping size into account)
                          tareController.text = _calculateTare(
                            localSize,
                            localBrand,
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Tare Weight (Manual Override)
                    _buildNumberField(
                      'EMPTY_BOTTLE_WEIGHT (TARE - KG)',
                      tareController,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Tare is an estimate. Check the stamped empty-bottle weight and edit it if needed.',
                        style: TextStyle(fontSize: 10, color: Colors.white54),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Gas Capacity (Fixed based on size)
                    _buildNumberField(
                      'GAS_CONTENT_WEIGHT (CAPACITY - KG)',
                      capacityController,
                      readOnly: true,
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            await ref
                                .read(authStateProvider.notifier)
                                .updateProfile({
                                  'preferred_bottle_size': localSize,
                                  'preferred_bottle_brand': localBrand,
                                  'tare_weight': tareController.text,
                                  'gas_capacity': capacityController.text,
                                });
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('CONFIGURATION SECURED'),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('CONFIGURATION FAILED: $e'),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentTeal,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'SAVE CONFIGURATION',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Logout
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ref.read(authStateProvider.notifier).logout();
                        },
                        child: const Text(
                          'LOGOUT',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Colors.white38,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),

                    // Delete Account
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _confirmDelete();
                        },
                        child: Text(
                          'TERMINATE_ACCOUNT',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: Colors.redAccent.withOpacity(0.5),
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _calculateTare(String size, String brand) {
    return BottleProfiles.estimatedTareFor(size, brand).toStringAsFixed(2);
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w900,
            color: Colors.white24,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: items.contains(value) ? value : items.first,
          dropdownColor: const Color(0xFF1E293B),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.01),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item.replaceAll('_', ' ')),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ],
    );
  }

  Widget _buildNumberField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w900,
            color: Colors.white24,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(
            color: readOnly ? Colors.white38 : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.01),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            suffixText: readOnly ? 'FIXED' : null,
            suffixStyle: const TextStyle(fontSize: 8, color: Colors.white24),
          ),
        ),
      ],
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'DANGER_PROTOCOL',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: Colors.redAccent,
            letterSpacing: 2,
          ),
        ),
        content: const Text(
          'TERMINATE IDENTITY NODE? THIS LOGIC CANNOT BE REVERSED.',
          style: TextStyle(fontSize: 14, color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ABORT'),
          ),
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);
              navigator.pop();
              try {
                await ref.read(authStateProvider.notifier).deleteAccount();
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('TERMINATION FAILED: $e')),
                  );
                }
              }
            },
            child: const Text(
              'CONFIRM PURGE',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettingsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SYSTEM SETTINGS',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Colors.white24,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.notifications_active_outlined,
              color: AppTheme.accentTeal,
            ),
            title: const Text(
              'Notifications & Vocal Alarms',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text(
              'Configure voice synthesis and push alerts',
              style: TextStyle(color: Colors.white30, fontSize: 11),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white30),
            onTap: () => GoRouter.of(context).push('/settings'),
          ),
        ],
      ),
    );
  }
}
