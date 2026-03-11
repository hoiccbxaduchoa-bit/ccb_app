import 'package:flutter/material.dart';
import '../services/db_service.dart';
import 'add_member_screen.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/photo_service.dart';
class MemberDetailScreen extends StatefulWidget {

  final Map member;

  const MemberDetailScreen({
    super.key,
    required this.member,
  });

  @override
  State<MemberDetailScreen> createState() =>
      _MemberDetailScreenState();
}

class _MemberDetailScreenState
    extends State<MemberDetailScreen> {

  late Map member;

  @override
  void initState() {
    super.initState();
    member = widget.member;
  }

  /// ================= ROW =================
  Widget row(String title, dynamic value) {

    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 6),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          SizedBox(
            width: 160,
            child: Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child:
                Text(value?.toString() ?? ""),
          )
        ],
      ),
    );
  }

  /// ================= DELETE =================
  Future deleteMember(BuildContext context) async {

    bool? ok = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xóa hội viên"),
        content: const Text(
            "Bạn chắc chắn muốn xóa hội viên này?"),

        actions: [

          TextButton(
            onPressed: () =>
                Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),

          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, true),
            child: const Text("Xóa"),
          )
        ],
      ),
    );

    if (ok == true) {

      await DBService.deleteMember(member["id"]);

      Navigator.pop(context, true);
    }
  }

  /// ================= PRINT =================
  Future printMember() async {

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (_) {

          pw.Widget line(String t, dynamic v) {

            return pw.Padding(
              padding: const pw.EdgeInsets.only(
                  bottom: 6),

              child: pw.Row(
                children: [

                  pw.SizedBox(
                    width: 150,
                    child: pw.Text(
                      "$t:",
                      style: pw.TextStyle(
                        fontWeight:
                            pw.FontWeight.bold,
                      ),
                    ),
                  ),

                  pw.Expanded(
                    child: pw.Text(
                        v?.toString() ?? ""),
                  )
                ],
              ),
            );
          }

          return pw.Column(
            crossAxisAlignment:
                pw.CrossAxisAlignment.start,

            children: [

              pw.Center(
                child: pw.Text(
                  "THÔNG TIN HỘI VIÊN CCB",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight:
                        pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.SizedBox(height: 20),

              line("Họ tên", member["ho_ten"]),
              line("CCCD", member["so_cccd"]),
              line("Năm sinh",
                  member["nam_sinh"]),
              line("Chi hội",
                  member["chi_hoi"]),
              line("Điện thoại",
                  member["so_dien_thoai"]),
              line("Ngày vào hội",
                  member["ngay_vao_hoi"]),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
    );
  }

  /// ================= PICK IMAGE =================
  pickImage() async {

  final picker = ImagePicker();

  final image = await picker.pickImage(
    source: ImageSource.gallery,
  );

  if (image == null) return;

  File newImage = File(image.path);

  File photoFile =
      await PhotoService.getPhoto(member["id"]);

  if (photoFile.existsSync()) {
    photoFile.deleteSync();
  }

  await newImage.copy(photoFile.path);

  setState(() {
    member = Map.from(member);
  });
}

  /// ================= PHOTO BOX =================
  Widget photoBox() {

    return FutureBuilder<File>(

      future: PhotoService.getPhoto(member["id"]),

      key: ValueKey(member["id"].toString() + DateTime.now().toString()),

      builder: (context, snapshot) {

        if (!snapshot.hasData) {

          return Container(
            width: 120,
            height: 180,
            child: Center(child: Text("PHOTO")),
          );

        }

        File file = snapshot.data!;

        return Container(
          width: 120,
          height: 180,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
          ),
          child: file.existsSync()
              ? Image.file(
                  file,
                  fit: BoxFit.cover,
                  key: ValueKey(file.lastModifiedSync().toString()),
                )
              : Center(
                  child: Text(
                    "PHOTO",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        );
      },
    );
  }
  /// ================= UI =================
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title:
            const Text("Thông tin hội viên"),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(15),

        child: Column(

          children: [

            photoBox(),

            const SizedBox(height: 10),

            ElevatedButton.icon(
              icon: const Icon(Icons.photo),
              label: const Text("Đổi ảnh"),
              onPressed: pickImage,
            ),

            row("Họ tên", member["ho_ten"]),
            row("CCCD", member["so_cccd"]),
            row("Năm sinh", member["nam_sinh"]),
            row("Chi hội", member["chi_hoi"]),
            row("Điện thoại",
                member["so_dien_thoai"]),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,

              children: [

                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text("Sửa"),
                  onPressed: () async {

                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddMemberScreen(
                          member:
                              Map<String,
                                      dynamic>.from(
                                  member),
                        ),
                      ),
                    );

                    Navigator.pop(context, true);
                  },
                ),

                ElevatedButton.icon(
                  icon: const Icon(Icons.print),
                  label: const Text("In"),
                  onPressed: printMember,
                ),

                ElevatedButton.icon(
                  icon: const Icon(Icons.delete),
                  label: const Text("Xóa"),
                  onPressed: () =>
                      deleteMember(context),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}