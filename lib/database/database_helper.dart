import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'grocery.db');

    return await openDatabase(
      path,
      version: 3, // updated version
      onCreate: (db, version) async {

        // USERS TABLE
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT UNIQUE,
            password TEXT,
            gender TEXT
          )
        ''');

        // CART TABLE
        await db.execute('''
          CREATE TABLE cart(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            item TEXT,
            quantity INTEGER
          )
        ''');

        // FEEDBACK TABLE
        await db.execute('''
          CREATE TABLE feedback(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            message TEXT
          )
        ''');
      },
    );
  }

  // ================= USERS =================

  Future<int> insertUser(
      String name, String email, String password, String gender) async {
    final db = await database;
    return await db.insert('users', {
      'name': name,
      'email': email,
      'password': password,
      'gender': gender,
    });
  }

  Future<Map<String, dynamic>?> loginUser(
      String email, String password) async {
    final db = await database;

    var result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) return result.first;
    return null;
  }

  // ================= CART =================

  Future<List<Map<String, dynamic>>> getItems() async {
    final db = await database;
    return db.query('cart');
  }

  Future<int> addItem(String item, int quantity) async {
    final db = await database;

    var existing = await db.query(
      'cart',
      where: 'item = ?',
      whereArgs: [item],
    );

    if (existing.isNotEmpty) {
      int id = existing.first['id'];
      int currentQty = existing.first['quantity'];
      return await db.update(
        'cart',
        {'quantity': currentQty + quantity},
        where: 'id = ?',
        whereArgs: [id],
      );
    }

    return await db.insert('cart', {
      'item': item,
      'quantity': quantity,
    });
  }

  Future<int> updateItem(int id, int quantity) async {
    final db = await database;
    return db.update(
      'cart',
      {'quantity': quantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    return db.delete('cart', where: 'id = ?', whereArgs: [id]);
  }

  // ================= FEEDBACK =================

  Future<int> insertFeedback(String message) async {
    final db = await database;
    return db.insert('feedback', {'message': message});
  }

  Future<List<Map<String, dynamic>>> getFeedbacks() async {
    final db = await database;
    return db.query('feedback');
  }
}