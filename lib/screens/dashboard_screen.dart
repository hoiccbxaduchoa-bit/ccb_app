import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'member_screen.dart';
import 'statistic_screen.dart';
import 'setting_screen.dart';
import 'tham_khao_screen.dart';
import 'tailieu_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_manage_screen.dart';
import '../services/permission_service.dart';
class DashboardScreen extends StatefulWidget {
@override
State<DashboardScreen> createState() =>
_DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

String donVi = "***";
int currentTab = 1;

@override
void initState() {
super.initState();
loadDonVi();
}

loadDonVi() async {


final prefs =
    await SharedPreferences.getInstance();

setState(() {
  donVi =
      prefs.getString("donvi") ?? "***";
});


}

/// ===============================
/// MENU BOX
/// ===============================

Widget menuBox(
String title,
IconData icon,
VoidCallback onTap,
{String? permission}) {

return Expanded(
  child: InkWell(

    onTap: () async {

      if(permission != null){

        bool ok = await PermissionService.allow(
            context,
            permission
        );

        if(!ok) return;

      }

      onTap();
    },

    child: Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 30,
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [

            Icon(
              icon,
              size: 45,
              color: Colors.green,
            ),

            SizedBox(height: 10),

            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            )

          ],
        ),
      ),
    ),
  ),
);
}

/// ===============================
/// TRANG CHỦ
/// ===============================

Widget homePage() {


return Padding(
  padding: EdgeInsets.all(15),

  child: Column(

    children: [

      SizedBox(height: 20),

      Text(
        "HỘI CCB $donVi",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 22,
          fontWeight:
              FontWeight.bold,
          color: Colors.red,
        ),
      ),

      SizedBox(height: 10),

      Divider(),

      SizedBox(height: 30),

      Row(

        children: [

          menuBox(
            "Quản lý hội viên",
            Icons.people,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      MemberScreen(),
                ),
              );
            },
          ),

          SizedBox(width: 10),

          menuBox(
           "Thống kê",
           Icons.bar_chart,
           () {
             Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (_) => StatisticScreen(),
               ),
             );
           },
           permission: "perm_statistic",
          ),

        ],
      ),

      SizedBox(height: 20),

      Row(
        children: [

          menuBox(
            "Tham khảo",
            Icons.menu_book,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ThamKhaoScreen(),
                ),
              );
            },
          ),

        ],
      ),

      SizedBox(height: 20),

      Row(
        children: [

          menuBox(
           "Tài liệu của tôi",
           Icons.folder,
           () {
             Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (_) => TaiLieuScreen(),
               ),
             );
           },
           permission: "perm_document",
          ),

        ],
      ),

    ],
  ),
);


}

/// ===============================
/// TÀI KHOẢN
/// ===============================

Widget accountPage() {


return FutureBuilder(

  future: AuthService.getAccountInfo(),

  builder: (context, snapshot) {

    if (!snapshot.hasData) {
      return Center(
          child:
              CircularProgressIndicator());
    }

    var info = snapshot.data as Map;

    return ListView(

      children: [

        SizedBox(height: 20),

        CircleAvatar(
          radius: 40,
          child: Icon(Icons.person,
              size: 40),
        ),

        SizedBox(height: 10),

        Center(
          child: Text(
            info["username"] ?? "",
            style: TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),

        SizedBox(height: 5),

        Center(
          child: Text(
            info["role"] ?? "",
            style: TextStyle(
                color: Colors.grey),
          ),
        ),

        Center(
          child: Text(
            "Chi hội: ${info["chiHoi"]}",
            style: TextStyle(
                color: Colors.grey),
          ),
        ),

        SizedBox(height: 20),

        Divider(),

        ListTile(
          leading: Icon(Icons.lock),
          title: Text("Đổi mật khẩu"),

          onTap: () {

            TextEditingController newPass =
                TextEditingController();

            showDialog(

              context: context,

              builder: (_) => AlertDialog(

                title: Text("Đổi mật khẩu"),

                content: TextField(
                  controller: newPass,
                  obscureText: true,
                  decoration:
                      InputDecoration(
                    labelText:
                        "Mật khẩu mới",
                  ),
                ),

                actions: [

                  TextButton(
                    child: Text("Hủy"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),

                  ElevatedButton(
                    child: Text("Lưu"),
                    onPressed: () async {

                      await AuthService
                          .changePassword(
                        newPass.text,
                      );

                      Navigator.pop(context);

                      ScaffoldMessenger.of(
                              context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                              "Đã đổi mật khẩu"),
                        ),
                      );

                    },
                  ),

                ],

              ),

            );

          },
        ),

        if (AuthService.role == "admin")

          ListTile(
            leading:
                Icon(Icons.people),
            title: Text(
                "Quản lý tài khoản chi hội"),

            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      UserManageScreen(),
                ),
              );

            },
          ),

        Divider(),

        ListTile(
          leading: Icon(Icons.logout),
          title: Text("Đăng xuất"),

          onTap: () async {

            await AuthService.logout();

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    LoginScreen(),
              ),
            );

          },
        ),

      ],

    );

  },

);


}

@override
Widget build(BuildContext context) {


List<Widget> pages = [

  accountPage(),
  homePage(),
  SettingScreen(),

];

return Scaffold(

  body: pages[currentTab],

  bottomNavigationBar:
      BottomNavigationBar(

    currentIndex: currentTab,

    onTap: (index) {

      setState(() {
        currentTab = index;
      });

    },

    items: [

      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: "Tài khoản",
      ),

      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: "Trang chủ",
      ),

      BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: "Cài đặt",
      ),

    ],

  ),

);


}

}
