import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TomorrowRecommendations extends StatelessWidget {
  final DateTime recommendedBedtime;
  final DateTime recommendedWakeTime;
  final Duration targetSleepDuration;

  const TomorrowRecommendations({
    super.key,
    required this.recommendedBedtime,
    required this.recommendedWakeTime,
    required this.targetSleepDuration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
              'Tomorrow\'s Plan',
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.bedtime,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recommended Sleep Schedule',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _TimeDisplay(
                            label: 'Bedtime',
                            time: recommendedBedtime,
                            context: context,
                          ),
                          _TimeDisplay(
                            label: 'Wake time',
                            time: recommendedWakeTime,
                            context: context,
                          ),
                          _DurationDisplay(
                            duration: targetSleepDuration,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeDisplay extends StatelessWidget {
  final String label;
  final DateTime time;
  final BuildContext context;

  const _TimeDisplay({
    required this.label,
    required this.time,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          TimeOfDay.fromDateTime(time).format(context),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.energy,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DurationDisplay extends StatelessWidget {
  final Duration duration;

  const _DurationDisplay({
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          '${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.energy,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
