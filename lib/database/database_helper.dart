import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/water_intake.dart';
import '../models/calorie_intake.dart';
import '../models/activity.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('health_tracker.db');
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

  Future _createDB(Database db, int version) async {
    // Tabel Water Intake
    await db.execute('''
      CREATE TABLE water_intake (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL
      )
    ''');

    // Tabel Calorie Intake
    await db.execute('''
      CREATE TABLE calorie_intake (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        description TEXT
      )
    ''');

    // Tabel Activity
    await db.execute('''
      CREATE TABLE activity (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        duration INTEGER NOT NULL,
        status TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  // ========== WATER INTAKE OPERATIONS ==========
  
  Future<int> insertWaterIntake(WaterIntake water) async {
    final db = await database;
    return await db.insert('water_intake', water.toMap());
  }

  Future<double> getTodayWaterIntake(String date) async {
    final db = await database;
    final result = await db.query(
      'water_intake',
      where: 'date = ?',
      whereArgs: [date],
    );

    double total = 0;
    for (var item in result) {
      total += item['amount'] as double;
    }
    return total;
  }

  Future<List<WaterIntake>> getWaterIntakeByDate(String date) async {
    final db = await database;
    final result = await db.query(
      'water_intake',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'time DESC',
    );

    return result.map((json) => WaterIntake.fromMap(json)).toList();
  }

  // ========== CALORIE INTAKE OPERATIONS ==========
  
  Future<int> insertCalorieIntake(CalorieIntake calorie) async {
    final db = await database;
    return await db.insert('calorie_intake', calorie.toMap());
  }

  Future<Map<String, double>> getTodayCalories(String date) async {
    final db = await database;
    final result = await db.query(
      'calorie_intake',
      where: 'date = ?',
      whereArgs: [date],
    );

    double calorieIn = 0;
    double calorieOut = 0;

    for (var item in result) {
      if (item['type'] == 'masuk') {
        calorieIn += item['amount'] as double;
      } else {
        calorieOut += item['amount'] as double;
      }
    }

    return {'masuk': calorieIn, 'keluar': calorieOut};
  }

  Future<List<CalorieIntake>> getCaloriesByDate(String date) async {
    final db = await database;
    final result = await db.query(
      'calorie_intake',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'time DESC',
    );

    return result.map((json) => CalorieIntake.fromMap(json)).toList();
  }

  // ========== ACTIVITY OPERATIONS ==========
  
  Future<int> insertActivity(Activity activity) async {
    final db = await database;
    return await db.insert('activity', activity.toMap());
  }

  Future<int> updateActivity(Activity activity) async {
    final db = await database;
    return await db.update(
      'activity',
      activity.toMap(),
      where: 'id = ?',
      whereArgs: [activity.id],
    );
  }

  Future<List<Activity>> getActivitiesByDate(String date) async {
    final db = await database;
    final result = await db.query(
      'activity',
      where: 'date = ?',
      whereArgs: [date],
    );

    return result.map((json) => Activity.fromMap(json)).toList();
  }

  // ========== DELETE OPERATIONS (untuk reset/hapus data) ==========
  
  Future<int> deleteWaterIntake(int id) async {
    final db = await database;
    return await db.delete('water_intake', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteCalorieIntake(int id) async {
    final db = await database;
    return await db.delete('calorie_intake', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteActivity(int id) async {
    final db = await database;
    return await db.delete('activity', where: 'id = ?', whereArgs: [id]);
  }

  // Close database
  Future close() async {
    final db = await database;
    db.close();
  }
}