import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_health_connect/flutter_health_connect.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<HealthConnectDataType> _types = [
    HealthConnectDataType.SleepSession,
  ];

  String _resultText = '';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeHealthConnect();
  }

  Future<void> _initializeHealthConnect() async {
    try {
      // Check if Health Connect is supported
      final bool isSupported = await HealthConnectFactory.checkIfSupported();
      if (!isSupported) {
        _updateResultText('Health Connect is not supported on this device');
        return;
      }

      // Check if Health Connect app is installed
      final bool isInstalled = await HealthConnectFactory.checkIfHealthConnectAppInstalled();
      if (!isInstalled) {
        _updateResultText('Installing Health Connect...');
        await HealthConnectFactory.installHealthConnect();
        return;
      }

      // Check permissions
      final bool hasPermissions = await HealthConnectFactory.checkPermissions(_types, readOnly: true);
      if (!hasPermissions) {
        final bool permissionsGranted = await HealthConnectFactory.requestPermissions(_types, readOnly: true);
        if (!permissionsGranted) {
          _updateResultText('Required permissions not granted');
          return;
        }
      }

      setState(() => _isInitialized = true);
      _updateResultText('Health Connect initialized successfully');
    } catch (e) {
      _updateResultText('Error: $e');
    }
  }

  Future<void> _getSleepRecords() async {
    try {
      final DateTime startTime = DateTime.now().subtract(const Duration(days: 7));
      final DateTime endTime = DateTime.now();
      
      final sleepRecords = await HealthConnectFactory.getRecords(
        startTime: startTime,
        endTime: endTime,
        type: HealthConnectDataType.SleepSession,
      );

      if (sleepRecords.isEmpty) {
        _updateResultText('No sleep records found in the last 7 days');
        return;
      }

      final StringBuffer buffer = StringBuffer();
      buffer.writeln('Sleep Records for the last 7 days:');
      
      for (final record in sleepRecords) {
        final offset = record.startZoneOffset;
        final adjustedStartTime = record.startTime.add(offset);
        final adjustedEndTime = record.endTime.add(offset);
        
        buffer.writeln('─────────────────');
        buffer.writeln('Start: $adjustedStartTime (UTC${_formatOffset(offset)})');
        buffer.writeln('End: $adjustedEndTime (UTC${_formatOffset(offset)})');
        buffer.writeln('Duration: ${record.endTime.difference(record.startTime)}');
      }

      _updateResultText(buffer.toString());
    } catch (e) {
      _updateResultText('Error fetching sleep records: $e');
    }
  }

  String _formatOffset(Duration offset) {
    final hours = offset.inHours;
    final minutes = offset.inMinutes.remainder(60).abs();
    final sign = hours >= 0 ? '+' : '';
    return '$sign$hours:${minutes.toString().padLeft(2, '0')}';
  }

  void _updateResultText(String newText) {
    if (context.mounted) {
      setState(() => _resultText = newText);
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Sleep Records'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (!_isInitialized)
                  ElevatedButton(
                    onPressed: _initializeHealthConnect,
                    child: const Text('Initialize Health Connect'),
                  )
                else
                  ElevatedButton(
                    onPressed: _getSleepRecords,
                    child: const Text('Get Sleep Records (Last 7 Days)'),
                  ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(_resultText),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
