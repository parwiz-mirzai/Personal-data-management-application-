import 'dart:async';
import 'package:infogurd/App/Authentication/Data/user_data.dart';
import 'package:infogurd/App/View/Image/Data/user_data.dart';
import 'package:infogurd/App/View/Khaterat/Data/user_data.dart';
import 'package:infogurd/App/View/Link/Data/user_data.dart';
import 'package:infogurd/App/View/Password/Data/user_data.dart';
import 'package:infogurd/App/View/Finance/Data/user_data.dart';
import 'package:path/path.dart';

import 'package:sqflite/sqflite.dart' hide Transaction;



// Database helper class for managing users and transactions
class DatabaseHelper {
  final databaseName = "auth.db";

  String createUsersTable = '''
CREATE TABLE users(
  usrId INTEGER PRIMARY KEY AUTOINCREMENT,
  name UNIQUE,
  usrPassword TEXT,
  createdAt TEXT DEFAULT CURRENT_TIMESTAMP
)
''';

  String createLinksTable = '''
CREATE TABLE links(
  linkId TEXT PRIMARY KEY,
  usrId INTEGER,
  linkTitle TEXT,
  linkContent TEXT,
  linkDescription TEXT,
  createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
  priority TEXT,
  FOREIGN KEY (usrId) REFERENCES users(usrId)
)
''';

  String createKhateratTable = '''
CREATE TABLE khaterat(
  khaterahId INTEGER PRIMARY KEY AUTOINCREMENT,
  usrId INTEGER,
  khaterahTitle TEXT,
  khaterahContent TEXT,
  createdAt TEXT,
  level TEXT,
  videoPath TEXT,
  filePath TEXT,
  FOREIGN KEY (usrId) REFERENCES users(usrId)
)
''';

  String createPasswordsTable = '''
CREATE TABLE passwords(
  passwordId TEXT PRIMARY KEY,
  usrId INTEGER,
  passwordTitle TEXT,
  passwordContent TEXT,
  password TEXT,
  priority INTEGER,
  createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usrId) REFERENCES users(usrId)
)
''';

  String createPhotosTable = '''
CREATE TABLE photos(
  photoId INTEGER PRIMARY KEY AUTOINCREMENT,
  usrId INTEGER,
  photoName TEXT,
  photoTitle TEXT,
  createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
  importanceLevel TEXT DEFAULT 'Medium',
  FOREIGN KEY (usrId) REFERENCES users(usrId)
)
''';

  String createActivitiesTable = '''
CREATE TABLE activities(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type TEXT,
  title TEXT,
  timestamp INTEGER,
  priority TEXT
)
''';

