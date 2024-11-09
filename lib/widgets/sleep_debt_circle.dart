import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class SleepDebtCircleWidget extends StatelessWidget {
  final double debtHours;
  final double targetHours;

  const SleepDebtCircleWidget({
    super.key,
    required this.debtHours,
    required this.targetHours,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = math.max(0.0, math.min(1.0, 1 - (debtHours / (targetHours * 7))));
    
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 12,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.7 
                  ? Colors.green 
                  : progress > 0.4 
                    ? Colors.orange 
                    : Colors.red,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${debtHours.abs().toStringAsFixed(1)}h',
                style: theme.textTheme.headlineMedium,
              ),
              Text(
                debtHours >= 0 ? 'Sleep Debt' : 'Sleep Surplus',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
