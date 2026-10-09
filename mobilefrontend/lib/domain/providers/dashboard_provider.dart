import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dio_provider.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../data/models/dashboard_models.dart';
import '../../data/models/recipe.dart';
import 'websocket_provider.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return DashboardRepository(dio);
});

class SensorsNotifier extends StateNotifier<AsyncValue<List<GasSensor>>> {
  final DashboardRepository _repository;
  final Ref _ref;
  StreamSubscription? _subscription;
  Timer? _refreshTimer;
  bool _isFetching = false;

  SensorsNotifier(this._repository, this._ref)
    : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    // Subscribe before the first fetch so a reading that arrives during startup
    // is not missed. Polling keeps the dashboard fresh if a hosted WebSocket
    // connection is temporarily unavailable.
    _subscribeToWebSocket();
    await _fetch();
    _refreshTimer = Timer.periodic(const Duration(seconds: 4), (_) => _fetch());
  }

  Future<void> _fetch() async {
    if (_isFetching) return;
    _isFetching = true;
    try {
      final data = await _repository.getSensors();
      _publishSensors(data);
    } catch (e, st) {
      // Keep showing the last successful reading during a brief network outage.
      if (state.valueOrNull == null) {
        state = AsyncValue.error(e, st);
      }
    } finally {
      _isFetching = false;
    }
  }

  void _publishSensors(List<GasSensor> sensors) {
    final previous = state.valueOrNull ?? const <GasSensor>[];
    final changed =
        previous.length != sensors.length ||
        List.generate(
          previous.length,
          (index) => index,
        ).any((index) => previous[index] != sensors[index]);

    state = AsyncValue.data(sensors);
    if (!changed) return;

    for (final sensor in sensors) {
      _ref.invalidate(predictionProvider(sensor.id));
      _ref.invalidate(cookableFoodsProvider(sensor.id));
    }
    _ref.invalidate(dailyReadingsProvider);
  }

  void _subscribeToWebSocket() {
    // Cancel existing subscription before re-subscribing
    _subscription?.cancel();

    final wsClient = _ref.read(websocketClientProvider);
    _subscription = wsClient.stream.listen(
      (event) {
        final type = event['type'];
        final payload = event['data'];
        if (type == 'gas_sensors' && payload is List) {
          try {
            final sensors = payload
                .map(
                  (item) => GasSensor.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ),
                )
                .toList();
            _publishSensors(sensors);
          } catch (error) {
            // Fall back to REST if a server sends an older or unexpected shape.
            debugPrint('WebSocket sensor update could not be parsed: $error');
            _fetch();
          }
        }
      },
      onError: (e) {
        debugPrint('WebSocket sensors subscription error: $e');
      },
    );
  }

  Future<void> controlValve(int sensorId, String command) async {
    try {
      await _repository.controlValve(sensorId, command);
      await _fetch();
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}

final sensorsProvider =
    StateNotifierProvider<SensorsNotifier, AsyncValue<List<GasSensor>>>((ref) {
      final repo = ref.watch(dashboardRepositoryProvider);
      return SensorsNotifier(repo, ref);
    });

final dailyReadingsProvider = FutureProvider<List<DailyConsumption>>((
  ref,
) async {
  return ref.watch(dashboardRepositoryProvider).getDailyReadings();
});

final predictionProvider = FutureProvider.family<PredictionData, int>((
  ref,
  sensorId,
) async {
  return ref.watch(dashboardRepositoryProvider).getPrediction(sensorId);
});

final cookableFoodsProvider = FutureProvider.family<List<Recipe>, int>((
  ref,
  sensorId,
) async {
  return ref.watch(dashboardRepositoryProvider).getCookableFoods(sensorId);
});
