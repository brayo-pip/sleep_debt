import 'package:flutter/material.dart';
import 'package:flutter_health_connect/flutter_health_connect.dart';
import '../models/sleep_debt_calculator.dart';

class HealthConnectProvider extends ChangeNotifier {
  final SleepDebtCalculator _calculator = SleepDebtCalculator();
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  
  List<SleepSessionRecord> _sleepRecords = [];
  List<SleepSessionRecord> get sleepRecords => _sleepRecords;

  // Stats for UI
  Map<String, dynamic> get stats => _calculator.getSleepStats(_sleepRecords);

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

  Future<void> refreshSleepData() async {
    if (!_isInitialized) return;

    try {
      final DateTime startTime = DateTime.now().subtract(const Duration(days: 7));
      final DateTime endTime = DateTime.now();
      
      final records = await HealthConnectFactory.getRecords(
        startTime: startTime,
        endTime: endTime,
        type: HealthConnectDataType.SleepSession,
      );

      _sleepRecords = records.cast<SleepSessionRecord>();
      notifyListeners();
    } catch (e) {
      // Handle error but don't rethrow - we want the app to continue functioning
      debugPrint('Error refreshing sleep data: $e');
    }
  }

  Duration? getLastNightSleep() {
    if (_sleepRecords.isEmpty) return null;
    
    final lastRecord = _sleepRecords.last;
    return lastRecord.endTime.difference(lastRecord.startTime);
  }

  DateTime? getLastSleepStart() {
    if (_sleepRecords.isEmpty) return null;
    return _sleepRecords.last.startTime;
  }

  DateTime? getLastSleepEnd() {
    if (_sleepRecords.isEmpty) return null;
    return _sleepRecords.last.endTime;
  }
}
