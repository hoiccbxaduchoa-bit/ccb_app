import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WebsiteScreen extends StatelessWidget {

Future<void> openLink(String url) async {


final Uri uri = Uri.parse(url);

await launchUrl(
  uri,
  mode: LaunchMode.externalApplication,
);


}

Widget webItem(String title, String url) {


return Card(
  child: ListTile(
    leading: Icon(
      Icons.language,
      color: Colors.green,
    ),
    title: Text(title),
    trailing: Icon(Icons.open_in_new),
    onTap: () {
      openLink(url);
    },
  ),
);


}

@override
Widget build(BuildContext context) {


return Scaffold(

  appBar: AppBar(
    title: Text("Trang web chính thống"),
  ),

  body: ListView(

    padding: EdgeInsets.all(10),

    children: [

      webItem(
        "Hội CCB Việt Nam",
        "https://cuuchienbinh.vn",
      ),

      webItem(
        "Cổng thông tin Chính phủ",
        "https://chinhphu.vn",
      ),

      webItem(
        "Tỉnh ủy Tây Ninh",
        "https://tayninh.dcs.vn",
      ),

      webItem(
        "UBND tỉnh Tây Ninh",
        "https://www.tayninh.gov.vn",
      ),

      webItem(
        "MTTQ tỉnh Tây Ninh",
        "https://mattrantoquoc.tayninh.gov.vn",
      ),

    ],
  ),
);


}
}
