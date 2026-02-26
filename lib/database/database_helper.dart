import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  // ================= DATABASE INSTANCE =================
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  // ================= INITIALIZE DATABASE =================
  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'users.db');

    return await openDatabase(
      path,
      version: 2, // ⚠️ Increased version (important)
      onCreate: (db, version) async {

        // ================= USERS TABLE =================
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT UNIQUE,
            password TEXT,
            gender TEXT
          )
        ''');

        // ================= CART TABLE =================
        await db.execute('''
          CREATE TABLE cart(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            item TEXT,
            quantity INTEGER
          )
        ''');
      },
    );
  }

  // ======================================================
  // ================= USER METHODS =======================
  // ======================================================

  Future<int> insertUser(
      String name, String email, String password, String gender) async {
    final db = await database;
    return await db.insert(
      'users',
      {
        'name': name,
        'email': email,
        'password': password,
        'gender': gender,
      },
    );
  }

  Future<Map<String, dynamic>?> loginUser(
      String email, String password) async {
    final db = await database;

    var result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return db.query('users');
  }

  // ======================================================
  // ================= CART METHODS =======================
  // ======================================================

  // Get all cart items
  Future<List<Map<String, dynamic>>> getItems() async {
    final db = await database;
    return await db.query('cart');
  }

  // Add new item
  Future<int> addItem(String item, int quantity) async {
    final db = await database;
    return await db.insert(
      'cart',
      {
        'item': item,
        'quantity': quantity,
      },
    );
  }

  // Update quantity
  Future<int> updateItem(int id, int quantity) async {
    final db = await database;
    return await db.update(
      'cart',
      {'quantity': quantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete item
  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete(
      'cart',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}