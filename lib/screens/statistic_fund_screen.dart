import 'package:flutter/material.dart';
import '../services/db_service.dart';
import 'statistic_list_screen.dart';
import 'fund_member_list_screen.dart';
import '../services/auth_service.dart';
class StatisticFundScreen extends StatefulWidget {
  @override
  State<StatisticFundScreen> createState() =>
      _StatisticFundScreenState();
}

class _StatisticFundScreenState
    extends State<StatisticFundScreen> {

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
      SELECT chi_hoi,
      SUM(quy_dong_doi) tong_quy,
      COUNT(*) so_hv
      FROM members
      WHERE chi_hoi='${AuthService.chiHoi}'
      GROUP BY chi_hoi
      ORDER BY chi_hoi
    ''');

  } else {

    data = await db.rawQuery('''
      SELECT chi_hoi,
      SUM(quy_dong_doi) tong_quy,
      COUNT(*) so_hv
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
        title: Text("Thống kê quỹ đồng đội"),
      ),

      body: ListView.builder(

        itemCount: data.length,

        itemBuilder: (c, i) {

          var r = data[i];

          String chiHoi =
              r["chi_hoi"]?.toString() ??
                  "Chưa xác định";

          int quy =
              (r["tong_quy"] ?? 0) as int;

          int soHV =
              (r["so_hv"] ?? 0) as int;

          return Card(

            child: ListTile(

              leading: Icon(
                Icons.account_balance_wallet,
                size: 35,
              ),

              title: Text(
                chiHoi,
                style: TextStyle(
                    fontWeight: FontWeight.bold),
              ),

              subtitle:
                  Text("Hội viên: $soHV"),

              trailing: Text(
                "$quy đ",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              onTap: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FundMemberListScreen(
                      chiHoi: chiHoi,
                    ),
                  ),
                );

              }
            ),
          );
        },
      ),
    );
  }
}