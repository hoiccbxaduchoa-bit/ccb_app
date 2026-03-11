import 'package:flutter/material.dart';

class BieuMauScreen extends StatelessWidget {

Widget item(String title) {
return Card(
child: ListTile(
leading: Icon(Icons.description, color: Colors.blue),
title: Text(title),
onTap: () {},
),
);
}

@override
Widget build(BuildContext context) {


return Scaffold(
  appBar: AppBar(
    title: Text("Biểu mẫu báo cáo"),
  ),

  body: ListView(
    padding: EdgeInsets.all(10),
    children: [

      item("Mẫu báo cáo tháng-không có"),
      item("Mẫu báo cáo quý-không có"),
      item("Mẫu danh sách hội viên-không có"),

    ],
  ),
);


}
}
