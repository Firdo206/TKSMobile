class HasilTesModel {
  final int sesiTesId;
  final String namaOlahraga;
  final String tipe;
  final String tanggal;
  final double nilaiHasil;
  final String? grade;

  HasilTesModel({
    required this.sesiTesId,
    required this.namaOlahraga,
    required this.tipe,
    required this.tanggal,
    required this.nilaiHasil,
    this.grade,
  });

  factory HasilTesModel.fromJson(Map<String, dynamic> json) {
    return HasilTesModel(
      sesiTesId: json['sesi_tes_id'],
      namaOlahraga: json['nama_olahraga'] ?? '-',
      tipe: json['tipe'] ?? 'poin',
      tanggal: json['tanggal'] ?? '',
      nilaiHasil: double.tryParse(json['nilai_hasil'].toString()) ?? 0,
      grade: json['grade'],
    );
  }
}