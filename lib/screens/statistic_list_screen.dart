import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../services/auth_service.dart';
class StatisticListScreen extends StatefulWidget {

  final String title;
  final String condition;

  StatisticListScreen({
    required this.title,
    required this.condition,
  });

  @override
  State<StatisticListScreen> createState() =>
      _StatisticListScreenState();
}

class _StatisticListScreenState
    extends State<StatisticListScreen> {

  List members = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {

  var db = await DBService.database();

  String where = widget.condition;

  if(AuthService.role != "admin"){
    where = "$where AND chi_hoi='${AuthService.chiHoi}'";
  }

  members = await db.rawQuery(
      "SELECT * FROM members WHERE $where");

  setState(() {});
}

  @override
  Widget build(BuildContext context){

    return Scaffold(

      appBar: AppBar(
        title: Text(widget.title),
      ),

      body: ListView.builder(

        itemCount: members.length,

        itemBuilder:(c,i){

          var m = members[i];

          return Card(

            child: ListTile(

              title: Text(
                m["ho_ten"] ?? "",
                style: TextStyle(
                    fontWeight: FontWeight.bold),
              ),

              subtitle: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text("Chi hội: ${m["chi_hoi"] ?? ""}"),

                  Text("Năm sinh: ${m["nam_sinh"] ?? ""}"),

                  Text("Điện thoại: ${m["so_dien_thoai"] ?? ""}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}