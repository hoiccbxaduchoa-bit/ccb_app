import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/sync_service.dart';
import '../services/db_service.dart';
import '../services/backup_service.dart';
import '../services/auth_service.dart';
import '../services/permission_service.dart';
class SettingScreen extends StatefulWidget {
@override
State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {

TextEditingController donVi = TextEditingController();

@override
void initState() {
super.initState();
loadConfig();
}

loadConfig() async {


final prefs = await SharedPreferences.getInstance();

donVi.text =
    prefs.getString("donvi") ??
    "HỘI CCB XÃ ĐỨC HOÀ";


}

saveConfig() async {


final prefs = await SharedPreferences.getInstance();

await prefs.setString(
  "donvi",
  donVi.text.toUpperCase(),
);

ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text("Đã lưu tên đơn vị"),
  ),
);

Navigator.pop(context);


}

syncPRO() async {


bool ok = await SyncService.syncBackup();

if (ok) {

  await DBService.closeDB();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("✅ Đồng bộ dữ liệu + ảnh thành công"),
    ),
  );

} else {

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("❌ Đồng bộ thất bại"),
    ),
  );

}


}

backupData() async {


try {

  String path = await BackupService.createBackup();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("✅ Đã tạo backup: $path"),
    ),
  );

} catch (e) {

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("❌ Backup thất bại"),
    ),
  );

}


}

@override
Widget build(BuildContext context) {


return Scaffold(

  appBar: AppBar(
    title: Text("Cài đặt hệ thống"),
  ),

  body: SingleChildScrollView(

    padding: EdgeInsets.all(15),

    child: Column(

      children: [

        Card(
          child: Padding(
            padding: EdgeInsets.all(12),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(
                  "Tên đơn vị",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8),

                TextField(
                  controller: donVi,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 8),

                ElevatedButton(

                  onPressed: () {

                    if (AuthService.role != "admin") {

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Không được phép sửa"),
                        ),
                      );

                      return;
                    }

                    saveConfig();

                  },

                  child: Text("Lưu"),
                )

              ],
            ),
          ),
        ),

        SizedBox(height: 18),

        Card(
          child: Padding(
            padding: EdgeInsets.all(12),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(
                  "Đồng bộ dữ liệu từ PC",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8),

                ElevatedButton.icon(
                  icon: Icon(Icons.sync),
                  label: Text("Chọn file Backup ZIP"),
                  onPressed: () async {

                   if(!await PermissionService.allow(
                          context,
                          "perm_setting"
                   )) return;

                   syncPRO();

                  },
                ),

              ],
            ),
          ),
        ),

        SizedBox(height: 18),

        Card(
          child: Padding(
            padding: EdgeInsets.all(12),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(
                  "Sao lưu dữ liệu",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8),

                ElevatedButton.icon(
                  icon: Icon(Icons.backup),
                  label: Text("Tạo file ccb_backup.zip"),
                  onPressed: () async {

                   if(!await PermissionService.allow(
                          context,
                          "perm_setting"
                   )) return;

                   backupData();

                  },
                ),

              ],
            ),
          ),
        ),

        SizedBox(height: 18),

        Card(
          child: Padding(
            padding: EdgeInsets.all(12),

            child: Column(

              children: [

                Text(
                  "Thông tin ứng dụng",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                SizedBox(height: 15),

                Text(
                  "Version 1.26",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  "Ứng dụng Quản lý HCCB",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  "Developed by MrDuy",
                  style: TextStyle(
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  "Hotline: 0987 947 113",
                  style: TextStyle(
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                  ),
                ),

              ],
            ),
          ),
        ),

      ],
    ),
  ),
);


}
}
