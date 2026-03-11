import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../services/auth_service.dart';
import 'statistic_list_screen.dart';
import 'statistic_member_screen.dart';
import 'statistic_chihoi_screen.dart';
import 'statistic_age_screen.dart';
import 'statistic_policy_screen.dart';
import 'statistic_fund_screen.dart';

class StatisticScreen extends StatefulWidget {
  @override
  State<StatisticScreen> createState() =>
      _StatisticScreenState();
}

class _StatisticScreenState
    extends State<StatisticScreen> {

  int tong = 0;
  int dangVien = 0;
  int bhyt = 0;
  int msh = 0;
  int quyTong = 0;

  @override
  void initState() {
    super.initState();
    loadStatistic();
  }

  loadStatistic() async {

  var db = await DBService.database();

  String where = "";

  if(AuthService.role != "admin"){
    where = " WHERE chi_hoi='${AuthService.chiHoi}' ";
  }

  var t = await db.rawQuery(
      "SELECT COUNT(*) c FROM members $where");

  var d = await db.rawQuery(
      "SELECT COUNT(*) c FROM members $where ${where.isEmpty ? "WHERE" : "AND"} ngay_vao_dang!=''");

  var b = await db.rawQuery(
      "SELECT COUNT(*) c FROM members $where ${where.isEmpty ? "WHERE" : "AND"} bhyt='Có'");

  var m = await db.rawQuery(
      "SELECT COUNT(*) c FROM members $where ${where.isEmpty ? "WHERE" : "AND"} mien_sinh_hoat='Có'");

  var q = await db.rawQuery(
      "SELECT SUM(quy_dong_doi) s FROM members $where");

  setState(() {
    tong = t.first["c"] as int;
    dangVien = d.first["c"] as int;
    bhyt = b.first["c"] as int;
    msh = m.first["c"] as int;
    quyTong = (q.first["s"] ?? 0) as int;
  });
}

  Widget card(String title,String value,IconData icon,String condition){

    return Card(
      child: ListTile(

        leading: Icon(icon,size:35),

        title: Text(title),

        trailing: Text(
          value,
          style: TextStyle(
            fontSize:18,
            fontWeight: FontWeight.bold,
          ),
        ),

        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StatisticListScreen(
                title: title,
                condition: condition,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget proMenu(String title,IconData icon,Widget screen){

    return Card(
      child: ListTile(
        leading: Icon(icon,size:35),
        title: Text(title,
            style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context){

    int quyBQ = tong==0 ? 0 : (quyTong~/tong);

    return Scaffold(

      appBar: AppBar(title: Text("Thống kê nhanh")),

      body: ListView(
        padding: EdgeInsets.all(12),
        children: [

          Text("📊 Tổng hợp Hội CCB",
              style: TextStyle(
                  fontSize:18,fontWeight: FontWeight.bold)),

          SizedBox(height:9),

          card("Tổng hội viên","$tong",Icons.people,"1=1"),
          card("Đảng viên","$dangVien",Icons.flag,"ngay_vao_dang!=''"),
          card("Có BHYT","$bhyt",Icons.health_and_safety,"bhyt='Có'"),
          card("Miễn sinh hoạt","$msh",Icons.event_busy,"mien_sinh_hoat='Có'"),
          card("Quỹ bình quân","$quyBQ đ",Icons.account_balance_wallet,"1=1"),

          SizedBox(height:18),

          Text("📊 Thống kê nâng cao",
              style: TextStyle(
                  fontSize:18,fontWeight: FontWeight.bold)),

          
          proMenu("Thống kê theo chi hội",Icons.location_city,StatisticChiHoiScreen()),
          proMenu("Thống kê theo độ tuổi",Icons.elderly,StatisticAgeScreen()),
          proMenu("Thống kê theo chính sách",Icons.assignment,StatisticPolicyScreen()),
          proMenu("Thống kê quỹ đồng đội",Icons.account_balance_wallet,StatisticFundScreen()),
          proMenu("Thông tin khác",Icons.people,StatisticMemberScreen()),
        ],
      ),
    );
  }
}