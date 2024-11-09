import 'package:flutter/material.dart';
import 'package:flutter_health_connect/flutter_health_connect.dart';
import '../theme/app_theme.dart';

class WeeklySleepTrend extends StatelessWidget {
  final List<SleepSessionRecord> sleepRecords;

  const WeeklySleepTrend({
    super.key,
    required this.sleepRecords,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    
    // Get today's weekday index (0-6, Sunday = 0)
    final todayIndex = now.weekday % 7;
    
    // Create a list of the last 7 days' indices, starting from 7 days ago
    final dayIndices = List.generate(7, (index) {
      // Calculate backwards from today
      return (todayIndex - 6 + index) % 7;
    });

    // Create a map of date string to sleep duration for the last 7 days
    final Map<String, Duration> sleepByDay = {};
    for (var record in sleepRecords) {
      final dateStr = '${record.startTime.year}-${record.startTime.month}-${record.startTime.day}';
      final duration = record.endTime.difference(record.startTime);
      sleepByDay[dateStr] = duration;
    }

    // Get the last 7 days as date strings
    final last7Days = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return '${date.year}-${date.month}-${date.day}';
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (index) {
            final weekdayIndex = dayIndices[index];
            final dateStr = last7Days[index];
            final duration = sleepByDay[dateStr] ?? const Duration();
            final hours = duration.inHours;
            final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
            
            return Column(
              children: [
                Column(
                  children: [
                    Text(
                      weekDays[weekdayIndex],
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: index == 6 ? Colors.white : Colors.grey,
                        fontWeight: index == 6 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      duration.inMinutes > 0 
                        ? '${hours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}' 
                        : '-:--',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: index == 6 ? FontWeight.bold : FontWeight.normal,
                        color: duration.inMinutes > 0 
                          ? duration.inMinutes >= (8 * 60) 
                            ? Colors.green 
                            : Colors.red
                          : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
