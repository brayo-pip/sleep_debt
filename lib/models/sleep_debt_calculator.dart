import 'dart:math';
import 'package:flutter_health_connect/flutter_health_connect.dart';

class SleepDebtCalculator {
  static const double targetSleepHours = 8.0;
  static const double maxDailyDebt = 16.0;
  static const double maxTotalDebt = 40.0;
  static const double recoveryRate = 0.4;
  static const int daysToTrack = 14;

  double _currentDebt = 0.0;
  final List<double> _weeklyAverages = [];

  // Getters
  double get currentDebt => _currentDebt;
  List<double> get weeklyAverages => List.unmodifiable(_weeklyAverages);

  void calculateDebtFromDailySleep(Map<DateTime, double> dailySleepHours) {
    // Reset current calculations
    _currentDebt = 0.0;
    _weeklyAverages.clear();

    if (dailySleepHours.isEmpty) return;

    // Sort days chronologically
    final sortedDays = dailySleepHours.keys.toList()
      ..sort();

    // Calculate debt for each day's sleep total
    for (final day in sortedDays) {
      final hours = dailySleepHours[day]!;
      final double dailyDifference = targetSleepHours - hours;

      if (dailyDifference > 0) {
        // Accumulate debt
        final double newDebt = min(dailyDifference, maxDailyDebt);
        _currentDebt = min(_currentDebt + newDebt, maxTotalDebt);
      } else {
        // Sleep recovery
        final double recoveryHours = dailyDifference.abs() * recoveryRate;
        _currentDebt = max(0, _currentDebt - recoveryHours);
      }
    }

    // Update weekly averages if we have enough data
    if (sortedDays.length >= 7) {
      final lastWeekHours = sortedDays
          .sublist(sortedDays.length - 7)
          .map((day) => dailySleepHours[day]!)
          .toList();
      final weeklyAvg = _calculateWeeklyAverage(lastWeekHours);
      _weeklyAverages.add(weeklyAvg);
    }
  }

  double _calculateWeeklyAverage(List<double> weekRecords) {
    return weekRecords.reduce((a, b) => a + b) / weekRecords.length;
  }

  String getDebtTrend() {
    if (_weeklyAverages.length < 2) {
      return 'Insufficient data';
    }

    final double currentWeek = _weeklyAverages.last;
    final double previousWeek = _weeklyAverages[_weeklyAverages.length - 2];

    if (currentWeek > previousWeek) {
      return 'Improving';
    } else if (currentWeek < previousWeek) {
      return 'Declining';
    } else {
      return 'Stable';
    }
  }

  int getRecoveryEstimate() {
    if (_currentDebt == 0) {
      return 0;
    }

    const double extraSleepPerDay = 1.0;
    final double recoveryPerDay = extraSleepPerDay * recoveryRate;
    return (_currentDebt / recoveryPerDay).ceil();
  }

  Map<String, dynamic> getSleepStats(Map<DateTime, double> dailySleepHours) {
    if (dailySleepHours.isEmpty) {
      return {
        'averageSleep': 0.0,
        'minSleep': 0.0,
        'maxSleep': 0.0,
        'currentDebt': 0.0,
        'trend': 'No data',
        'recoveryDays': 0,
        'dailySleep': <DateTime, double>{},
      };
    }

    calculateDebtFromDailySleep(dailySleepHours);

    final sleepHours = dailySleepHours.values.toList();

    return {
      'averageSleep': sleepHours.reduce((a, b) => a + b) / sleepHours.length,
      'minSleep': sleepHours.reduce(min),
      'maxSleep': sleepHours.reduce(max),
      'currentDebt': _currentDebt,
      'trend': getDebtTrend(),
      'recoveryDays': getRecoveryEstimate(),
      'dailySleep': Map<DateTime, double>.from(dailySleepHours),
    };
  }
}
