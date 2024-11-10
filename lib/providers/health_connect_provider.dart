import 'package:flutter/material.dart' show TimeOfDay, ChangeNotifier, debugPrint;
import 'package:flutter_health_connect/flutter_health_connect.dart';
import '../models/sleep_debt_calculator.dart';
import '../data/database_helper.dart';

class HealthConnectProvider extends ChangeNotifier {
  final SleepDebtCalculator _calculator = SleepDebtCalculator();
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  
  // Stats for UI
  Map<String, dynamic> get stats => _calculator.getSleepStats(_dailySleepHours);

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    try {
      // First load data from database
      await _loadFromDatabase();
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();

      // Then initialize Health Connect and refresh data in background
      final bool isSupported = await HealthConnectFactory.checkIfSupported();
      if (!isSupported) {
        throw Exception('Health Connect is not supported on this device');
      }

      final bool isInstalled = await HealthConnectFactory.checkIfHealthConnectAppInstalled();
      if (!isInstalled) {
        await HealthConnectFactory.installHealthConnect();
        return;
      }

      final List<HealthConnectDataType> types = [HealthConnectDataType.SleepSession];
      final bool hasPermissions = await HealthConnectFactory.checkPermissions(types, readOnly: true);
      if (!hasPermissions) {
        final bool permissionsGranted = await HealthConnectFactory.requestPermissions(types, readOnly: true);
        if (!permissionsGranted) {
          throw Exception('Required permissions not granted');
        }
      }
      
      // Refresh from Health Connect in background
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

        double sleepHours = 0.0;
        if (sleepTime.containsKey(SleepSessionRecord.aggregationKeySleepDurationTotal)) {
          final double seconds = sleepTime[SleepSessionRecord.aggregationKeySleepDurationTotal] as double;
          sleepHours = seconds / 3600; // Convert seconds to hours
        }
        
        // Store in memory
        _dailySleepHours[dayStart] = sleepHours;
        
        // Persist to database
        await DatabaseHelper.instance.updateDailySleep(
          dayStart.toIso8601String().split('T')[0],
          sleepHours,
        );
      }

      // Get and store detailed sleep records
      final records = await HealthConnectFactory.getRecords(
        startTime: startTime,
        endTime: now,
        type: HealthConnectDataType.SleepSession,
      );
      _sleepRecords = records.cast<SleepSessionRecord>();

      // Store records in database
      for (final record in _sleepRecords) {
        await DatabaseHelper.instance.insertSleepRecord({
          'start_time': record.startTime.millisecondsSinceEpoch,
          'end_time': record.endTime.millisecondsSinceEpoch,
          'duration_seconds': record.endTime.difference(record.startTime).inSeconds,
          'source': 'health_connect',
        });
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing sleep data: $e');
      // Try to load from database if Health Connect fails
      await _loadFromDatabase();
    }
  }

  Future<void> _loadFromDatabase() async {
    try {
      final now = DateTime.now();
      final startTime = now.subtract(const Duration(days: 14));
      
      // Load daily sleep data
      _dailySleepHours = await DatabaseHelper.instance.getDailySleep(startTime, now);
      
      // Load sleep records
      final records = await DatabaseHelper.instance.getSleepRecords(startTime, now);
      _sleepRecords = records.map((record) => SleepSessionRecord(
        startTime: DateTime.fromMillisecondsSinceEpoch(record['start_time'] as int),
        endTime: DateTime.fromMillisecondsSinceEpoch(record['end_time'] as int),
      )).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading from database: $e');
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

  // Get recent wake times for sleep window calculation
  List<TimeOfDay> getRecentWakeTimes() {
    if (_sleepRecords.isEmpty) return [];
    
    // Get wake times from last 7 days of records
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    return _sleepRecords
      .where((record) => record.endTime.isAfter(weekAgo))
      .map((record) => TimeOfDay(
        hour: record.endTime.hour,
        minute: record.endTime.minute,
      ))
      .toList();
  }

  // Get the last sleep and wake times
  ({TimeOfDay? sleepTime, TimeOfDay? wakeTime}) getLastSleepTimes() {
    if (_sleepRecords.isEmpty) return (sleepTime: null, wakeTime: null);
    
    final lastRecord = _sleepRecords.last;
    return (
      sleepTime: TimeOfDay(
        hour: lastRecord.startTime.hour,
        minute: lastRecord.startTime.minute,
      ),
      wakeTime: TimeOfDay(
        hour: lastRecord.endTime.hour,
        minute: lastRecord.endTime.minute,
      ),
    );
  }
}
