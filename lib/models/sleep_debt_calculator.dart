import 'dart:math';
import 'package:flutter_health_connect/flutter_health_connect.dart';
import 'dart:collection';

class SleepDebtCalculator {
  static const double targetSleepHours =
      7.0; // Minimum target for debt calculation
  static const double recommendedSleepHours =
      8.0; // Recommended for optimal health
  static const double maxDailyDebt = 16.0;
  static const double maxTotalDebt = 40.0;
  static const double recoveryRate = 0.4;
  static const int daysToTrack = 7;
  // Public constants for consistent use across the app
  static const double decayFactor = 0.9; // Weight decay per day

  // Disable smoothing for now
  static const double smoothingFactor = 0.0; // EMA smoothing factor

  double _currentDebt = 0.0;
  double _smoothedDebt = 0.0;
  final List<double> _weeklyAverages = [];
  final Queue<double> _dailyAverages = Queue();

  // Getters
  double get currentDebt => _smoothedDebt; // Return smoothed debt
  List<double> get weeklyAverages => List.unmodifiable(_weeklyAverages);

  void calculateDebtFromDailySleep(Map<DateTime, double> dailySleepHours) {
    // Reset current calculations
    _currentDebt = 0.0;
    _weeklyAverages.clear();
    _dailyAverages.clear();

    if (dailySleepHours.isEmpty) return;

    // Sort days chronologically
    final sortedDays = dailySleepHours.keys.toList()..sort();

    // Get the most recent date for relative weighting
    final mostRecentDate = sortedDays.last;
    double totalDebt = 0.0;

    // Calculate debt for each day
    for (final day in sortedDays) {
      final hours = dailySleepHours[day]!;
      final daysAgo = mostRecentDate.difference(day).inDays;
      final double dailyDifference = targetSleepHours - hours;

      if (dailyDifference > 0) {
        // Calculate debt with decay only applied to debt accumulation
        double dailyDebt = min(dailyDifference, maxDailyDebt);
        dailyDebt *= pow(decayFactor, daysAgo).toDouble();
        if (_dailyAverages.length >= 14) {
          _dailyAverages.removeFirst();
        }
        _dailyAverages.add(dailyDebt);
        totalDebt += dailyDebt;
      } else {
        // Recovery hours without decay
        final double recoveryHours = dailyDifference.abs() * recoveryRate;
        totalDebt = max(0, totalDebt - recoveryHours);
        if (_dailyAverages.length >= 14) {
          _dailyAverages.removeFirst();
        }
        _dailyAverages.add(0);
      }
    }

    // Cap the raw debt
    final double rawDebt = min(totalDebt, maxTotalDebt);

    // Apply EMA smoothing
    _smoothedDebt =
        (rawDebt * (1 - smoothingFactor)) + (_smoothedDebt * smoothingFactor);

    // Store raw debt for internal calculations
    _currentDebt = rawDebt;

    // Update weekly averages if we have enough data
    if (sortedDays.length >= 7) {
      final lastWeekHours = sortedDays
          .sublist(sortedDays.length - 7)
          .map((day) => dailySleepHours[day]!)
          .toList();
      final weeklyAvg = _calculateWeightedAverage(lastWeekHours);
      _weeklyAverages.add(weeklyAvg);
    }
  }

  double _calculateWeightedAverage(List<double> weekRecords) {
    double weightedSum = 0.0;
    double totalSleepDays = 0.0;

    // Calculate weighted average with more recent days having higher weight
    for (int i = 0; i < weekRecords.length; i++) {
      final weight = pow(decayFactor, weekRecords.length - 1 - i).toDouble();
      weightedSum += weekRecords[i] * weight;
      totalSleepDays += 1;
    }

    return weightedSum / totalSleepDays;
  }

  String getDebtTrend() {
    if (_weeklyAverages.length < 2) {
      final daysTracked = _dailyAverages.length;
      if (daysTracked < 2) {
        return 'No trend yet, check back tomorrow';
      }
      // calculate the average for the first half
      final firstHalf = _dailyAverages.take(daysTracked ~/ 2).toList();
      final secondHalf = _dailyAverages.skip(daysTracked ~/ 2).toList();
      final firstHalfAvg = _calculateWeightedAverage(firstHalf);
      final secondHalfAvg = _calculateWeightedAverage(secondHalf);
      if (secondHalfAvg > firstHalfAvg) {
        return 'Improving';
      } else if (secondHalfAvg < firstHalfAvg) {
        return 'Worsening';
      } else {
        return 'Stable';
      }
    }

    final double currentWeek = _weeklyAverages.last;
    final double previousWeek = _weeklyAverages[_weeklyAverages.length - 2];

    if (currentWeek > previousWeek) {
      return 'Improving';
    } else if (currentWeek < previousWeek) {
      return 'Worsening';
    } else {
      return 'Stable';
    }
  }

  int getRecoveryEstimate() {
    if (_currentDebt == 0) {
      return 0;
    }

    const double extraSleepPerDay = 1.0;
    const double recoveryPerDay = extraSleepPerDay * recoveryRate;
    return (_currentDebt / recoveryPerDay).ceil();
  }

  Map<String, dynamic> getSleepStats(Map<DateTime, double> dailySleepHours) {
    if (dailySleepHours.isEmpty) {
      return {
        'averageSleep': 0.0,
        'minSleep': 0.0,
        'maxSleep': 0.0,
        'rawDebt': 0.0,
        'currentDebt': 0.0, // smoothed debt
        'trend': 'No data',
        'recoveryDays': 0,
        'dailySleep': <DateTime, double>{},
      };
    }

    calculateDebtFromDailySleep(dailySleepHours);

    final sleepHours = dailySleepHours.values.toList();

    return {
      'averageSleep': _calculateWeightedAverage(sleepHours),
      'minSleep': sleepHours.reduce(min),
      'maxSleep': sleepHours.reduce(max),
      'rawDebt': _currentDebt,
      'currentDebt': _smoothedDebt, // smoothed debt
      'trend': getDebtTrend(),
      'recoveryDays': getRecoveryEstimate(),
      'dailySleep': Map<DateTime, double>.from(dailySleepHours),
    };
  }
}
