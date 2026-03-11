import 'package:flutter/material.dart';
import '../services/db_service.dart';
import 'statistic_list_screen.dart';

class StatisticPolicyScreen extends StatefulWidget {
  @override
  State<StatisticPolicyScreen> createState() =>
      _StatisticPolicyScreenState();
}

class _StatisticPolicyScreenState
    extends State<StatisticPolicyScreen> {

  List data = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {

    var db = await DBService.database();

    data = await db.rawQuery('''
      SELECT che_do_chinh_sach,
      COUNT(*) total
      FROM members
      GROUP BY che_do_chinh_sach
      ORDER BY che_do_chinh_sach
    ''');

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Thống kê chế độ chính sách"),
      ),

      body: ListView.builder(

        itemCount: data.length,

        itemBuilder: (c, i) {

          var r = data[i];

          String cs =
              r["che_do_chinh_sach"]?.toString() ??
                  "Chưa xác định";

          int total = r["total"];

          return Card(
            child: ListTile(

              leading:
                  Icon(Icons.assignment, size: 35),

              title: Text(
                cs,
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
                      title: cs,
                      condition:
                          "che_do_chinh_sach='$cs'",
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