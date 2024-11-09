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
    // Calculate color based on debt (0h = green, 20h = red)
    final debtRatio = math.min(debtHours / 20.0, 1.0);  // Clamp to max 20h
    final color = Color.lerp(
      Colors.green,
      Colors.red,
      debtRatio,
    )!;
    
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: CircularProgressIndicator(
              value: 1.0, // Always full circle
              strokeWidth: 12,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
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
