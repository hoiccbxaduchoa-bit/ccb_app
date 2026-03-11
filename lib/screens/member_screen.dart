import 'package:flutter/material.dart';
import '../services/db_service.dart';
import 'add_member_screen.dart';
import 'member_detail_screen.dart';
import 'dart:io';
import '../services/photo_service.dart';
import '../services/auth_service.dart';
import '../services/permission_service.dart';
class MemberScreen extends StatefulWidget {
  @override
  State<MemberScreen> createState() =>
      _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen> {

  List members = [];
  List filtered = [];

  TextEditingController search =
      TextEditingController();

  int total = 0;

  @override
  void initState() {
    super.initState();
    load();
  }

  /// ================= LOAD DATA =================
  load() async {

    List data;

    /// ADMIN → xem toàn bộ

    if (AuthService.role == "admin") {

      data = await DBService.getMembers();

    }

    /// CHI HỘI → chỉ xem chi hội mình

    else {

      data = await DBService.getMembersByChiHoi(
          AuthService.chiHoi ?? "");

    }

    members = List.from(data);

    /// SẮP XẾP THEO TÊN

    members.sort((a, b) {

      String nameA =
          (a["ho_ten"] ?? "").trim().split(" ").last.toLowerCase();

      String nameB =
          (b["ho_ten"] ?? "").trim().split(" ").last.toLowerCase();

      return nameA.compareTo(nameB);

    });

    filtered = members;

    total = members.length;

    setState(() {});
  }

  /// ================= SEARCH =================
  searchMember(String key) {

    filtered = members.where((m) {

      return (m["ho_ten"] ?? "")
              .toLowerCase()
              .contains(key.toLowerCase()) ||

          (m["so_cccd"] ?? "")
              .toLowerCase()
              .contains(key.toLowerCase()) ||

          (m["chi_hoi"] ?? "")
              .toLowerCase()
              .contains(key.toLowerCase());

    }).toList();

    setState(() {});
  }

  /// ================= DELETE =================
  delete(int id) async {

    bool ok = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Xóa hội viên"),
        content:
            Text("Bạn chắc chắn muốn xóa hội viên này?"),
        actions: [

          TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: Text("Hủy")),

          ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context, true),
              child: Text("Xóa"))
        ],
      ),
    );

    if (ok == true) {
      await DBService.deleteMember(id);
      load();
    }
  }

  /// ================= SUMMARY =================
  Widget summaryBox() {

    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(
          horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius:
            BorderRadius.circular(10),
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

        children: [

          Text(
            "Tổng hội viên",
            style:
                TextStyle(fontSize: 16),
          ),

          Text(
            "$total",
            style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold),
          )
        ],
      ),
    );
  }
///==============PHOTO=============
  Widget avatar(Map m) {

    return FutureBuilder(

      future: PhotoService.getPhoto(m["id"]),

      builder: (context, snapshot) {
  
        if (!snapshot.hasData) {
          return CircleAvatar(
            radius: 22,
            child: Icon(Icons.person),
          );
        }

        File file = snapshot.data as File;

        if (!file.existsSync()) {
          return CircleAvatar(
            radius: 22,
            child: Icon(Icons.person),
          );
        }

        return CircleAvatar(
          radius: 22,
          backgroundImage: FileImage(file),
          key: ValueKey(file.lastModifiedSync().millisecondsSinceEpoch),
        );
      },
    );
  }
  /// ================= UI =================
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(
          AuthService.role == "admin"
              ? "Quản lý hội viên CCB"
              : "Chi hội: ${AuthService.chiHoi}",
        ),
      ),

      floatingActionButton:
          FloatingActionButton(

        child: Icon(Icons.add),

        onPressed: () async {

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AddMemberScreen(),
            ),
          );

          load();
        },
      ),

      body: Column(
        children: [

          /// SEARCH
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(

              controller: search,

              onChanged: searchMember,

              decoration: InputDecoration(
                prefixIcon:
                    Icon(Icons.search),
                hintText:
                    "Tìm theo tên / CCCD / Chi hội",
                border:
                    OutlineInputBorder(),
              ),
            ),
          ),

          summaryBox(),

          /// LIST
          Expanded(
            child: ListView.builder(

              itemCount: filtered.length,

              itemBuilder: (c, i) {

                var m = filtered[i];

                return Card(

                  margin:
                      EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5),

                  child: ListTile(

                    onTap: () async {

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              MemberDetailScreen(
                                member: Map<String,dynamic>.from(m),
                              ),
                        ),
                      );

                      load();   // reload danh sách
                    },

                    leading: avatar(m),

                    title: Text(
                      m["ho_ten"] ?? "",
                      style: TextStyle(
                          fontWeight:
                              FontWeight.bold),
                    ),

                    subtitle: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [

                        Text(
                            "Năm sinh: ${m["nam_sinh"] ?? ""}"),

                        Text(
                            "Chi hội: ${m["chi_hoi"] ?? ""}"),

                        Text(
                            "SĐT: ${m["so_dien_thoai"] ?? ""}"),
                      ],
                    ),

                    trailing: PopupMenuButton(

                      itemBuilder: (c) => [

                        PopupMenuItem(
                          value: "delete",
                          child: Text("Xóa"),
                        )

                      ],

                      onSelected: (value) async {

                        if (value == "delete") {

                          if(await PermissionService.allow(
                              context,
                              "perm_delete_member"
                          )){

                            delete(m["id"]);

                          }

                        }

                      },
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}