import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LastNightSleepPanel extends StatelessWidget {
  String _formatDifference(Duration actual, Duration target) {
    final differenceMin = actual.inMinutes - target.inMinutes;
    final hours = differenceMin ~/ 60;
    final minutes = differenceMin.abs() % 60;
    
    final sign = differenceMin >= 0 ? '+' : '-';
    final hourStr = hours.abs().toString();
    final minStr = minutes.toString().padLeft(2, '0');
    
    return '$sign$hourStr:$minStr ${differenceMin >= 0 ? 'over' : 'under'} target';
  }

  final Duration? sleepDuration;
  final DateTime? sleepStart;
  final DateTime? sleepEnd;
  final double targetHours;

  const LastNightSleepPanel({
    super.key,
    required this.sleepDuration,
    required this.sleepStart,
    required this.sleepEnd,
    required this.targetHours,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (sleepDuration == null || sleepStart == null || sleepEnd == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Last Night\'s Sleep',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text('No sleep data recorded'),
            ],
          ),
        ),
      );
    }

    final hours = sleepDuration!.inHours;
    final minutes = sleepDuration!.inMinutes.remainder(60);
    final difference = sleepDuration!.inHours - targetHours;
    
    final timeFormat = TimeOfDay.fromDateTime(sleepStart!).format(context);
    final endTimeFormat = TimeOfDay.fromDateTime(sleepEnd!).format(context);

    return Card(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surface,
              AppColors.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Night\'s Sleep',
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${hours}:${minutes.toString().padLeft(2, '0')}',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDifference(sleepDuration!, Duration(hours: targetHours.toInt())),
                      style: TextStyle(
                        color: AppTheme.getSleepQualityColor(sleepDuration!),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$timeFormat - $endTimeFormat'),
                    const SizedBox(height: 4),
                    Text(
                      'Target: ${targetHours.toStringAsFixed(1)}h',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
