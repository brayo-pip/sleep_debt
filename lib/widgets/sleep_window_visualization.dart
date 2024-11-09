import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sleep_window_calculator.dart';
import '../providers/health_connect_provider.dart';

class SleepWindowVisualization extends StatelessWidget {
  final double sleepDebt;
  final TimeOfDay? lastSleepTime;
  final TimeOfDay? lastWakeTime;

  const SleepWindowVisualization({
    super.key,
    this.sleepDebt = 0.0,
    this.lastSleepTime,
    this.lastWakeTime,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<HealthConnectProvider>(context);
    final recentWakeTimes = provider.getRecentWakeTimes();
    final lastSleepTimes = provider.getLastSleepTimes();
    
    final windows = SleepWindowCalculator.calculateSleepWindows(
      sleepDebt: sleepDebt,
      lastSleepTime: lastSleepTimes.sleepTime,
      lastWakeTime: lastSleepTimes.wakeTime,
      recentWakeTimes: recentWakeTimes,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommended Sleep Schedule',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Optimal bedtime section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bedtime',
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      SleepWindowCalculator.formatTimeOfDay(windows.optimalBed),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Wake time',
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      SleepWindowCalculator.formatTimeOfDay(windows.optimalWake),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Sleep duration info
            Text(
              'Recommended Sleep: ${(windows.optimalSleep.inMinutes / 60).toStringAsFixed(1)} hours',
              style: theme.textTheme.titleMedium,
            ),
            if (sleepDebt > 0) ...[
              const SizedBox(height: 8),
              Text(
                sleepDebt >= SleepWindowCalculator.minDebtForRecovery
                  ? '(Including up to ${SleepWindowCalculator.maxExtraPerNight} hour extra for sleep debt recovery)'
                  : '(Sleep debt too low for recovery mode)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
