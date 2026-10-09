import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/bottle_profiles.dart';
import '../../domain/providers/dashboard_provider.dart';
import '../../domain/providers/auth_provider.dart';
import '../../data/models/dashboard_models.dart';
import '../widgets/gas_gauge.dart';
import '../widgets/cookable_foods_widget.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensorsAsync = ref.watch(sensorsProvider);
    final readingsAsync = ref.watch(dailyReadingsProvider);
    final authState = ref.watch(authStateProvider);

    final user = authState.user;
    final bottleSize = user?.preferredBottleSize ?? 'MEDIUM_12_5KG';
    final capacity = BottleProfiles.capacityFor(bottleSize);
    final dailyUsage =
        readingsAsync.valueOrNull
            ?.where((reading) => reading.consumption > 0)
            .map((reading) => reading.consumption)
            .toList() ??
        const <double>[];
    final averageDailyUsage = dailyUsage.isEmpty
        ? 0.0
        : dailyUsage.reduce((a, b) => a + b) / dailyUsage.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GaSX',
          style: TextStyle(
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none,
              color: AppTheme.accentTeal,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: sensorsAsync.when(
        data: (sensors) {
          if (sensors.isEmpty) {
            return const Center(child: Text('No gas sensors found.'));
          }
          final sensor = sensors.first;
          final predictionAsync = ref.watch(predictionProvider(sensor.id));
          final tareWeight =
              double.tryParse(user?.tareWeight ?? '') ?? capacity;
          final hasGrossWeight = sensor.rawWeight > 0;
          final remainingGasKg = hasGrossWeight
              ? BottleProfiles.remainingGasFromGrossWeight(
                  grossWeightKg: sensor.rawWeight,
                  tareWeightKg: tareWeight,
                  bottleSize: bottleSize,
                )
              : sensor.currentLevel.clamp(0.0, capacity).toDouble();
          final gasPercentage = hasGrossWeight
              ? (remainingGasKg / capacity * 100).clamp(0.0, 100.0).toDouble()
              : sensor.currentGasPercentage.clamp(0.0, 100.0).toDouble();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gas Gauge Section
                Center(
                  child: GasGauge(level: gasPercentage, capacity: capacity),
                ),
                const SizedBox(height: 24),

                // 1.5 Remote Gas Valve Control Card
                _buildValveControlCard(context, ref, sensor),
                const SizedBox(height: 32),

                // 2. AI Prediction Section
                predictionAsync.when(
                  data: (prediction) =>
                      _buildEnhancedPredictionCard(context, prediction),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),

                // 3. Stats Section
                _buildNodeMetadata(context, sensor, user, capacity),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'STATUS',
                        sensor.isActive ? 'READY' : 'OFFLINE',
                        sensor.isActive
                            ? AppTheme.accentTeal
                            : Colors.redAccent,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'AVG DAILY USE',
                        '${averageDailyUsage.toStringAsFixed(2)} kg/d',
                        AppTheme.accentBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 4. Cookable Foods Section
                CookableFoodsWidget(sensorId: sensor.id),
                const SizedBox(height: 32),

                // 4. Consumption Chart Section
                Text(
                  'DAILY USE (30 DAYS)',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: readingsAsync.when(
                    data: (readings) => _buildChart(readings),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) =>
                        const Center(child: Text('Error loading chart')),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildEnhancedPredictionCard(
    BuildContext context,
    dynamic prediction,
  ) {
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
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: AppTheme.accentTeal,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'GAS USE ESTIMATE',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppTheme.accentTeal),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Text(
                  prediction.trend == 'collecting' ||
                          prediction.daysRemaining == 0
                      ? '--'
                      : '${prediction.daysRemaining.toInt()}',
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),
                Text(
                  prediction.trend == 'collecting'
                      ? 'LEARNING YOUR GAS USE…'
                      : 'ESTIMATED DAYS OF GAS LEFT',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _buildSubPredictionStat(
                  'ESTIMATE ACCURACY',
                  '${(prediction.confidenceScore * 100).toInt()}%',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSubPredictionStat(
                  'GAS USE TREND',
                  prediction.trend.toUpperCase(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.accentTeal.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.accentTeal.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SUGGESTION',
                  style: TextStyle(
                    fontSize: 8,
                    color: AppTheme.accentTeal,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  prediction.recommendation,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubPredictionStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              color: Colors.white24,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.accentTeal,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeMetadata(
    BuildContext context,
    dynamic sensor,
    dynamic user,
    double capacity,
  ) {
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
          Text('SENSOR DETAILS', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 20),
          _buildMetadataRow('SENSOR ID', sensor.sensorId),
          _buildMetadataRow('DEVICE TYPE', 'GAS SENSOR'),
          _buildMetadataRow(
            'BOTTLE WEIGHT',
            '${sensor.rawWeight.toStringAsFixed(2)} KG',
          ),
          _buildMetadataRow(
            'BOTTLE CAPACITY',
            '${capacity.toStringAsFixed(2)} KG',
          ),
          _buildMetadataRow(
            'EMPTY BOTTLE WEIGHT',
            '${user?.tareWeight ?? "12.50"} KG',
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: Colors.white12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white60,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
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
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(List<DailyConsumption> readings) {
    if (readings.isEmpty) {
      return const Center(child: Text('No data for this range'));
    }

    // Sort readings by date just in case
    final sortedReadings = [...readings]
      ..sort((a, b) => a.date.compareTo(b.date));

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(sortedReadings.length, (index) {
              return FlSpot(
                index.toDouble(),
                sortedReadings[index].consumption,
              );
            }),
            isCurved: true,
            color: AppTheme.accentTeal,
            barWidth: 4,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.accentTeal.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValveControlCard(
    BuildContext context,
    WidgetRef ref,
    dynamic sensor,
  ) {
    final desiredValveOpen = sensor.desiredValveState.toUpperCase() == 'OPEN';
    final actualValveOpen = sensor.currentValveState.toUpperCase() == 'OPEN';
    final valvePending = desiredValveOpen != actualValveOpen;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: actualValveOpen
              ? AppTheme.accentTeal.withOpacity(0.2)
              : Colors.redAccent.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: actualValveOpen
                  ? AppTheme.accentTeal.withOpacity(0.1)
                  : Colors.redAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              actualValveOpen ? Icons.vaping_rooms : Icons.lock_clock,
              color: actualValveOpen ? AppTheme.accentTeal : Colors.redAccent,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GAS VALVE CONTROL',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white38,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  actualValveOpen
                      ? 'VALVE OPEN (GAS FLOW ON)'
                      : 'VALVE CLOSED (GAS FLOW CUT OFF)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: actualValveOpen
                        ? AppTheme.accentTeal
                        : Colors.redAccent,
                  ),
                ),
                if (valvePending) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Waiting for device to ${desiredValveOpen ? 'open' : 'close'}',
                    style: const TextStyle(fontSize: 10, color: Colors.white54),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: desiredValveOpen,
            activeColor: AppTheme.accentTeal,
            inactiveThumbColor: Colors.redAccent,
            onChanged: (bool newOpenState) async {
              final targetCmd = newOpenState ? 'OPEN' : 'CLOSE';
              try {
                await ref
                    .read(sensorsProvider.notifier)
                    .controlValve(sensor.id, targetCmd);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Valve command sent: $targetCmd')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to send valve command: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
