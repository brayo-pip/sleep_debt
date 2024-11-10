import 'package:flutter/foundation.dart';
import '../models/sleep_debt_calculator.dart';

class SleepDebtProvider with ChangeNotifier {
  final SleepDebtCalculator _calculator = SleepDebtCalculator();
  
  Map<String, dynamic> _stats = {
    'averageSleep': 0.0,
    'minSleep': 0.0,
    'maxSleep': 0.0,
    'currentDebt': 0.0,
    'smoothedDebt': 0.0,
    'trend': 'No data',
    'recoveryDays': 0,
    'dailySleep': <DateTime, double>{},
  };

  Map<String, dynamic> get stats => _stats;
  double get currentDebt => _calculator.currentDebt;  // This now returns smoothed debt

  void updateSleepData(Map<DateTime, double> dailySleepHours) {
    _stats = _calculator.getSleepStats(dailySleepHours);
    notifyListeners();
  }

  void reset() {
    _stats = {
      'averageSleep': 0.0,
      'minSleep': 0.0,
      'maxSleep': 0.0,
      'currentDebt': 0.0,
      'smoothedDebt': 0.0,
      'trend': 'No data',
      'recoveryDays': 0,
      'dailySleep': <DateTime, double>{},
    };
    notifyListeners();
  }
}
