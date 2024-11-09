import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DebtTrendPanel extends StatelessWidget {
  final double weeklyChange;
  final bool isImproving;

  const DebtTrendPanel({
    super.key,
    required this.weeklyChange,
    required this.isImproving,
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
              'Weekly Trend',
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
                    color: (isImproving ? AppColors.primary : AppColors.warning).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isImproving 
                        ? Icons.trending_down 
                        : Icons.trending_up,
                    color: isImproving 
                        ? AppColors.greenLight 
                        : AppColors.warning,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isImproving 
                            ? 'Sleep debt is decreasing' 
                            : 'Sleep debt is increasing',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Average: ${weeklyChange.abs().toStringAsFixed(1)}h ${weeklyChange >= 0 ? 'over' : 'under'} target per night',
                        style: theme.textTheme.bodyMedium,
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
