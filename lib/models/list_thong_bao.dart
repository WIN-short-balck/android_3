class ThongBao {
  final int? id;
  final String nguoiDang;
  final String title;
  final String noiDung;

  ThongBao({
    this.id,

    required this.title,
    required this.noiDung,
    required this.nguoiDang,
  });

  factory ThongBao.fromMap(Map<String, dynamic> map) {
    return ThongBao(
      id: map['id'],
      title: map['title'],
      noiDung: map['noiDung'],
      nguoiDang: map['nguoiDang'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'noiDung': noiDung,
      'nguoiDang': nguoiDang,
    };
  }
}
