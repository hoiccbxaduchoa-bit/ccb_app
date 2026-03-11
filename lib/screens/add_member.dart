import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/db_service.dart';

class AddMember extends StatefulWidget {
  @override
  State<AddMember> createState() => _AddMemberState();
}

class _AddMemberState extends State<AddMember> {

  final hoTen = TextEditingController();
  final namSinh = TextEditingController();
  final diaChi = TextEditingController();
  final chiHoi = TextEditingController();
  final chucVu = TextEditingController();
  final sdt = TextEditingController();

  File? image;

  Future pickImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (picked != null) {
      image = File(picked.path);
      setState(() {});
    }
  }

  Future save() async {
    await DBService.insert({
      "hoTen": hoTen.text,
      "namSinh": namSinh.text,
      "diaChi": diaChi.text,
      "chiHoi": chiHoi.text,
      "chucVu": chucVu.text,
      "dienThoai": sdt.text,
      "image": image?.path
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thêm hội viên"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [

            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 55,
                backgroundImage:
                    image != null ? FileImage(image!) : null,
                child:
                    image == null ? Icon(Icons.camera_alt, size: 35) : null,
              ),
            ),

            SizedBox(height: 20),

            TextField(
              controller: hoTen,
              decoration: InputDecoration(labelText: "Họ tên"),
            ),

            TextField(
              controller: namSinh,
              decoration: InputDecoration(labelText: "Năm sinh"),
            ),

            TextField(
              controller: diaChi,
              decoration: InputDecoration(labelText: "Địa chỉ"),
            ),

            TextField(
              controller: chiHoi,
              decoration: InputDecoration(labelText: "Chi hội"),
            ),

            TextField(
              controller: chucVu,
              decoration: InputDecoration(labelText: "Chức vụ"),
            ),

            TextField(
              controller: sdt,
              decoration: InputDecoration(labelText: "Điện thoại"),
            ),

            SizedBox(height: 25),

            ElevatedButton(
              onPressed: save,
              child: Text("Lưu hội viên"),
            ),
          ],
        ),
      ),
    );
  }
}