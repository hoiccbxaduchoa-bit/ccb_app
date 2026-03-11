import 'package:flutter/material.dart';
import 'website_screen.dart';
import 'vanban_screen.dart';
import 'bieumau_screen.dart';
import 'tailieu_screen.dart';

class ThamKhaoScreen extends StatelessWidget {

Widget menuItem(
BuildContext context,
IconData icon,
String title,
Widget screen,
) {
return Card(
child: ListTile(
leading: Icon(icon, color: Colors.green),
title: Text(title),
trailing: Icon(Icons.arrow_forward_ios),
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => screen,
),
);
},
),
);
}

@override
Widget build(BuildContext context) {


return Scaffold(
  appBar: AppBar(
    title: Text("Tham khảo"),
  ),

  body: ListView(
    padding: EdgeInsets.all(10),

    children: [

      menuItem(
        context,
        Icons.menu_book,
        "Văn bản Hội CCB",
        VanBanScreen(),
      ),

      menuItem(
        context,
        Icons.description,
        "Biểu mẫu báo cáo",
        BieuMauScreen(),
      ),

      menuItem(
        context,
        Icons.public,
        "Trang web chính thống",
        WebsiteScreen(),
      ),


    ],
  ),
);


}
}
