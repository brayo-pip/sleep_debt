import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/health_connect_provider.dart';
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
    final provider = Provider.of<HealthConnectProvider>(context);

    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final baseColor = AppColors.getDebtColor(debtHours);
    
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1500),
              builder: (context, value, _) => CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 10,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(baseColor),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: debtHours),
                duration: const Duration(milliseconds: 1500),
                builder: (context, value, _) => Text(
                  '${value.abs().toStringAsFixed(1)}h',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: baseColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                debtHours >= 0 ? 'Sleep Debt' : 'Sleep Surplus',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
