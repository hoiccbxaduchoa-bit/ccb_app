import 'package:flutter/material.dart';
import 'member_screen.dart';
import 'member_screen.dart';
import 'statistic_screen.dart';
import 'report_screen.dart';
import 'setting_screen.dart';
class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(Title: Text("Hội CCB xã Đức Hoà")),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(20),
        children: [
          menu(context, "Hội viên 2", Icons.people),
        ],
      ),
    );
  }

  Widget menu(BuildContext context, String title, IconData icon) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MemberScreen()),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50),
            SizedBox(height: 10),
            Text(title),
          ],
        ),
      ),
    );
  }
}