import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dio_provider.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/models/notification_models.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/audio_alarm_service.dart';
import 'settings_provider.dart';
import 'websocket_provider.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return NotificationRepository(dio);
});

class NotificationsNotifier extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final NotificationRepository _repository;
  final Ref _ref;
  StreamSubscription? _subscription;

  NotificationsNotifier(this._repository, this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    await _fetch();
    _subscribeToWebSocket();
  }

  Future<void> _fetch({bool showPushNotification = false}) async {
    try {
      final oldList = state.valueOrNull ?? [];
      final data = await _repository.getNotifications();
      state = AsyncValue.data(data);

      if (showPushNotification && oldList.isNotEmpty) {
        final oldIds = oldList.map((n) => n.id).toSet();
        // Identify new, unresolved alerts
        final newAlerts = data.where((n) => !oldIds.contains(n.id) && !n.isResolved).toList();

        for (final notification in newAlerts) {
          await NotificationService.instance.showNotification(
            id: notification.id,
            title: _getAlertTitle(notification.alertType),
            body: notification.alertMessage,
          );

          if (notification.alertType == 'GAS_LEAK') {
            final settings = _ref.read(settingsProvider);
            if (settings.audioAlarmEnabled) {
              AudioAlarmService.instance.playAlarm();
            }
          }
        }
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  String _getAlertTitle(String type) {
    switch (type) {
      case 'GAS_LEAK':
        return '🚨 GAS LEAK DETECTED! 🚨';
      case 'GAS_LEVEL_LOW':
        return '⛽ LOW GAS LEVEL WARNING';
      case 'LOW_BATTERY':
        return '🔋 LOW BATTERY ENCOUNTERED';
      case 'SENSOR_OFFLINE':
        return '🔌 SENSOR HAS GONE OFFLINE';
      default:
        return '⚠️ GAS MONITOR ALARM';
    }
  }

  void _subscribeToWebSocket() {
    _subscription?.cancel();

    final wsClient = _ref.read(websocketClientProvider);
    _subscription = wsClient.stream.listen((event) {
      final type = event['type'];
      if (type == 'notifications') {
        // Re-fetch from REST and trigger push notifications for any new records
        _fetch(showPushNotification: true);
      }
    }, onError: (e) {
      print('WebSocket notifications subscription error: $e');
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, AsyncValue<List<NotificationModel>>>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return NotificationsNotifier(repo, ref);
});
