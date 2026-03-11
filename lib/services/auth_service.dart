import 'package:shared_preferences/shared_preferences.dart';
import '../services/db_service.dart';

class AuthService {

static String? username;
static String? role;
static String? chiHoi;

/// ===============================
/// KIỂM TRA HỆ THỐNG
/// ===============================
static Future<bool> systemReady() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.containsKey("admin_user");
}

/// ===============================
/// TẠO ADMIN LẦN ĐẦU
/// ===============================
static Future setupAccount(String user, String pass) async {

  final prefs = await SharedPreferences.getInstance();

  user = user.trim();
  pass = pass.trim();

  await prefs.setString("admin_user", user);
  await prefs.setString("admin_pass", pass);

  await prefs.setBool("loggedIn", true);
  await prefs.setString("current_user", user);

  username = user;
  role = "admin";      // Chủ tịch
  chiHoi = "all";
}

/// ===============================
/// LOGIN
/// ===============================
static Future<bool> login(String user, String pass) async {

  user = user.trim();
  pass = pass.trim();

  final prefs = await SharedPreferences.getInstance();

  /// =================
  /// ADMIN
  /// =================

  String? adminUser = prefs.getString("admin_user");
  String? adminPass = prefs.getString("admin_pass");

  if(user == adminUser && pass == adminPass){

    await prefs.setBool("loggedIn", true);
    await prefs.setString("current_user", user);

    username = user;
    role = "admin";
    chiHoi = "all";

    return true;
  }

  /// =================
  /// DATABASE USER
  /// =================

  var result = await DBService.login(user, pass);

  if(result != null){

    await prefs.setBool("loggedIn", true);
    await prefs.setString("current_user", user);

    username = result["username"];
    role = result["role"];
    chiHoi = result["chi_hoi"];

    return true;
  }

  return false;
}

/// ===============================
/// LOAD SESSION
/// ===============================
static Future loadSession() async {

  final prefs = await SharedPreferences.getInstance();

  bool logged = prefs.getBool("loggedIn") ?? false;
  if (!logged) return;

  String? user = prefs.getString("current_user");
  if (user == null) return;

  String? adminUser = prefs.getString("admin_user");

  /// ADMIN
  if (user == adminUser) {
    username = user;
    role = "admin";
    chiHoi = "all";
    return;
  }

  /// LOAD DATABASE USER
  final db = await DBService.database();

  var result = await db.query(
    "users",
    where: "username=?",
    whereArgs: [user],
  );

  if(result.isNotEmpty){

    username = result.first["username"].toString();
    role = result.first["role"].toString();
    chiHoi = result.first["chi_hoi"].toString();

  }
}

/// ===============================
/// RESET PASSWORD
/// ===============================
static Future resetPassword(String user,String newPass) async {

  final db = await DBService.database();

  await db.update(
    "users",
    {"password": newPass},
    where: "username=?",
    whereArgs: [user],
  );
}

/// ===============================
/// ĐỔI MẬT KHẨU
/// ===============================
static Future changePassword(String newPass) async {

  final db = await DBService.database();

  if(role == "admin"){

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("admin_pass", newPass);

  }else{

    await db.update(
      "users",
      {"password": newPass},
      where: "username=?",
      whereArgs: [username],
    );
  }
}

/// ===============================
/// THÔNG TIN TÀI KHOẢN
/// ===============================
static Future<Map<String,String?>> getAccountInfo() async {

  if(role == "admin"){
    return {
      "username": username,
      "role": "Chủ tịch hội",
      "chiHoi": "Toàn xã"
    };
  }

  return {
    "username": username,
    "role": "Chi hội trưởng",
    "chiHoi": chiHoi
  };
}

/// ===============================
/// KIỂM TRA LOGIN
/// ===============================
static Future<bool> isLoggedIn() async {

  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool("loggedIn") ?? false;
}

/// ===============================
/// LOGOUT
/// ===============================
static Future logout() async {

  final prefs = await SharedPreferences.getInstance();

  await prefs.setBool("loggedIn", false);
  await prefs.remove("current_user");

  username = null;
  role = null;
  chiHoi = null;
}

}