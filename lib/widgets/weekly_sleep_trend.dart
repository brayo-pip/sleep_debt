import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_connect_provider.dart';

class WeeklySleepTrend extends StatelessWidget {
  static const double targetSleepHours = 8.0;
  static const double maxDisplayHours = 12.0;
  
  const WeeklySleepTrend({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<HealthConnectProvider>();
    final stats = provider.stats;
    final dailySleep = stats['dailySleep'] as Map<DateTime, double>;
    
    final now = DateTime.now();
    final weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    
    // Get the last 7 days
    final last7Days = List.generate(7, (index) {
      return DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 6 - index));
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (index) {
            final date = last7Days[index];
            final weekdayIndex = date.weekday % 7;
            final hours = dailySleep[date] ?? 0.0;
            final isToday = index == 6;
            
            return Column(
              children: [
                Text(
                  weekDays[weekdayIndex],
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isToday ? Colors.white : Colors.grey,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hours > 0 
                    ? hours.toStringAsFixed(1) 
                    : '-.-',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: hours > 0 
                      ? hours >= 8.0
                        ? Colors.green 
                        : Colors.red
                      : Colors.grey,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
