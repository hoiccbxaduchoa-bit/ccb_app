import 'package:flutter/material.dart';
import '../services/db_service.dart';

class AddMemberScreen extends StatefulWidget {

  final Map<String, dynamic>? member;

  const AddMemberScreen({super.key, this.member});

  @override
  State<AddMemberScreen> createState() =>
      _AddMemberScreenState();
}

class _AddMemberScreenState
    extends State<AddMemberScreen> {

  /// ================= CONTROLLERS =================
  final Map<String, TextEditingController> c = {

    "ho_ten": TextEditingController(),
    "so_cccd": TextEditingController(),
    "nam_sinh": TextEditingController(),
    "so_the_hoi_vien": TextEditingController(),

    "chi_hoi": TextEditingController(),
    "so_dien_thoai": TextEditingController(),

    "ngay_vao_hoi": TextEditingController(),
    "chuc_vu_hoi": TextEditingController(),

    "ngay_nhap_ngu": TextEditingController(),
    "ngay_xuat_ngu": TextEditingController(),
    "ngay_vao_dang": TextEditingController(),

    "cap_bac_truoc_xuat_ngu":
        TextEditingController(),

    "chuc_vu_truoc_xuat_ngu":
        TextEditingController(),

    "don_vi_truoc_xuat_ngu":
        TextEditingController(),

    "dan_toc": TextEditingController(),

    "trinh_do_hoc_van":
        TextEditingController(),

    "trinh_do_chuyen_mon":
        TextEditingController(),

    "trinh_do_llct":
        TextEditingController(),

    "che_do_chinh_sach":
        TextEditingController(),

    "khen_thuong":
        TextEditingController(),

    "tham_gia_khang_chien":
        TextEditingController(),

    "ghi_chu": TextEditingController(),
  };

  bool bhyt = false;
  bool knc = false;
  bool msh = false;

  final quy = TextEditingController();

  /// ================= INIT =================
  @override
  void initState() {
    super.initState();

    if (widget.member != null) {
      loadMember();
    }
  }

  /// ================= LOAD MEMBER =================
  void loadMember() {

    final m = widget.member!;

    for (var key in c.keys) {
      c[key]!.text =
          (m[key] ?? "").toString();
    }

    bhyt = m["bhyt"] == "Có";
    knc = m["knc"] == "Có";
    msh = m["msh"] == "Có";

    quy.text =
        (m["quy_dong_doi"] ?? 0).toString();
  }

  /// ================= SAVE =================
  Future save() async {

    Map<String, dynamic> data = {};

    for (var key in c.keys) {
      data[key] = c[key]!.text;
    }

    data["bhyt"] = bhyt ? "Có" : "Không";
    data["knc"] = knc ? "Có" : "Không";
    data["msh"] = msh ? "Có" : "Không";

    data["quy_dong_doi"] =
        int.tryParse(quy.text) ?? 0;

    if (widget.member == null) {

      /// INSERT
      await DBService.insert(data);

    } else {

      /// UPDATE
      int id = widget.member!["id"];
      await DBService.update(
        id,
        data,
      );
    }

    Navigator.pop(context, true);
  }

  /// ================= FIELD =================
  Widget field(String label, String key) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),

      child: TextField(

        controller: c[key],

        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text(
          widget.member == null
              ? "Thêm hội viên"
              : "Sửa hội viên",
        ),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(15),

        child: Column(

          children: [

            field("Họ tên", "ho_ten"),
            field("Số CCCD", "so_cccd"),
            field("Năm sinh", "nam_sinh"),
            field("Số thẻ hội viên",
                "so_the_hoi_vien"),

            field("Chi hội", "chi_hoi"),
            field("SĐT", "so_dien_thoai"),

            field("Ngày vào Hội",
                "ngay_vao_hoi"),

            field("Chức vụ Hội",
                "chuc_vu_hoi"),

            field("Ngày nhập ngũ",
                "ngay_nhap_ngu"),

            field("Ngày xuất ngũ",
                "ngay_xuat_ngu"),

            field("Ngày vào Đảng",
                "ngay_vao_dang"),

            field("Cấp bậc",
                "cap_bac_truoc_xuat_ngu"),

            field("Chức vụ QĐ",
                "chuc_vu_truoc_xuat_ngu"),

            field("Đơn vị",
                "don_vi_truoc_xuat_ngu"),

            field("Dân tộc", "dan_toc"),

            field("Học vấn",
                "trinh_do_hoc_van"),

            field("Chuyên môn",
                "trinh_do_chuyen_mon"),

            field("LLCT",
                "trinh_do_llct"),

            field("Chế độ CS",
                "che_do_chinh_sach"),

            field("Khen thưởng",
                "khen_thuong"),

            field("Tham gia KC",
                "tham_gia_khang_chien"),

            field("Ghi chú", "ghi_chu"),

            const SizedBox(height: 10),

            TextField(

              controller: quy,

              keyboardType:
                  TextInputType.number,

              decoration: const InputDecoration(
                labelText: "Quỹ đồng đội",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            CheckboxListTile(
              value: bhyt,
              title: const Text("Có BHYT"),
              onChanged: (v) =>
                  setState(() => bhyt = v!),
            ),

            CheckboxListTile(
              value: knc,
              title:
                  const Text("Kỷ niệm chương"),
              onChanged: (v) =>
                  setState(() => knc = v!),
            ),

            CheckboxListTile(
              value: msh,
              title:
                  const Text("Miễn sinh hoạt"),
              onChanged: (v) =>
                  setState(() => msh = v!),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: save,
              child: const Text("LƯU HỘI VIÊN"),
            )
          ],
        ),
      ),
    );
  }
}