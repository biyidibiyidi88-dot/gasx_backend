import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/providers/notification_provider.dart';
import '../../data/models/notification_models.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  String _activeFilter = 'unread';

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('COMMUNICATION', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white24)),
            Text('NODE INTELLIGENCE', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showSettings(context),
            icon: const Icon(Icons.tune, color: AppTheme.accentTeal),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          final filtered = _filterNotifications(notifications);
          if (filtered.isEmpty) return _buildEmptyState();

          return Column(
            children: [
              _buildFilters(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _buildNotificationCard(context, filtered[index]),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildFilters() {
    final filters = [
      {'value': 'all', 'label': 'MATRIX'},
      {'value': 'unread', 'label': 'UNRESOLVED'},
      {'value': 'alerts', 'label': 'ANOMALIES'},
      {'value': 'system', 'label': 'CORE LOG'},
    ];

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isActive = _activeFilter == filter['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => setState(() => _activeFilter = filter['value']!),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.accentTeal : Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isActive ? AppTheme.accentTeal : Colors.white.withOpacity(0.05)),
                ),
                alignment: Alignment.center,
                child: Text(
                  filter['label']!,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: isActive ? Colors.black : Colors.white38,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<NotificationModel> _filterNotifications(List<NotificationModel> notifications) {
    if (_activeFilter == 'all') return notifications;
    if (_activeFilter == 'unread') return notifications.where((n) => !n.isResolved).toList();
    if (_activeFilter == 'alerts') return notifications.where((n) => n.alertType != 'SYSTEM').toList();
    if (_activeFilter == 'system') return notifications.where((n) => n.alertType == 'SYSTEM').toList();
    return notifications;
  }

  Widget _buildNotificationCard(BuildContext context, NotificationModel n) {
    final color = _getSeverityColor(n.severityLevel, n.isResolved);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: Container(color: color),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_getIcon(n.alertType), color: color, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('HH:mm').format(n.triggeredAt),
                            style: const TextStyle(fontSize: 9, color: Colors.white24, fontWeight: FontWeight.w900, letterSpacing: 1),
                          ),
                          if (!n.isResolved)
                            const Text('UNRESOLVED', style: TextStyle(fontSize: 8, color: AppTheme.accentTeal, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        n.alertMessage.toUpperCase(),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(n.sensorName ?? 'SYSTEM GRID', style: TextStyle(fontSize: 9, color: AppTheme.accentTeal.withOpacity(0.6), fontWeight: FontWeight.w900, letterSpacing: 1)),
                          const SizedBox(width: 8),
                          const Icon(Icons.circle, size: 4, color: Colors.white10),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(n.houseAddress ?? 'CORE LOCATION', style: const TextStyle(fontSize: 9, color: Colors.white24, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis)),
                          ),
                        ],
                      ),
                      if (!n.isResolved) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => _resolve(n.id),
                              child: const Text('RESOLVE_LOG', style: TextStyle(fontSize: 9, color: AppTheme.accentTeal, fontWeight: FontWeight.w900, letterSpacing: 1)),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String level, bool isResolved) {
    if (isResolved) return Colors.white10;
    switch (level) {
      case 'CRITICAL': return Colors.redAccent;
      case 'HIGH': return Colors.orangeAccent;
      default: return AppTheme.accentTeal;
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'GAS_LEAK': return Icons.warning_rounded;
      case 'SYSTEM': return Icons.settings_input_component_rounded;
      default: return Icons.info_outline_rounded;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 24),
          const Text('ZERO DEVIATIONS DETECTED', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: Colors.white24)),
          const SizedBox(height: 8),
          const Text('ALL NODES OPERATING WITHIN NOMINAL RANGE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white10, letterSpacing: 2)),
        ],
      ),
    );
  }

  void _resolve(int id) async {
    await ref.read(notificationRepositoryProvider).markAsRead(id);
    ref.invalidate(notificationsProvider);
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('TRANSMISSION RULES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 4, color: AppTheme.accentTeal)),
            const SizedBox(height: 32),
            _buildSettingToggle('SMTP_LINK', true),
            _buildSettingToggle('DIRECT_NOTIFY', true),
            _buildSettingToggle('BINARY_SMS', false),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentTeal,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('APPLY CONFIGURATION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingToggle(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white60, letterSpacing: 1)),
          Switch(
            value: value,
            onChanged: (v) {},
            activeColor: AppTheme.accentTeal,
          ),
        ],
      ),
    );
  }
}
