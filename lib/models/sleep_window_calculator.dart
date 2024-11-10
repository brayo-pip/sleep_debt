import 'package:flutter/material.dart';

class SleepWindows {
  final TimeOfDay earliestBed;
  final TimeOfDay optimalBed;
  final TimeOfDay latestBed;
  final TimeOfDay earliestWake;
  final TimeOfDay optimalWake;
  final TimeOfDay latestWake;
  final Duration optimalSleep;

  SleepWindows({
    required this.earliestBed,
    required this.optimalBed,
    required this.latestBed,
    required this.earliestWake,
    required this.optimalWake,
    required this.latestWake,
    required this.optimalSleep,
  });
}

class SleepWindowCalculator {
  static const double baseTargetHours = 8.0;
  static const double maxExtraPerNight = 1.0;  // Max 1 hour extra for recovery
  static const double minDebtForRecovery = 5.0;  // Minimum debt to trigger recovery
  static const int recoveryDays = 7;  // Spread recovery over a week
  static const int flexibilityMinutes = 30;  // Window flexibility each way
  
  static SleepWindows calculateSleepWindows({
    required double sleepDebt,
    TimeOfDay? lastWakeTime,
    TimeOfDay? lastSleepTime,
    List<TimeOfDay>? recentWakeTimes,
    TimeOfDay defaultWakeTime = const TimeOfDay(hour: 7, minute: 0),
  }) {
    // Calculate recovery sleep if needed
    double extraSleepHours = 0.0;
    if (sleepDebt >= minDebtForRecovery) {
      final double dailyRecovery = sleepDebt / recoveryDays;
      extraSleepHours = dailyRecovery.clamp(0.0, maxExtraPerNight);
    }

    // Calculate optimal sleep duration
    final Duration optimalSleep = Duration(
      minutes: ((baseTargetHours + extraSleepHours) * 60).round()
    );

    // Determine target wake time based on recent patterns
    TimeOfDay targetWakeTime;
    if (recentWakeTimes != null && recentWakeTimes.isNotEmpty) {
      // Calculate average wake time from recent history
      int totalMinutes = 0;
      for (final time in recentWakeTimes) {
        totalMinutes += _timeOfDayToMinutes(time);
      }
      final int avgMinutes = totalMinutes ~/ recentWakeTimes.length;
      targetWakeTime = _minutesToTimeOfDay(avgMinutes);
    } else if (lastWakeTime != null) {
      // Use last wake time if available
      targetWakeTime = lastWakeTime;
    } else {
      // Fall back to default
      targetWakeTime = defaultWakeTime;
    }

    // Calculate optimal bedtime based on target wake time and sleep duration
    int optimalMinutes = _timeOfDayToMinutes(targetWakeTime) - optimalSleep.inMinutes;
    
    // If they have a recent sleep time, average it with optimal time
    if (lastSleepTime != null) {
      final int lastBedMinutes = _timeOfDayToMinutes(lastSleepTime);
      optimalMinutes = (optimalMinutes + lastBedMinutes) ~/ 2;
    }
    
    final TimeOfDay optimalBed = _minutesToTimeOfDay(optimalMinutes);
    
    // Calculate windows with flexibility
    final TimeOfDay earliestBed = _minutesToTimeOfDay(optimalMinutes - flexibilityMinutes);
    final TimeOfDay latestBed = _minutesToTimeOfDay(optimalMinutes + flexibilityMinutes);
    
    final TimeOfDay earliestWake = _minutesToTimeOfDay(_timeOfDayToMinutes(targetWakeTime) - flexibilityMinutes);
    final TimeOfDay optimalWake = targetWakeTime;
    final TimeOfDay latestWake = _minutesToTimeOfDay(_timeOfDayToMinutes(targetWakeTime) + flexibilityMinutes);

    return SleepWindows(
      earliestBed: earliestBed,
      optimalBed: optimalBed,
      latestBed: latestBed,
      earliestWake: earliestWake,
      optimalWake: optimalWake,
      latestWake: latestWake,
      optimalSleep: optimalSleep,
    );
  }

  static Duration calculateSleepDuration(TimeOfDay bedTime, TimeOfDay wakeTime) {
    final int bedMinutes = _timeOfDayToMinutes(bedTime);
    int wakeMinutes = _timeOfDayToMinutes(wakeTime);
    
    // Handle crossing midnight
    if (wakeMinutes < bedMinutes) {
      wakeMinutes += 24 * 60;  // Add 24 hours
    }
    
    return Duration(minutes: wakeMinutes - bedMinutes);
  }

  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  static int _timeOfDayToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  static TimeOfDay _minutesToTimeOfDay(int minutes) {
    // Handle negative minutes and minutes > 24 hours
    minutes = ((minutes % (24 * 60)) + (24 * 60)) % (24 * 60);
    return TimeOfDay(
      hour: (minutes ~/ 60),
      minute: (minutes % 60),
    );
  }
}
