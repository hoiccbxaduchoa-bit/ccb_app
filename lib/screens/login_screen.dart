import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final userController = TextEditingController();
  final passController = TextEditingController();

  bool firstSetup = false;
  String error = "";

  /// tên đơn vị
  String donVi = "***";

  @override
  void initState() {
    super.initState();
    checkSystem();
    loadDonVi();
  }

  /// ===============================
  /// LOAD TÊN ĐƠN VỊ
  /// ===============================
  loadDonVi() async {

    final prefs =
        await SharedPreferences.getInstance();

    setState(() {
      donVi =
          prefs.getString("donvi") ?? "***";
    });
  }

  /// kiểm tra đã tạo tài khoản chưa
  checkSystem() async {
    bool ready = await AuthService.systemReady();

    setState(() {
      firstSetup = !ready;
    });
  }

  setupSystem() async {

    String user = userController.text.trim();
    String pass = passController.text.trim();

    if (user.isEmpty || pass.isEmpty) {
      setState(() {
        error = "Phải nhập tên đăng nhập và mật khẩu";
      });
      return;
    }

    if (pass.length < 6) {
      setState(() {
        error = "Mật khẩu phải từ 6 ký tự trở lên";
      });
      return;
    }

    await AuthService.setupAccount(user, pass);
    await AuthService.login(user, pass);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardScreen(),
      ),
    );
  }

  /// đăng nhập
  login() async {

    bool success = await AuthService.login(
      userController.text,
      passController.text,
    );

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(),
        ),
      );
    } else {
      setState(() {
        error = "Sai tài khoản hoặc mật khẩu";
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 340,
            padding: EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black12,
                )
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Image.asset(
                  "assets/images/logo_ccb.png",
                  height: 110,
                ),

                SizedBox(height: 15),

                Text(
                  "HỘI CỰU CHIẾN BINH",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                /// tên đơn vị động
                Text(
                  donVi,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                ),

                SizedBox(height: 25),

                TextField(
                  controller: userController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    labelText: "Tài khoản",
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 15),

                TextField(
                  controller: passController,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                    labelText: "Mật khẩu",
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed:
                        firstSetup ? setupSystem : login,
                    child: Text(
                      firstSetup
                          ? "TẠO TÀI KHOẢN LẦN ĐẦU"
                          : "ĐĂNG NHẬP",
                    ),
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  error,
                  style: TextStyle(color: Colors.red),
                ),

                SizedBox(height: 20),

                Text(
                  "by MrDuy - version 1.26",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}