class Member {
  int? id;
  String hoTen;
  String namSinh;
  String diaChi;
  String chiHoi;
  String chucVu;
  String dienThoai;
  String? image;

  Member({
    this.id,
    required this.hoTen,
    required this.namSinh,
    required this.diaChi,
    required this.chiHoi,
    required this.chucVu,
    required this.dienThoai,
    this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hoTen': hoTen,
      'namSinh': namSinh,
      'diaChi': diaChi,
      'chiHoi': chiHoi,
      'chucVu': chucVu,
      'dienThoai': dienThoai,
      'image': image
    };
  }
}