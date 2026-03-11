import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/auth_service.dart';

void main() {
  runApp(CCBApp());
}

class CCBApp extends StatelessWidget {

  Future<Widget> startScreen() async {

    bool logged =
        await AuthService.isLoggedIn();

    /// LOAD SESSION
    await AuthService.loadSession();

    if (logged) {
      return DashboardScreen();
    }

    return LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Hội CCB xã Đức Hoà",

      home: FutureBuilder(
        future: startScreen(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return snapshot.data!;
        },
      ),
    );
  }
}