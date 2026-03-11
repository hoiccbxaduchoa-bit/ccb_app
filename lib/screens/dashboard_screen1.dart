import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'member_screen.dart';
import 'statistic_screen.dart';
import 'setting_screen.dart';
import 'tham_khao_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
@override
State<DashboardScreen> createState() =>
_DashboardScreenState();
}

class _DashboardScreenState
extends State<DashboardScreen> {

String donVi = "***";

@override
void initState() {
super.initState();
loadDonVi();
}

/// LOAD TÊN ĐƠN VỊ
loadDonVi() async {


final prefs =
    await SharedPreferences.getInstance();

setState(() {

  donVi =
      prefs.getString("donvi") ?? "***";

});


}

Widget menu(
BuildContext context,
String title,
IconData icon,
Widget screen,
) {
return InkWell(
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => screen,
),
);
},
child: Card(
elevation: 3,
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [


        Icon(
          icon,
          size: 45,
          color: Colors.green,
        ),

        SizedBox(height: 10),

        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    ),
  ),
);


}

@override
Widget build(BuildContext context) {


return Scaffold(
  appBar: AppBar(

    /// TIÊU ĐỀ TỰ ĐỘNG
    title: Text(
      "HỘI CCB $donVi",
    ),

    actions: [

      IconButton(
        icon: Icon(Icons.logout),

        onPressed: () async {

          await AuthService.logout();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  LoginScreen(),
            ),
          );
        },
      )
    ],
  ),

  body: GridView.count(

    crossAxisCount: 2,
    padding: EdgeInsets.all(15),

    children: [

      menu(
        context,
        "Quản lý hội viên",
        Icons.people,
        MemberScreen(),
      ),

      menu(
        context,
        "Thống kê",
        Icons.bar_chart,
        StatisticScreen(),
      ),

      /// ĐỔI BÁO CÁO → THAM KHẢO

      menu(
        context,
        "Tham khảo",
        Icons.menu_book,
        ThamKhaoScreen(),
      ),

      menu(
        context,
        "Cài đặt",
        Icons.settings,
        SettingScreen(),
      ),
    ],
  ),
);


}
}
