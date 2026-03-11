import 'package:flutter/material.dart';
import '../services/db_service.dart';
import 'statistic_list_screen.dart';
import '../services/auth_service.dart';
class StatisticAgeScreen extends StatefulWidget {
  @override
  State<StatisticAgeScreen> createState() =>
      _StatisticAgeScreenState();
}

class _StatisticAgeScreenState
    extends State<StatisticAgeScreen> {

  int duoi40 = 0;
  int t41_50 = 0;
  int t51_60 = 0;
  int t61_70 = 0;
  int tren71 = 0;

  int year = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {

  var db = await DBService.database();

  var m = await db.query("members");

  /// lọc theo chi hội nếu không phải admin
  if(AuthService.role != "admin"){
    m = m.where((row) =>
        row["chi_hoi"] == AuthService.chiHoi
    ).toList();
  }

  for (var row in m) {

    int nam =
        int.tryParse(row["nam_sinh"]
                ?.toString() ??
            "0") ??
            0;

    if (nam == 0) continue;

    int age = year - nam;

    if (age < 40) duoi40++;

    else if (age <= 50) t41_50++;

    else if (age <= 60) t51_60++;

    else if (age <= 70) t61_70++;

    else tren71++;
  }

  setState(() {});
}

  Widget card(
      String title,
      int value,
      String condition) {

    return Card(
      child: ListTile(

        title: Text(title),

        trailing: Text(
          "$value",
          style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold),
        ),

        onTap: () {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  StatisticListScreen(
                title: title,
                condition: condition,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    int y = DateTime.now().year;

    return Scaffold(

      appBar:
          AppBar(title: Text("Thống kê độ tuổi")),

      body: ListView(
        padding: EdgeInsets.all(12),
        children: [

          card(
            "Dưới 40 tuổi",
            duoi40,
            "($y - nam_sinh) < 40",
          ),

          card(
            "Từ 41 - 50",
            t41_50,
            "($y - nam_sinh) BETWEEN 41 AND 50",
          ),

          card(
            "Từ 51 - 60",
            t51_60,
            "($y - nam_sinh) BETWEEN 51 AND 60",
          ),

          card(
            "Từ 61 - 70",
            t61_70,
            "($y - nam_sinh) BETWEEN 61 AND 70",
          ),

          card(
            "Trên 71",
            tren71,
            "($y - nam_sinh) > 71",
          ),
        ],
      ),
    );
  }
}