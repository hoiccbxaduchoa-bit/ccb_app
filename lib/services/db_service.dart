import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBService {

static Database? _db;

/// =============================
/// OPEN DATABASE
/// =============================
static Future<Database> database() async {

if (_db != null) return _db!;

String path = join(await getDatabasesPath(), "members.db");

_db = await openDatabase(
path,
version: 1,


onCreate: (db, version) async {

  /// =============================
  /// MEMBERS TABLE
  /// =============================

  await db.execute('''
  CREATE TABLE IF NOT EXISTS members(

    id INTEGER PRIMARY KEY AUTOINCREMENT,

    ho_ten TEXT,
    so_cccd TEXT,
    nam_sinh TEXT,
    so_the_hoi_vien TEXT,

    chi_hoi TEXT,
    so_dien_thoai TEXT,

    ngay_vao_hoi TEXT,
    chuc_vu_hoi TEXT,

    ngay_nhap_ngu TEXT,
    ngay_xuat_ngu TEXT,
    ngay_vao_dang TEXT,

    cap_bac_truoc_xuat_ngu TEXT,
    chuc_vu_truoc_xuat_ngu TEXT,
    don_vi_truoc_xuat_ngu TEXT,

    dan_toc TEXT,
    trinh_do_hoc_van TEXT,
    trinh_do_chuyen_mon TEXT,
    trinh_do_llct TEXT,

    che_do_chinh_sach TEXT,
    khen_thuong TEXT,
    tham_gia_khang_chien TEXT,
    ghi_chu TEXT,

    bhyt TEXT,
    knc TEXT,
    msh TEXT,
    photo TEXT,
    quy_dong_doi INTEGER
  )
  ''');

  /// USERS TABLE

  await db.execute('''
  CREATE TABLE IF NOT EXISTS users(

    id INTEGER PRIMARY KEY AUTOINCREMENT,

    username TEXT UNIQUE,
    password TEXT,

    role TEXT,
    chi_hoi TEXT

  )
  ''');

  /// ADMIN DEFAULT

  await db.insert("users",{
    "username":"admin",
    "password":"123456",
    "role":"chu_tich",
    "chi_hoi":"all"
  });

},


);

/// =============================
/// ĐẢM BẢO BẢNG USERS TỒN TẠI
/// =============================

await _db!.execute('''
CREATE TABLE IF NOT EXISTS users(


id INTEGER PRIMARY KEY AUTOINCREMENT,
username TEXT UNIQUE,
password TEXT,
role TEXT,
chi_hoi TEXT


)
''');

/// =============================
/// TẠO ADMIN NẾU CHƯA CÓ
/// =============================

var admin = await _db!.query(
"users",
where:"username=?",
whereArgs:["admin"]
);

if(admin.isEmpty){


await _db!.insert("users",{
  "username":"admin",
  "password":"123456",
  "role":"chu_tich",
  "chi_hoi":"all"
});


}

/// =============================
/// TỰ ĐỘNG THÊM CỘT NẾU THIẾU
/// =============================

try {
await _db!.execute(
"ALTER TABLE members ADD COLUMN photo TEXT");
} catch (e) {}

await addColumnIfNotExists(_db!, "knc", "TEXT");
await addColumnIfNotExists(_db!, "msh", "TEXT");
await addColumnIfNotExists(_db!, "quy_dong_doi", "INTEGER");

return _db!;

}

/// =============================
/// GET ALL MEMBERS
/// =============================
static Future<List<Map<String, dynamic>>> getMembers() async {

final db = await database();

return await db.query(
"members",
orderBy: "ho_ten ASC",
);

}

/// =============================
/// GET MEMBERS BY CHI HOI
/// =============================
static Future<List<Map<String,dynamic>>> getMembersByChiHoi(
String chiHoi) async {

final db = await database();

return await db.query(
"members",
where:"chi_hoi=?",
whereArgs:[chiHoi],
);

}

/// =============================
/// INSERT MEMBER
/// =============================
static Future<int> insert(
Map<String,dynamic> data) async {

final db = await database();

return await db.insert(
"members",
data,
conflictAlgorithm: ConflictAlgorithm.replace,
);

}

/// =============================
/// UPDATE MEMBER
/// =============================
static Future<int> update(
int id,
Map<String,dynamic> data) async {

final db = await database();

return await db.update(
"members",
data,
where:"id=?",
whereArgs:[id],
conflictAlgorithm: ConflictAlgorithm.replace,
);

}

/// =============================
/// DELETE MEMBER
/// =============================
static Future deleteMember(int id) async {

final db = await database();

await db.delete(
"members",
where:"id=?",
whereArgs:[id],
);

}

/// =============================
/// LOGIN
/// =============================
static Future<Map<String,dynamic>?> login(
String username,
String password) async {

final db = await database();

var result = await db.query(
"users",
where:"username=? AND password=?",
whereArgs:[username,password],
);

if(result.isNotEmpty){
return result.first;
}

return null;

}

/// =============================
/// CREATE USER
/// =============================
static Future createUser(
String username,
String password,
String role,
String chiHoi) async {

final db = await database();

await db.insert(
"users",
{
"username":username,
"password":password,
"role":role,
"chi_hoi":chiHoi
},
conflictAlgorithm: ConflictAlgorithm.replace,
);

}

/// =============================
/// GET USERS
/// =============================
static Future<List<Map<String,dynamic>>> getUsers() async {

final db = await database();

return await db.query("users");

}

/// =============================
/// DELETE USER
/// =============================
static Future deleteUser(int id) async {

final db = await database();

await db.delete(
"users",
where:"id=?",
whereArgs:[id],
);

}

/// =============================
/// RESET PASSWORD
/// =============================
static Future resetPassword(int id) async {

final db = await database();

await db.update(
"users",
{"password":"123456"},
where:"id=?",
whereArgs:[id]
);

}

/// =============================
/// CLOSE DATABASE
/// =============================
static Future closeDB() async {

if(_db != null){


await _db!.close();

_db = null;


}

}

/// =============================
/// ADD COLUMN IF NOT EXISTS
/// =============================
static Future addColumnIfNotExists(
Database db,
String column,
String type) async {

var result =
await db.rawQuery("PRAGMA table_info(members)");

bool exists =
result.any((c)=>c["name"]==column);

if(!exists){


await db.execute(
    "ALTER TABLE members ADD COLUMN $column $type");


}

}

/// =============================
/// DATABASE PATH
/// =============================
static Future<String> dbPath() async {

return join(
await getDatabasesPath(),
"members.db",
);

}

}
