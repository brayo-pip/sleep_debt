import 'package:flutter/foundation.dart';
import '../models/sleep_debt_calculator.dart';

class SleepDebtProvider with ChangeNotifier {
  final SleepDebtCalculator _calculator = SleepDebtCalculator();
  
  Map<String, dynamic> _stats = {
    'averageSleep': 0.0,
    'minSleep': 0.0,
    'maxSleep': 0.0,
    'currentDebt': 0.0,
    'trend': 'No data',
    'recoveryDays': 0,
  };

  Map<String, dynamic> get stats => _stats;
  List<double> get sleepRecords => _calculator.sleepRecords;
  double get currentDebt => _calculator.currentDebt;

  void addSleepRecord(double hours) {
    _calculator.addSleepRecord(hours);
    _stats = _calculator.getSleepStats();
    notifyListeners();
  }

  void reset() {
    _calculator.reset();
    _stats = _calculator.getSleepStats();
    notifyListeners();
  }
}
