import 'dart:async';
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

  SensorsNotifier(this._repository, this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    await _fetch();
    _subscribeToWebSocket();
  }

  Future<void> _fetch() async {
    try {
      final data = await _repository.getSensors();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void _subscribeToWebSocket() {
    // Cancel existing subscription before re-subscribing
    _subscription?.cancel();

    final wsClient = _ref.read(websocketClientProvider);
    _subscription = wsClient.stream.listen((event) {
      final type = event['type'];
      if (type == 'gas_sensors') {
        // Re-fetch from REST to guarantee fresh data
        _fetch().then((_) {
          // Invalidate dependent providers after sensors are updated
          final currentSensors = state.valueOrNull ?? [];
          for (final sensor in currentSensors) {
            _ref.invalidate(predictionProvider(sensor.id));
            _ref.invalidate(cookableFoodsProvider(sensor.id));
          }
          _ref.invalidate(dailyReadingsProvider);
        });
      }
    }, onError: (e) {
      print('WebSocket sensors subscription error: $e');
    });
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
    _subscription?.cancel();
    super.dispose();
  }
}

final sensorsProvider = StateNotifierProvider<SensorsNotifier, AsyncValue<List<GasSensor>>>((ref) {
  final repo = ref.watch(dashboardRepositoryProvider);
  return SensorsNotifier(repo, ref);
});

final dailyReadingsProvider = FutureProvider<List<DailyConsumption>>((ref) async {
  return ref.watch(dashboardRepositoryProvider).getDailyReadings();
});

final predictionProvider = FutureProvider.family<PredictionData, int>((ref, sensorId) async {
  return ref.watch(dashboardRepositoryProvider).getPrediction(sensorId);
});

final cookableFoodsProvider = FutureProvider.family<List<Recipe>, int>((ref, sensorId) async {
  return ref.watch(dashboardRepositoryProvider).getCookableFoods(sensorId);
});
