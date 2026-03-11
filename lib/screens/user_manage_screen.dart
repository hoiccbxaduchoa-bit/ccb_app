import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/db_service.dart';
import '../services/permission_service.dart';

class UserManageScreen extends StatefulWidget {
@override
State<UserManageScreen> createState() => _UserManageScreenState();
}

class _UserManageScreenState extends State<UserManageScreen> {

List users = [];

@override
void initState() {
super.initState();
load();
}

/// ================= LOAD USERS =================

load() async {


users = await DBService.getUsers();

setState(() {});


}

/// ================= CREATE USER =================

addUserDialog(){


TextEditingController user = TextEditingController();
TextEditingController pass = TextEditingController();
TextEditingController chiHoi = TextEditingController();

showDialog(
  context: context,
  builder: (_) => AlertDialog(

    title: Text("Tạo tài khoản chi hội"),

    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        TextField(
          controller: user,
          decoration: InputDecoration(labelText: "Tên đăng nhập"),
        ),

        TextField(
          controller: pass,
          decoration: InputDecoration(labelText: "Mật khẩu"),
        ),

        TextField(
          controller: chiHoi,
          decoration: InputDecoration(labelText: "Chi hội"),
        ),

      ],
    ),

    actions: [

      TextButton(
        child: Text("Hủy"),
        onPressed: (){
          Navigator.pop(context);
        },
      ),

      ElevatedButton(
        child: Text("Tạo"),
        onPressed: () async {

          await DBService.createUser(
            user.text.trim(),
            pass.text.trim(),
            "user",
            chiHoi.text.trim(),
          );

          Navigator.pop(context);
          load();
        },
      ),

    ],

  ),
);


}

/// ================= RESET PASSWORD =================

resetPassword(int id) async {


await DBService.resetPassword(id);

ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text("Đã reset mật khẩu = 123456")),
);


}

/// ================= DELETE USER =================

deleteUser(int id) async {


bool ok = await showDialog(
  context: context,
  builder: (_) => AlertDialog(

    title: Text("Xóa tài khoản"),

    content: Text("Bạn chắc chắn muốn xóa tài khoản này?"),

    actions: [

      TextButton(
        onPressed: ()=>Navigator.pop(context,false),
        child: Text("Hủy"),
      ),

      ElevatedButton(
        onPressed: ()=>Navigator.pop(context,true),
        child: Text("Xóa"),
      )

    ],
  ),
);

if(ok == true){
  await DBService.deleteUser(id);
  load();
}


}

/// ================= PERMISSION =================

permissionDialog(String user) async {


final prefs = await SharedPreferences.getInstance();

bool add = prefs.getBool("${user}_perm_add_member") ?? false;
bool edit = prefs.getBool("${user}_perm_edit_member") ?? false;
bool del = prefs.getBool("${user}_perm_delete_member") ?? false;
bool stat = prefs.getBool("${user}_perm_statistic") ?? false;
bool doc = prefs.getBool("${user}_perm_document") ?? false;
bool setting = prefs.getBool("${user}_perm_setting") ?? false;

showDialog(
  context: context,
  builder: (_) {

    return StatefulBuilder(
      builder: (context,setLocal){

        return AlertDialog(

          title: Text("Cấp quyền tài khoản"),

          content: SingleChildScrollView(

            child: Column(

              mainAxisSize: MainAxisSize.min,

              children: [

                SwitchListTile(
                  title: Text("Thêm hội viên"),
                  value: add,
                  onChanged:(v) async{
                    add = v;
                    await PermissionService.set(user,"perm_add_member",v);
                    setLocal((){});
                  },
                ),

                SwitchListTile(
                  title: Text("Sửa hội viên"),
                  value: edit,
                  onChanged:(v) async{
                    edit = v;
                    await PermissionService.set(user,"perm_edit_member",v);
                    setLocal((){});
                  },
                ),

                SwitchListTile(
                  title: Text("Xóa hội viên"),
                  value: del,
                  onChanged:(v) async{
                    del = v;
                    await PermissionService.set(user,"perm_delete_member",v);
                    setLocal((){});
                  },
                ),

                SwitchListTile(
                  title: Text("Thống kê"),
                  value: stat,
                  onChanged:(v) async{
                    stat = v;
                    await PermissionService.set(user,"perm_statistic",v);
                    setLocal((){});
                  },
                ),

                SwitchListTile(
                  title: Text("Tài liệu"),
                  value: doc,
                  onChanged:(v) async{
                    doc = v;
                    await PermissionService.set(user,"perm_document",v);
                    setLocal((){});
                  },
                ),

                SwitchListTile(
                  title: Text("Cài đặt"),
                  value: setting,
                  onChanged:(v) async{
                    setting = v;
                    await PermissionService.set(user,"perm_setting",v);
                    setLocal((){});
                  },
                ),

              ],

            ),
          ),
        );
      },
    );
  },
);


}

/// ================= UI =================

@override
Widget build(BuildContext context) {


return Scaffold(

  appBar: AppBar(
    title: Text("Quản lý tài khoản chi hội"),
  ),

  floatingActionButton: FloatingActionButton(
    child: Icon(Icons.add),
    onPressed: addUserDialog,
  ),

  body: ListView.builder(

    itemCount: users.length,

    itemBuilder:(context,i){

      var u = users[i];

      if(u["username"]=="admin"){
        return SizedBox();
      }

      return Card(

        margin: EdgeInsets.symmetric(horizontal: 10,vertical: 5),

        child: ListTile(

          leading: Icon(Icons.person),

          title: Text(
            u["username"] ?? "",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          subtitle: Text("Chi hội: ${u["chi_hoi"]}"),

          trailing: PopupMenuButton(

            itemBuilder:(context)=>[

              PopupMenuItem(
                value:"perm",
                child:Text("Cấp quyền"),
              ),

              PopupMenuItem(
                value:"reset",
                child:Text("Reset mật khẩu"),
              ),

              PopupMenuItem(
                value:"delete",
                child:Text("Xóa tài khoản"),
              ),

            ],

            onSelected:(value){

              if(value=="perm"){
                permissionDialog(u["username"]);
              }

              if(value=="reset"){
                resetPassword(u["id"]);
              }

              if(value=="delete"){
                deleteUser(u["id"]);
              }

            },

          ),

        ),
      );
    },
  ),
);


}
}
