import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Get the databases path
    String databasesPath = await getDatabasesPath();

    // Concatenate the file path with the database name manually
    String path = join(databasesPath, 'xbug.db');
    
   // await databaseFactory.deleteDatabase(path);

    // Open the database
    return await openDatabase(
      path,
      version: 2, // Increment version to trigger onUpgrade
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Handle upgrades
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    // Run only if upgrading from a version less than 2
    await db.execute('''
      ALTER TABLE Debt ADD COLUMN alarming_limit REAL DEFAULT -1
    ''');
   
  }

  // Add future upgrades here by checking the version range
}

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Asset (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        value REAL NOT NULL,
        desc TEXT,
        type TEXT NOT NULL,
        status INTEGER NOT NULL,
        user_code TEXT,
        unique_code TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE Debt (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        monthly_payment REAL NOT NULL,
        remaining_month INTEGER NOT NULL,
        total_month INTEGER NOT NULL,
        status INTEGER NOT NULL,
        desc TEXT,
        last_payment_date DATETIME,
        user_code TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE Transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        desc TEXT,
        asset_id INTEGER,
        debt_id INTEGER,
        user_code TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE Chat_History (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        request TEXT NOT NULL,
        response TEXT NOT NULL,
        transaction_id INTEGER,
        create_at TEXT NOT NULL,
        status TEXT NOT NULL,
        user_code TEXT
      )
    ''');

     await db.execute('''
        ALTER TABLE Transactions ADD COLUMN transaction_type INTEGER NOT NULL DEFAULT 1
      ''');

    await db.execute('''
        ALTER TABLE Transactions ADD COLUMN image TEXT 
      ''');

    _onUpgrade(db, 0, 3);

  }


  // Insert data into a specific table
  Future<int> insertData(String tableName, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(tableName, data);
  }

  // Update data in a specific table
  Future<int> updateData(
      String tableName, Map<String, dynamic> data, int id) async {
    final db = await database;
    return await db.update(
      tableName,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete data from a specific table
  Future<int> deleteData(String tableName, int id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Fetch all rows from a table
  Future<List<Map<String, dynamic>>> getAllRows(String tableName) async {
    final db = await database;
    return await db.query(tableName);
  }

  // Fetch a single row by ID from a table
  Future<Map<String, dynamic>?> getRowById(String tableName, int id) async {
    final db = await database;
    final result = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
}
