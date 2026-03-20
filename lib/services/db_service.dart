import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

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
    quy_dong_doi INTEGER,

    uid TEXT,
    updated_at TEXT
  )
  ''');

  await db.execute('''
  CREATE TABLE IF NOT EXISTS users(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE,
    password TEXT,
    role TEXT,
    chi_hoi TEXT
  )
  ''');

  await db.insert("users",{
    "username":"admin",
    "password":"123456",
    "role":"chu_tich",
    "chi_hoi":"all"
  });

},
);

/// đảm bảo users tồn tại
await _db!.execute('''
CREATE TABLE IF NOT EXISTS users(
id INTEGER PRIMARY KEY AUTOINCREMENT,
username TEXT UNIQUE,
password TEXT,
role TEXT,
chi_hoi TEXT
)
''');

/// đảm bảo admin
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

/// thêm cột thiếu
await addColumnIfNotExists(_db!, "knc", "TEXT");
await addColumnIfNotExists(_db!, "msh", "TEXT");
await addColumnIfNotExists(_db!, "quy_dong_doi", "INTEGER");
await addColumnIfNotExists(_db!, "uid", "TEXT");
await addColumnIfNotExists(_db!, "updated_at", "TEXT");

/// UNIQUE UID
await _db!.execute(
  "CREATE UNIQUE INDEX IF NOT EXISTS idx_uid ON members(uid)"
);

return _db!;
}

/// =============================
/// INSERT MEMBER
/// =============================
static Future<int> insert(
Map<String,dynamic> data) async {

final db = await database();

/// auto uid
if (data["uid"] == null || data["uid"].toString().isEmpty) {
  data["uid"] = Uuid().v4();
}

/// timestamp
data["updated_at"] = DateTime.now().toIso8601String();

return await db.insert(
"members",
data,
conflictAlgorithm: ConflictAlgorithm.abort,
);

}

/// =============================
/// UPDATE MEMBER
/// =============================
static Future<int> update(
int id,
Map<String,dynamic> data) async {

final db = await database();

/// giữ uid
data.remove("uid");

/// update time
data["updated_at"] = DateTime.now().toIso8601String();

return await db.update(
"members",
data,
where:"id=?",
whereArgs:[id],
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
static Future<List<Map<String,dynamic>>> getUsers() async {

final db = await database();
return await db.query("users");

}

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
static Future closeDB() async {

if(_db != null){
await _db!.close();
_db = null;
}

}

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
static Future<String> dbPath() async {

return join(
await getDatabasesPath(),
"members.db",
);

}

}