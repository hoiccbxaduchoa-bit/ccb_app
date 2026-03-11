import 'package:flutter/material.dart';
import 'member_screen.dart';
import 'setting_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String donVi = "***";

  @override
  void initState() {
    super.initState();
    loadDonVi();
  }

  loadDonVi() async {

    final prefs =
        await SharedPreferences.getInstance();

    setState(() {
      donVi = prefs.getString("donvi") ?? "***";
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(
          "HỘI CỰU CHIẾN BINH $donVi",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Center(
            child: ElevatedButton.icon(
              icon: Icon(Icons.people),
              label: Text("Quản lý hội viên"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MemberScreen(),
                  ),
                );
              },
            ),
          ),

          SizedBox(height:20),

          Center(
            child: ElevatedButton.icon(
              icon: Icon(Icons.settings),
              label: Text("Cài đặt hệ thống"),

              onPressed: () async {

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingScreen(),
                  ),
                );

                /// reload tên đơn vị
                loadDonVi();

              },
            ),
          ),

        ],
      ),
    );
  }
}