import 'dart:async';
import 'package:flutter/foundation.dart';
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

class NotificationsNotifier
    extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final NotificationRepository _repository;
  final Ref _ref;
  StreamSubscription? _subscription;
  Timer? _refreshTimer;
  final Set<int> _knownNotificationIds = {};
  bool _hasInitialSnapshot = false;
  bool _isFetching = false;

  NotificationsNotifier(this._repository, this._ref)
    : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    _subscribeToWebSocket();
    await _fetch();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) => _fetch());
  }

  Future<void> _fetch() async {
    if (_isFetching) return;
    _isFetching = true;
    try {
      final data = await _repository.getNotifications();
      state = AsyncValue.data(data);

      final newAlerts = _hasInitialSnapshot
          ? data
                .where(
                  (notification) =>
                      !_knownNotificationIds.contains(notification.id) &&
                      !notification.isResolved,
                )
                .toList()
          : const <NotificationModel>[];
      _knownNotificationIds
        ..clear()
        ..addAll(data.map((notification) => notification.id));
      _hasInitialSnapshot = true;

      for (final notification in newAlerts) {
        await NotificationService.instance.showNotification(
          id: notification.id,
          title: _getAlertTitle(notification.alertType),
          body: notification.alertMessage,
        );
      }

      // Keep the configured phone alarm active for as long as a leak is open.
      // This also handles an alert that was already active when the app opens.
      final hasActiveLeak = data.any(
        (notification) =>
            notification.alertType.toUpperCase() == 'GAS_LEAK' &&
            !notification.isResolved,
      );
      if (hasActiveLeak && _ref.read(settingsProvider).audioAlarmEnabled) {
        await AudioAlarmService.instance.playAlarm();
      } else {
        await AudioAlarmService.instance.stop();
      }
    } catch (e, st) {
      // Preserve the last known alerts while the connection is recovering.
      if (state.valueOrNull == null) {
        state = AsyncValue.error(e, st);
      }
    } finally {
      _isFetching = false;
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
    _subscription = wsClient.stream.listen(
      (event) {
        final type = event['type'];
        if (type == 'notifications') {
          _fetch();
        }
      },
      onError: (e) {
        debugPrint('WebSocket notifications subscription error: $e');
      },
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}

final notificationsProvider =
    StateNotifierProvider<
      NotificationsNotifier,
      AsyncValue<List<NotificationModel>>
    >((ref) {
      final repo = ref.watch(notificationRepositoryProvider);
      return NotificationsNotifier(repo, ref);
    });
