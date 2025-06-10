import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBConfig {
  static Database? _database;
  static const String DB_NAME = 'clockin.db';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), DB_NAME);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        email TEXT,
        password TEXT,
        role TEXT
      )
    ''');

    // Create attendance table
    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        date TEXT,
        timeIn TEXT,
        timeOut TEXT,
        status TEXT,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('''
      ALTER TABLE attendance ADD COLUMN userId INTEGER;
    ''');
    }
  }
}
