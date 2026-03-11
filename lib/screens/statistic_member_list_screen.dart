import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../services/auth_service.dart';
class StatisticMemberListScreen extends StatefulWidget {

  final String title;
  final String field;
  final String value;

  StatisticMemberListScreen({
    required this.title,
    required this.field,
    required this.value,
  });

  @override
  State<StatisticMemberListScreen> createState() =>
      _StatisticMemberListScreenState();
}

class _StatisticMemberListScreenState
    extends State<StatisticMemberListScreen> {

  List members = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {

  var db = await DBService.database();

  if(AuthService.role != "admin"){

    members = await db.rawQuery(
        "SELECT * FROM members WHERE ${widget.field}=? AND chi_hoi=?",
        [widget.value, AuthService.chiHoi]);

  }else{

    members = await db.rawQuery(
        "SELECT * FROM members WHERE ${widget.field}=?",
        [widget.value]);

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

                ],
              ),
            ),
          );
        },
      ),
    );
  }
}