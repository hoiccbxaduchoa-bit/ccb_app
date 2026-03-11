import 'package:flutter/material.dart';
import '../services/db_service.dart';
import 'statistic_list_screen.dart';
import '../services/auth_service.dart';
class StatisticChiHoiScreen extends StatefulWidget {
  @override
  State<StatisticChiHoiScreen> createState() =>
      _StatisticChiHoiScreenState();
}

class _StatisticChiHoiScreenState
    extends State<StatisticChiHoiScreen> {

  List data = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {

  var db = await DBService.database();

  /// nếu là chi hội trưởng → chỉ xem chi hội mình
  if(AuthService.role != "admin"){

    data = await db.rawQuery('''
      SELECT chi_hoi,
      COUNT(*) total
      FROM members
      WHERE chi_hoi='${AuthService.chiHoi}'
      GROUP BY chi_hoi
      ORDER BY chi_hoi
    ''');

  }else{

    data = await db.rawQuery('''
      SELECT chi_hoi,
      COUNT(*) total
      FROM members
      GROUP BY chi_hoi
      ORDER BY chi_hoi
    ''');

  }

  setState(() {});
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Thống kê chi hội"),
      ),

      body: ListView.builder(

        itemCount: data.length,

        itemBuilder: (c, i) {

          var r = data[i];

          String chiHoi =
              r["chi_hoi"]?.toString() ??
                  "Chưa xác định";

          int total = r["total"];

          return Card(
            child: ListTile(

              leading: Icon(Icons.location_city,
                  size: 35),

              title: Text(
                chiHoi,
                style: TextStyle(
                    fontWeight: FontWeight.bold),
              ),

              trailing: Text(
                "$total",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              onTap: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        StatisticListScreen(
                      title: "Chi hội $chiHoi",
                      condition:
                          "chi_hoi='$chiHoi'",
                    ),
                  ),
                );

              },
            ),
          );
        },
      ),
    );
  }
}