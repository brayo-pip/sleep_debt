import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sleep_debt.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sleep_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        start_time INTEGER NOT NULL,
        end_time INTEGER NOT NULL,
        duration_seconds INTEGER NOT NULL,
        source TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_sleep (
        date TEXT PRIMARY KEY,
        hours REAL NOT NULL,
        last_updated INTEGER NOT NULL
      )
    ''');
  }

  // Sleep Records operations
  Future<int> insertSleepRecord(Map<String, dynamic> record) async {
    final db = await database;
    return await db.insert('sleep_records', record);
  }

  Future<List<Map<String, dynamic>>> getSleepRecords(DateTime startDate, DateTime endDate) async {
    final db = await database;
    return await db.query(
      'sleep_records',
      where: 'start_time >= ? AND end_time <= ?',
      whereArgs: [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch],
      orderBy: 'start_time DESC',
    );
  }

  // Daily Sleep operations
  Future<void> updateDailySleep(String date, double hours) async {
    final db = await database;
    await db.insert(
      'daily_sleep',
      {
        'date': date,
        'hours': hours,
        'last_updated': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<DateTime, double>> getDailySleep(DateTime startDate, DateTime endDate) async {
    final db = await database;
    final results = await db.query(
      'daily_sleep',
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        startDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0],
      ],
    );

    return Map.fromEntries(
      results.map((row) => MapEntry(
        DateTime.parse(row['date'] as String),
        row['hours'] as double,
      )),
    );
  }

  // Clear all data (useful for testing)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('sleep_records');
    await db.delete('daily_sleep');
  }

  // Close database
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
