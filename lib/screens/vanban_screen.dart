import 'package:flutter/material.dart';
import 'pdf_view_screen.dart';

class VanBanScreen extends StatelessWidget {

Widget item(
BuildContext context,
String title,
String file,
) {


return Card(
  child: ListTile(
    leading: Icon(
      Icons.picture_as_pdf,
      color: Colors.red,
    ),
    title: Text(title),

    onTap: () {

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfViewScreen(
            title: title,
            path: file,
          ),
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
    title: Text("Văn bản Hội CCB"),
  ),

  body: ListView(
    padding: EdgeInsets.all(10),

    children: [

      item(
        context,
        "Pháp lệnh Cựu chiến binh",
        "assets/vanban/phap_lenh_ccb.pdf",
      ),

      item(
        context,
        "Điều lệ Hội CCB Việt Nam",
        "assets/vanban/dieu_le_hoi_ccb.pdf",
      ),

      item(
        context,
        "Hướng dẫn thi hành Điều lệ",
        "assets/vanban/huong_dan_thi_hanh.pdf",
      ),

    ],
  ),
);


}
}
