import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DebtTrendPanel extends StatelessWidget {
  final double rawDebt;
  final double smoothedDebt;
  final String trend;
  final Map<String, num> trendDetails;

  const DebtTrendPanel({
    super.key,
    required this.rawDebt,
    required this.smoothedDebt,
    required this.trend,
    required this.trendDetails,
  });

  bool get isImproving => trend == 'Improving';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sleep Trend',
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
                    color: _getTrendColor(theme).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getTrendIcon(),
                    color: _getTrendColor(theme),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sleep Debt: ${smoothedDebt.toStringAsFixed(1)}h',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getTrendDescription(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _getTrendColor(theme),
                        ),
                      ),
                      if (rawDebt != smoothedDebt) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Raw: ${rawDebt.toStringAsFixed(1)}h',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        _getDetailedTrendText(),
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

  IconData _getTrendIcon() {
    switch (trend) {
      case 'Improving':
        return Icons.trending_down;
      case 'Declining':
        return Icons.trending_up;
      case 'Stable':
        return Icons.trending_flat;
      default:
        return Icons.help_outline;
    }
  }

  Color _getTrendColor(ThemeData theme) {
    switch (trend) {
      case 'Improving':
        return AppColors.debtFree;
      case 'Declining':
        return AppColors.highDebt;
      case 'Stable':
        return theme.textTheme.bodyMedium?.color ?? Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getTrendDescription() {
    switch (trend) {
      case 'Improving':
        return 'Sleep pattern is improving';
      case 'Declining':
        return 'Sleep pattern is worsening';
      case 'Stable':
        return 'Sleep pattern is stable';
      default:
        return 'Not enough data';
    }
  }

  String _getDetailedTrendText() {
    if (trend == 'Insufficient data') {
      return 'Need at least 7 days of data';
    }

    final difference = trendDetails['difference'] as num;
    final firstHalfAvg = trendDetails['firstHalfAvg'] as num;
    final secondHalfAvg = trendDetails['secondHalfAvg'] as num;

    final changeText = difference.abs() < 0.1 
        ? 'no change'
        : '${difference.abs().toStringAsFixed(1)}h ${difference > 0 ? 'more' : 'less'}';

    return 'Recent average: ${secondHalfAvg.toStringAsFixed(1)}h ($changeText than previous)';
  }
}
