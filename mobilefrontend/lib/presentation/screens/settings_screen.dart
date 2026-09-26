import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/bottle_profiles.dart';
import '../../domain/providers/auth_provider.dart';
import '../../domain/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Profile Section
          _buildSectionHeader(context, 'PROFILE'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.accentTeal.withOpacity(0.1),
                  child: const Icon(
                    Icons.person,
                    color: AppTheme.accentTeal,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user?.firstName} ${user?.lastName}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      user?.email ?? '',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Notifications Section
          _buildSectionHeader(context, 'NOTIFICATIONS'),
          _buildToggleTile(
            context,
            'Push Notifications',
            settings.pushNotificationsEnabled,
            (v) {
              settingsNotifier.setPushNotificationsEnabled(v);
            },
          ),
          _buildToggleTile(
            context,
            'Email Alerts',
            settings.emailAlertsEnabled,
            (v) {
              settingsNotifier.setEmailAlertsEnabled(v);
            },
          ),
          _buildToggleTile(
            context,
            'Critical Low Level SMS',
            settings.smsAlertsEnabled,
            (v) {
              settingsNotifier.setSmsAlertsEnabled(v);
            },
          ),
          const SizedBox(height: 32),

          // Alarm audio Section
          _buildSectionHeader(context, 'SYSTEM AUDIO ALARM'),
          _buildToggleTile(
            context,
            'Gas Leak Audio Alarm',
            settings.audioAlarmEnabled,
            (v) {
              settingsNotifier.setAudioAlarmEnabled(v);
            },
          ),
          const SizedBox(height: 32),

          // Gas Bottle Configuration Section
          _buildSectionHeader(context, 'GAS BOTTLE CONFIGURATION'),
          const SizedBox(height: 16),
          _GasBottleSettingsCard(user: user),
          const SizedBox(height: 32),

          // Thresholds
          _buildSectionHeader(context, 'ALERTS & THRESHOLDS'),
          const SizedBox(height: 16),
          _buildSliderTile(
            context,
            'Low Level Warning',
            settings.lowLevelWarningThreshold,
            (v) {
              settingsNotifier.setLowLevelWarningThreshold(v);
            },
          ),
          const SizedBox(height: 48),

          // Logout
          TextButton.icon(
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
            icon: const Icon(Icons.logout, color: AppTheme.criticalRed),
            label: const Text(
              'TERMINATE SESSION',
              style: TextStyle(color: AppTheme.criticalRed, letterSpacing: 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(title, style: Theme.of(context).textTheme.labelSmall);
  }

  Widget _buildToggleTile(
    BuildContext context,
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.accentTeal,
      ),
    );
  }

  Widget _buildSliderTile(
    BuildContext context,
    String title,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
            Text(
              '${value.toInt()}%',
              style: const TextStyle(
                color: AppTheme.accentTeal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 5,
          max: 40,
          onChanged: onChanged,
          activeColor: AppTheme.accentTeal,
          inactiveColor: Colors.white.withOpacity(0.05),
        ),
      ],
    );
  }
}

class _GasBottleSettingsCard extends ConsumerStatefulWidget {
  final dynamic user;
  const _GasBottleSettingsCard({required this.user});

  @override
  ConsumerState<_GasBottleSettingsCard> createState() =>
      _GasBottleSettingsCardState();
}

class _GasBottleSettingsCardState
    extends ConsumerState<_GasBottleSettingsCard> {
  late TextEditingController _tareController;
  late TextEditingController _capacityController;
  late String _selectedBrand;
  late String _selectedSize;
  bool _isSaving = false;

  final List<String> _brands = [
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
  ];
  final List<Map<String, String>> _sizes = [
    {'label': 'Small (6 kg)', 'value': 'SMALL_6KG'},
    {'label': 'Medium (12.5 kg)', 'value': 'MEDIUM_12_5KG'},
    {'label': 'Big (50 kg)', 'value': 'BIG_50KG'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedBrand = _brands.contains(widget.user?.preferredBottleBrand)
        ? widget.user!.preferredBottleBrand
        : 'TOTAL_ENERGIES';
    _selectedSize =
        BottleProfiles.capacitiesKg.containsKey(
          widget.user?.preferredBottleSize,
        )
        ? widget.user!.preferredBottleSize
        : 'MEDIUM_12_5KG';
    _tareController = TextEditingController(
      text:
          widget.user?.tareWeight ??
          BottleProfiles.estimatedTareFor(
            _selectedSize,
            _selectedBrand,
          ).toStringAsFixed(2),
    );
    _capacityController = TextEditingController(
      text: BottleProfiles.capacityFor(_selectedSize).toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _tareController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _onSizeChanged(String? newSize) {
    if (newSize == null) return;
    setState(() {
      _selectedSize = newSize;
      _tareController.text = BottleProfiles.estimatedTareFor(
        newSize,
        _selectedBrand,
      ).toStringAsFixed(2);
      _capacityController.text = BottleProfiles.capacityFor(
        newSize,
      ).toStringAsFixed(2);
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(authStateProvider.notifier).updateProfile({
        'preferred_bottle_brand': _selectedBrand,
        'preferred_bottle_size': _selectedSize,
        'tare_weight': _tareController.text.trim(),
        'gas_capacity': _capacityController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bottle configuration saved successfully!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save settings: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('BOTTLE BRAND', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _brands.contains(_selectedBrand)
                ? _selectedBrand
                : _brands.first,
            dropdownColor: const Color(0xFF1E293B),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.03),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _brands
                .map(
                  (b) => DropdownMenuItem(
                    value: b,
                    child: Text(b.replaceAll('_', ' ')),
                  ),
                )
                .toList(),
            onChanged: (val) => setState(() {
              _selectedBrand = val ?? _selectedBrand;
              _tareController.text = BottleProfiles.estimatedTareFor(
                _selectedSize,
                _selectedBrand,
              ).toStringAsFixed(2);
            }),
          ),
          const SizedBox(height: 16),
          Text(
            'BOTTLE SIZE / TYPE',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _sizes.any((s) => s['value'] == _selectedSize)
                ? _selectedSize
                : 'MEDIUM_12_5KG',
            dropdownColor: const Color(0xFF1E293B),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.03),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _sizes
                .map(
                  (s) => DropdownMenuItem(
                    value: s['value'],
                    child: Text(s['label']!),
                  ),
                )
                .toList(),
            onChanged: _onSizeChanged,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TARE WEIGHT (KG)',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _tareController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.03),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        helperText:
                            'Estimate only; verify and edit to match the empty bottle stamp.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GAS CAPACITY (KG)',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _capacityController,
                      readOnly: true,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.03),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveSettings,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Icon(Icons.save, color: Colors.black),
              label: Text(
                _isSaving ? 'SAVING...' : 'SAVE BOTTLE CONFIGURATION',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentTeal,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
