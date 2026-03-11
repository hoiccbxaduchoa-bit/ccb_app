import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class PermissionService {

  /// ================= ADMIN =================

  static bool isAdmin() {
    return AuthService.role == "admin";
  }

  /// ================= GET PERMISSION =================

  static Future<bool> get(String key) async {

    /// admin luôn có quyền
    if (isAdmin()) return true;

    final prefs = await SharedPreferences.getInstance();

    String user = AuthService.username ?? "";

    if(user.isEmpty) return false;

    bool value = prefs.getBool("${user}_$key") ?? false;

    return value;
  }

  /// ================= SET PERMISSION =================

  static Future set(
      String user,
      String key,
      bool value
      ) async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool("${user}_$key", value);
  }

  /// ================= CHECK PERMISSION =================

  static Future<bool> allow(
      BuildContext context,
      String key
      ) async {

    bool ok = await get(key);

    if (!ok) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Hạn chế quyền truy cập"),
        ),
      );

      return false;
    }

    return true;
  }
}