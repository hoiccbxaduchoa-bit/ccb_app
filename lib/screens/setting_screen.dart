import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/db_service.dart';
import '../services/backup_service.dart';
import '../services/auth_service.dart';
import '../services/permission_service.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../services/import_service.dart';

class SettingScreen extends StatefulWidget {
  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {

  TextEditingController donVi = TextEditingController();

  bool loading = false;

  // ===== SHARE BACKUP =====
  shareBackup() async {
    try {
      String path = await BackupService.createBackup();

      final file = File(path);

      if (!file.existsSync()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Không tìm thấy file backup")),
        );
        return;
      }

      await Share.shareXFiles(
        [XFile(file.path)],
        text: "Dữ liệu Hội CCB",
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Gửi file thất bại")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadConfig();
  }

  loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    donVi.text = prefs.getString("donvi") ?? "XÃ ĐỨC HOÀ";
  }

  saveConfig() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      "donvi",
      donVi.text.toUpperCase(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Đã lưu tên đơn vị")),
    );

    Navigator.pop(context);
  }

  // ===== IMPORT + MERGE ZIP =====
  syncPRO() async {

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result == null) return;

    final path = result.files.single.path!;

    setState(() => loading = true);

    bool ok = await ImportService.importZip(path);

    setState(() => loading = false);

    if (ok) {
      await DBService.closeDB();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Đã gộp dữ liệu thành công")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Lỗi import dữ liệu")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [

        Scaffold(

          appBar: AppBar(
            title: Text("Cài đặt hệ thống"),
            centerTitle: true,
            elevation: 1,
          ),

          body: SingleChildScrollView(
            padding: EdgeInsets.all(12),
            child: Column(
              children: [

                // ===== TÊN ĐƠN VỊ =====
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text("Tên đơn vị",
                            style: TextStyle(fontWeight: FontWeight.bold)),

                        SizedBox(height: 8),

                        TextField(
                          controller: donVi,
                          decoration: InputDecoration(
                            hintText: "Nhập tên đơn vị...",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),

                        SizedBox(height: 10),

                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              if (AuthService.role != "admin") {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Không được phép sửa")),
                                );
                                return;
                              }
                              saveConfig();
                            },
                            child: Text("Lưu"),
                          ),
                        )

                      ],
                    ),
                  ),
                ),

                SizedBox(height: 12),

                // ===== ĐỒNG BỘ =====
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text("Đồng bộ dữ liệu từ PC",
                            style: TextStyle(fontWeight: FontWeight.bold)),

                        SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.sync),
                            label: Text("Chọn file Backup ZIP"),
                            onPressed: () async {
                              if(!await PermissionService.allow(
                                  context, "perm_setting")) return;
                              syncPRO();
                            },
                          ),
                        ),

                        SizedBox(height: 8),

                        Text(
                          "Trong file ZIP phải có: file 'members.db' và thư mục 'photos'.",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),

                      ],
                    ),
                  ),
                ),

                SizedBox(height: 12),

                // ===== BACKUP =====
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text("Sao lưu dữ liệu",
                            style: TextStyle(fontWeight: FontWeight.bold)),

                        SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.send),
                            label: Text("Tạo & gửi file backup qua Zalo"),
                            onPressed: () async {
                              if(!await PermissionService.allow(
                                  context, "perm_setting")) return;
                              shareBackup();
                            },
                          ),
                        ),

                      ],
                    ),
                  ),
                ),

                SizedBox(height: 12),

                // ===== THÔNG TIN APP =====
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        Text("Thông tin ứng dụng",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),

                        Divider(height: 20),

                        Text("Version 1.26",
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),

                        SizedBox(height: 6),

                        Text("Ứng dụng Quản lý HCCB",
                            style: TextStyle(color: Colors.red)),

                        SizedBox(height: 6),

                        Text("Developed by MrDuy",
                            style: TextStyle(
                                color: Colors.red,
                                fontStyle: FontStyle.italic)),

                        SizedBox(height: 6),

                        Text("Hotline: 0987 947 113",
                            style: TextStyle(
                                color: Colors.red,
                                fontStyle: FontStyle.italic)),

                      ],
                    ),
                  ),
                ),

                SizedBox(height: 10),

              ],
            ),
          ),
        ),

        // ===== LOADING =====
        if (loading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )

      ],
    );
  }
}