  String createTransactionsTable = '''
CREATE TABLE transactions(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type INTEGER,
  source TEXT,
  amount REAL,
  date TEXT,
  notes TEXT,
  category TEXT
)
''';

  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);
    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(createUsersTable);
      await db.execute(createLinksTable);
      await db.execute(createKhateratTable);
      await db.execute(createPasswordsTable);
      await db.execute(createPhotosTable);
      await db.execute(createActivitiesTable);
      await db.execute(createTransactionsTable); // Create transactions table
    });
  }

  // User-related methods
  Future<bool> authenticate(Users usr) async {
    final Database db = await initDB();
    var result = await db.rawQuery(
        "SELECT * FROM users WHERE name = ? AND usrPassword = ?",
        [usr.name, usr.password]);
    return result.isNotEmpty;
  }

  Future<int> createUser(Users usr) async {
    final Database db = await initDB();
    return db.insert("users", usr.toMap());
  }

  Future<bool> checkUserExist(String name) async {
    final Database db = await initDB();
    final List<Map<String, dynamic>> res =
        await db.query("users", where: "name = ?", whereArgs: [name]);
    return res.isEmpty;
  }

  Future<Users?> getUser(String name) async {
    final Database db = await initDB();
    var res = await db.query("users", where: "name = ?", whereArgs: [name]);
    return res.isNotEmpty ? Users.fromMap(res.first) : null;
  }

  // Link-related methods
  Future<int> createLink(LinkModel link) async {
    final Database db = await initDB();
    return db.insert("links", link.toMap());
  }

  Future<List<LinkModel>> getLinks() async {
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db.query('links');
    return result.map((e) => LinkModel.fromMap(e)).toList();
  }

  Future<int> updateLink(String title, String content, String description, String linkId) async {
    final Database db = await initDB();
    return db.rawUpdate(
        'update links set linkTitle = ?,linkContent = ?, linkDescription = ? where linkId = ?',
        [title, content, description, linkId]);
  }

  Future<int> deleteLink(String id) async {
    final Database db = await initDB();
    return db.delete('links', where: 'linkId = ?', whereArgs: [id]);
  }

  // Khaterat-related methods
  Future<int> insertKhaterah(KhateratModel model) async {
    final db = await initDB();
    return await db.insert('khaterat', model.toMap());
  }

  Future<List<KhateratModel>> getKhaterah() async {
    final db = await initDB();
    final List<Map<String, dynamic>> result = await db.query('khaterat', orderBy: 'createdAt DESC');
    return result.map((e) => KhateratModel.fromMap(e)).toList();
  }

  Future<int> updateKhaterah(String title, String content, String level, int id) async {
    final db = await initDB();
    return await db.rawUpdate(
      'UPDATE khaterat SET khaterahTitle = ?, khaterahContent = ?, level = ? WHERE khaterahId = ?',
      [title, content, level, id],
    );
  }

  Future<int> deleteKhaterah(int id) async {
    final db = await initDB();
    return await db.delete('khaterat', where: 'khaterahId = ?', whereArgs: [id]);
  }

  // Password-related methods
  Future<int> createPassword(PasswordsModel passwordId) async {
    final Database db = await initDB();
    print('Saving to SQLite with ID: ${passwordId.passwordId}');
    return db.insert("passwords", passwordId.toMap());
  }

  Future<List<PasswordsModel>> getPasswords() async {
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db.query('passwords');
    return result.map((e) => PasswordsModel.fromMap(e)).toList();
  }

  Future<int> updatePassword(String title, String content, String password, String passwordId) async {
    final Database db = await initDB();
    return db.rawUpdate(
        'UPDATE passwords SET passwordTitle = ?, passwordContent = ?, password = ? WHERE passwordId = ?',
        [title, content, password, passwordId]);
  }

  Future<int> deletePassword(String passwordId) async {
    final Database db = await initDB();
    print('Attempting to delete SQLite passwordId: $passwordId');
    return db.delete('passwords', where: 'passwordId = ?', whereArgs: [passwordId]);
  }

  // Photo-related methods
  Future<int> createPhoto(PhotoModel photo) async {
    final db = await initDB();
    return db.insert("photos", photo.toMap());
  }

  Future<List<PhotoModel>> getPhotos() async {
    final db = await initDB();
    final maps = await db.query("photos");
    return maps.map((m) => PhotoModel.fromMap(m)).toList();
  }

  Future<int?> deletePhoto(int id) async {
    final db = await initDB();
    return db.delete('photos', where: 'photoId = ?', whereArgs: [id]);
  }

  // Activity-related methods
  Future<List<Map<String, dynamic>>> getRecentActivities() async {
    final Database db = await initDB();
    return await db.query('activities', orderBy: 'timestamp DESC', limit: 20);
  }

  Future<int> createActivity(String type, String title, int timestamp) async {
    final Database db = await initDB();
    return db.insert("activities", {
      "type": type,
      "title": title,
      "timestamp": timestamp,
    });
  }

  Future<int> deleteActivity(int id) async {
    final Database db = await initDB();
    return db.delete('activities', where: 'id = ?', whereArgs: [id]);
  }

  // Transaction-related methods
  Future<int> insertTransaction(Transaction tx) async {
    final db = await initDB();
    return await db.insert('transactions', tx.toMap());
  }

  Future<List<Transaction>> fetchTransactions() async {
    final db = await initDB();
    final maps = await db.query('transactions', orderBy: 'date DESC');
    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }

  Future<void> deleteTransaction(int id) async {
    final db = await initDB();
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final db = await initDB();
    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.transactionId],
    );
  }



  Future<List<Transaction>> fetchTransactionsByDateRange(DateTime start, DateTime end) async {
    final db = await initDB();
    final maps = await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );
    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }
}