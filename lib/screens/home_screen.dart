import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_connect_provider.dart';
import '../widgets/sleep_debt_circle.dart';
import '../widgets/weekly_sleep_trend.dart';
import '../widgets/last_night_sleep_panel.dart';
import '../widgets/debt_trend_panel.dart';
import '../widgets/sleep_window_visualization.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthConnectProvider>(
      builder: (context, provider, child) {
        if (!provider.isInitialized) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.initialize(),
                  child: const Text('Initialize Health Connect'),
                ),
              ],
            ),
          );
        }

        final stats = provider.stats;
        final lastSleepDuration = provider.getLastNightSleep();
        final lastSleepStart = provider.getLastSleepStart();
        final lastSleepEnd = provider.getLastSleepEnd();
        
        return RefreshIndicator(
          onRefresh: provider.refreshSleepData,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 20),
              SleepDebtCircleWidget(
                debtHours: stats['currentDebt'],
                targetHours: 8.0,
              ),
              const SizedBox(height: 24),
              const WeeklySleepTrend(),
              const SizedBox(height: 16),
              LastNightSleepPanel(
                sleepDuration: lastSleepDuration,
                sleepStart: lastSleepStart,
                sleepEnd: lastSleepEnd,
                targetHours: 8.0,
              ),
              const SizedBox(height: 16),
              DebtTrendPanel(
                weeklyChange: stats['averageSleep'] - 8.0,
                isImproving: stats['trend'] == 'Improving',
              ),
              const SizedBox(height: 16),
              SleepWindowVisualization(
                sleepDebt: stats['currentDebt'] ?? 0.0,
                lastSleepTime: lastSleepStart != null 
                  ? TimeOfDay.fromDateTime(lastSleepStart)
                  : null,
                lastWakeTime: lastSleepEnd != null
                  ? TimeOfDay.fromDateTime(lastSleepEnd)
                  : null,
              ),
            ],
          ),
        );
      },
    );
  }
}
