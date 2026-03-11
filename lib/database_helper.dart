import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'member_model.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ccb.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path,
        version: 1,
        onCreate: (db, version) async {
      await db.execute('''
      CREATE TABLE members(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hoTen TEXT,
        namSinh TEXT,
        chiHoi TEXT,
        soDienThoai TEXT
      )
      ''');
    });
  }

  Future<int> insert(Member member) async {
    final db = await instance.database;
    return db.insert('members', member.toMap());
  }

  Future<List<Member>> getAll() async {
    final db = await instance.database;
    final result = await db.query('members');
    return result.map((e) => Member.fromMap(e)).toList();
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return db.delete('members', where: 'id=?', whereArgs: [id]);
  }
}