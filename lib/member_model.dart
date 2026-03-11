class Member {
  int? id;
  String hoTen;
  String namSinh;
  String chiHoi;
  String soDienThoai;

  Member({
    this.id,
    required this.hoTen,
    required this.namSinh,
    required this.chiHoi,
    required this.soDienThoai,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hoTen': hoTen,
      'namSinh': namSinh,
      'chiHoi': chiHoi,
      'soDienThoai': soDienThoai,
    };
  }

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'],
      hoTen: map['hoTen'],
      namSinh: map['namSinh'],
      chiHoi: map['chiHoi'],
      soDienThoai: map['soDienThoai'],
    );
  }
}