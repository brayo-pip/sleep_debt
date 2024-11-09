import 'package:flutter/material.dart' show TimeOfDay, ChangeNotifier, debugPrint;
import 'package:flutter_health_connect/flutter_health_connect.dart';
import '../models/sleep_debt_calculator.dart';

class HealthConnectProvider extends ChangeNotifier {
  final SleepDebtCalculator _calculator = SleepDebtCalculator();
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  
  // Stats for UI
  Map<String, dynamic> get stats => _calculator.getSleepStats(_dailySleepHours);

  Future<void> initialize() async {
    try {
      // Check if Health Connect is supported
      final bool isSupported = await HealthConnectFactory.checkIfSupported();
      if (!isSupported) {
        throw Exception('Health Connect is not supported on this device');
      }

      // Check if Health Connect app is installed
      final bool isInstalled = await HealthConnectFactory.checkIfHealthConnectAppInstalled();
      if (!isInstalled) {
        await HealthConnectFactory.installHealthConnect();
        return;
      }

      // Request permissions
      final List<HealthConnectDataType> types = [HealthConnectDataType.SleepSession];
      final bool hasPermissions = await HealthConnectFactory.checkPermissions(types, readOnly: true);
      if (!hasPermissions) {
        final bool permissionsGranted = await HealthConnectFactory.requestPermissions(types, readOnly: true);
        if (!permissionsGranted) {
          throw Exception('Required permissions not granted');
        }
      }

      _isInitialized = true;
      notifyListeners();
      
      // Load initial data
      await refreshSleepData();
    } catch (e) {
      _isInitialized = false;
      notifyListeners();
      rethrow;
    }
  }

  Map<DateTime, double> _dailySleepHours = {};
  Map<DateTime, double> get dailySleepHours => _dailySleepHours;
  
  List<SleepSessionRecord> _sleepRecords = [];
  List<SleepSessionRecord> get sleepRecords => _sleepRecords;

  Future<void> refreshSleepData() async {
    if (!_isInitialized) return;

    try {
      _dailySleepHours.clear();
      final now = DateTime.now();
      final startTime = now.subtract(const Duration(days: 14));
      
      // Get sleep totals for each of the last 14 days
      for (int i = 0; i < 14; i++) {
        final date = now.subtract(Duration(days: i));
        final dayStart = DateTime(date.year, date.month, date.day);
        final dayEnd = dayStart.add(const Duration(days: 1));
        
        final Map<String, dynamic> sleepTime = await HealthConnectFactory.aggregate(
          aggregationKeys: [SleepSessionRecord.aggregationKeySleepDurationTotal],
          startTime: dayStart,
          endTime: dayEnd,
        );

        // The key in the map will be something like "sleep_duration_total"
        // and the value will be the total sleep time in seconds
        if (sleepTime.containsKey(SleepSessionRecord.aggregationKeySleepDurationTotal)) {
          final double seconds = sleepTime[SleepSessionRecord.aggregationKeySleepDurationTotal] as double;
          _dailySleepHours[dayStart] = seconds / 3600; // Convert seconds to hours
        } else {
          _dailySleepHours[dayStart] = 0.0; // No sleep recorded for this day
        }
      }

      // Also get the detailed sleep records for timing information
      final records = await HealthConnectFactory.getRecords(
        startTime: startTime,
        endTime: now,
        type: HealthConnectDataType.SleepSession,
      );
      _sleepRecords = records.cast<SleepSessionRecord>();

      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing sleep data: $e');
    }
  }

  // Helper methods for sleep timing information
  DateTime? getLastSleepStart() {
    if (_sleepRecords.isEmpty) return null;
    return _sleepRecords.last.startTime;
  }

  DateTime? getLastSleepEnd() {
    if (_sleepRecords.isEmpty) return null;
    return _sleepRecords.last.endTime;
  }

  Duration? getLastSleepDuration() {
    if (_sleepRecords.isEmpty) return null;
    final lastRecord = _sleepRecords.last;
    return lastRecord.endTime.difference(lastRecord.startTime);
  }

  // Get average sleep and wake times for the last week
  ({TimeOfDay? avgSleepTime, TimeOfDay? avgWakeTime}) getAverageSleepTimes() {
    if (_sleepRecords.isEmpty) return (avgSleepTime: null, avgWakeTime: null);

    // Get records from the last 7 days
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final weekRecords = _sleepRecords.where(
      (record) => record.startTime.isAfter(weekAgo)
    ).toList();

    if (weekRecords.isEmpty) return (avgSleepTime: null, avgWakeTime: null);

    // Calculate average sleep and wake times
    int totalSleepMinutes = 0;
    int totalWakeMinutes = 0;

    for (final record in weekRecords) {
      totalSleepMinutes += record.startTime.hour * 60 + record.startTime.minute;
      totalWakeMinutes += record.endTime.hour * 60 + record.endTime.minute;
    }

    final avgSleepMinutes = totalSleepMinutes ~/ weekRecords.length;
    final avgWakeMinutes = totalWakeMinutes ~/ weekRecords.length;

    return (
      avgSleepTime: TimeOfDay(
        hour: avgSleepMinutes ~/ 60,
        minute: avgSleepMinutes % 60,
      ),
      avgWakeTime: TimeOfDay(
        hour: avgWakeMinutes ~/ 60,
        minute: avgWakeMinutes % 60,
      ),
    );
  }

  // Helper method to get sleep hours for a specific date
  double getSleepHoursForDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return _dailySleepHours[normalized] ?? 0.0;
  }

  Duration? getLastNightSleep() {
    // Try to get from detailed records first
    if (_sleepRecords.isNotEmpty) {
      final lastRecord = _sleepRecords.last;
      return lastRecord.endTime.difference(lastRecord.startTime);
    }
    
    // Fall back to aggregated data if no detailed records
    if (_dailySleepHours.isEmpty) return null;
    
    final lastDay = _dailySleepHours.keys.reduce((a, b) => a.isAfter(b) ? a : b);
    final hours = _dailySleepHours[lastDay] ?? 0;
    return Duration(seconds: (hours * 3600).round());
  }
}
