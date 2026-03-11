import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'member_model.dart';

class AddMemberScreen extends StatefulWidget {
  @override
  _AddMemberScreenState createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final hoTen = TextEditingController();
  final namSinh = TextEditingController();
  final chiHoi = TextEditingController();
  final sdt = TextEditingController();

  save() async {
    await DBHelper.instance.insert(
      Member(
        hoTen: hoTen.text,
        namSinh: namSinh.text,
        chiHoi: chiHoi.text,
        soDienThoai: sdt.text,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Thêm hội viên")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: hoTen, decoration: InputDecoration(labelText: "Họ tên")),
            TextField(controller: namSinh, decoration: InputDecoration(labelText: "Năm sinh")),
            TextField(controller: chiHoi, decoration: InputDecoration(labelText: "Chi hội")),
            TextField(controller: sdt, decoration: InputDecoration(labelText: "Điện thoại")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: save, child: Text("Lưu"))
          ],
        ),
      ),
    );
  }
}