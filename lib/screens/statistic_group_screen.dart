import 'package:flutter/material.dart';
import '../services/db_service.dart';
import 'statistic_member_list_screen.dart';
import '../services/auth_service.dart';
class StatisticGroupScreen extends StatefulWidget {

  final String title;
  final String field;

  StatisticGroupScreen({
    required this.title,
    required this.field,
  });

  @override
  State<StatisticGroupScreen> createState() =>
      _StatisticGroupScreenState();
}

class _StatisticGroupScreenState
    extends State<StatisticGroupScreen> {

  List data = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {

  var db = await DBService.database();

  if (AuthService.role != "admin") {

    data = await db.rawQuery('''
      SELECT ${widget.field} value,
      COUNT(*) total
      FROM members
      WHERE chi_hoi='${AuthService.chiHoi}'
      GROUP BY ${widget.field}
      ORDER BY total DESC
    ''');

  } else {

    data = await db.rawQuery('''
      SELECT ${widget.field} value,
      COUNT(*) total
      FROM members
      GROUP BY ${widget.field}
      ORDER BY total DESC
    ''');

  }

  setState(() {});
}

  @override
  Widget build(BuildContext context){

    return Scaffold(

      appBar: AppBar(
        title: Text(widget.title),
      ),

      body: ListView.builder(

        itemCount: data.length,

        itemBuilder:(c,i){

          var r = data[i];

          String value =
              r["value"]?.toString() ??
                  "Chưa xác định";

          int total = r["total"];

          return Card(

            child: ListTile(

              title: Text(
                value,
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

              onTap:(){

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        StatisticMemberListScreen(
                      title: value,
                      field: widget.field,
                      value: value,
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