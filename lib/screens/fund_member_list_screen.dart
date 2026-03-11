import 'package:flutter/material.dart';
import '../services/db_service.dart';

class FundMemberListScreen extends StatefulWidget {

  final String chiHoi;

  FundMemberListScreen({required this.chiHoi});

  @override
  State<FundMemberListScreen> createState() =>
      _FundMemberListScreenState();
}

class _FundMemberListScreenState
    extends State<FundMemberListScreen> {

  List members = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {

    var db = await DBService.database();

    members = await db.rawQuery(
        "SELECT ho_ten, quy_dong_doi FROM members WHERE chi_hoi='${widget.chiHoi}'");

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Quỹ ${widget.chiHoi}"),
      ),

      body: ListView.builder(

        itemCount: members.length,

        itemBuilder: (c, i) {

          var m = members[i];

          return Card(

            child: ListTile(

              title: Text(
                m["ho_ten"] ?? "",
                style: TextStyle(
                    fontWeight: FontWeight.bold),
              ),

              trailing: Text(
                "${m["quy_dong_doi"] ?? 0} đ",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),

            ),
          );
        },
      ),
    );
  }
}