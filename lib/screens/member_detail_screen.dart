import 'package:flutter/material.dart';
import '../services/db_service.dart';
import 'add_member_screen.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/photo_service.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
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

  bool isPhone = title.toLowerCase().contains("điện thoại");

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        SizedBox(
          width: 160,
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        Expanded(
          child: isPhone
              ? InkWell(   // 👈 đổi từ GestureDetector → InkWell (mượt hơn)
                  onTap: () async {

                    final phone = value?.toString().trim() ?? "";
                    if (phone.isEmpty) return;

                    final uri = Uri(scheme: 'tel', path: phone);

                    try {
                      await launchUrl(uri);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Không thể thực hiện cuộc gọi"),
                        ),
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          value?.toString() ?? "",
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Icon(Icons.phone, size: 16, color: Colors.green) // 👈 thêm icon
                    ],
                  ),
                )
              : Text(value?.toString() ?? ""),
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
  final prefs = await SharedPreferences.getInstance();
  final tenDonVi =
    (prefs.getString("donvi") ?? "XÃ ĐỨC HOÀ").toUpperCase();
  String chucDanhKy = "CHỦ TỊCH";

  if (AuthService.role != "admin") {
    chucDanhKy = "CHI HỘI TRƯỞNG";
  }
  // ===== FONT =====
  final font = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
  final boldFont = await rootBundle.load("assets/fonts/Roboto-Bold.ttf");

  final ttf = pw.Font.ttf(font);
  final ttfBold = pw.Font.ttf(boldFont);

  // ===== LOGO =====
  final logo = await rootBundle.load("assets/images/logo_ccb.png");
  final logoImage = pw.MemoryImage(logo.buffer.asUint8List());

  // ===== ẢNH HỘI VIÊN =====
  File photoFile = await PhotoService.getPhoto(member["id"]);
  pw.ImageProvider? memberImage;

  if (photoFile.existsSync()) {
    memberImage = pw.MemoryImage(photoFile.readAsBytesSync());
  }

  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(   // 👈 đổi sang MultiPage để không bị tràn trang
      build: (_) {

        pw.Widget line(String t, dynamic v) {
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  width: 160,
                  child: pw.Text(
                    "$t",
                    style: pw.TextStyle(font: ttfBold),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    v?.toString() ?? "",
                    style: pw.TextStyle(font: ttf),
                  ),
                )
              ],
            ),
          );
        }

        return [

          // ===== HEADER =====
pw.Row(
  crossAxisAlignment: pw.CrossAxisAlignment.start,
  children: [

    pw.Image(logoImage, width: 55),

    pw.SizedBox(width: 6),

    pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [

        pw.Text(
          "HỘI CỰU CHIẾN BINH VIỆT NAM",
          style: pw.TextStyle(font: ttfBold, fontSize: 12),
        ),

        pw.Text(
          tenDonVi,
          style: pw.TextStyle(font: ttfBold, fontSize: 12),
        ),

        pw.SizedBox(height: 3),

        pw.Text(
          "THÔNG TIN HỘI VIÊN",
          style: pw.TextStyle(font: ttfBold, fontSize: 16),
        ),
      ],
    )
  ],
),

pw.SizedBox(height: 10),
pw.Divider(thickness: 1), // 👈 thêm cho đẹp
pw.SizedBox(height: 15),

          // ===== ẢNH + THÔNG TIN =====
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

              pw.Container(
                width: 100,
                height: 130,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                ),
                child: memberImage != null
                    ? pw.Image(memberImage, fit: pw.BoxFit.cover)
                    : pw.Center(
                        child: pw.Text("NO PHOTO",
                            style: pw.TextStyle(font: ttf)),
                      ),
              ),

              pw.SizedBox(width: 15),

              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [

                    line("Họ tên:", member["ho_ten"]),
                    line("CCCD:", member["so_cccd"]),
                    line("Năm sinh:", member["nam_sinh"]),
                    line("Chi hội:", member["chi_hoi"]),
                    line("Điện thoại:", member["so_dien_thoai"]),
                    line("Ngày vào hội:", member["ngay_vao_hoi"]),
                    line("Chức vụ hội:", member["chuc_vu_hoi"]),
                    line("Ngày nhập ngũ:", member["ngay_nhap_ngu"]),
                    line("Ngày xuất ngũ:", member["ngay_xuat_ngu"]),
                    line("Cấp bậc:", member["cap_bac_truoc_xuat_ngu"]),
                    line("Chức vụ trước xuất ngũ:", member["chuc_vu_truoc_xuat_ngu"]),
                    line("Đơn vị trước xuất ngũ:", member["don_vi_truoc_xuat_ngu"]),
                    line("Trình độ học vấn:", member["trinh_do_hoc_van"]),
                    line("Trình độ chuyên môn:", member["trinh_do_chuyen_mon"]),
                    line("Ngày vào Đảng:", member["ngay_vao_dang"]),
                    line("Trình độ LLCT:", member["trinh_do_llct"]),
                    line("Chế độ chính sách:", member["che_do_chinh_sach"]),
                    line("Tham gia kháng chiến:", member["tham_gia_khang_chien"]),
                    line("Khen thưởng:", member["khen_thuong"]),
                    line("Ghi chú:", member["ghi_chu"]),
                    line("BHYT:", member["bhyt"]),
                    line("KNC:", member["knc"]),
                    line("MSH:", member["msh"]),
                    line("Quỹ đồng đội:", member["quy_dong_doi"]),
                  ],
                ),
              )
            ],
          ),

          pw.SizedBox(height: 10),

          // ===== FOOTER =====
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Column(
                children: [
                  pw.Text("TM. HỘI CCB XÃ",
                      style: pw.TextStyle(font: ttfBold)),
                  pw.Text("CHỦ TỊCH",
                      style: pw.TextStyle(font: ttfBold)),
                  pw.SizedBox(height: 0),
                  pw.Text("(Ký, ghi rõ họ tên)",
                      style: pw.TextStyle(font: ttf)),
                ],
              )
            ],
          )
        ];
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
                  label: const Text("Xem & Sửa"),
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