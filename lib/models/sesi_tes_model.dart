class SesiTesModel {
  final int id;
  final String namaOlahraga;
  final String tipe;
  final String? protokolTes;
  final int? durasiDetik;
  final String tanggal;
  final String waktuMulai;
  final String waktuBerakhir;
  final String status;
  final bool sudahSubmit;

  SesiTesModel({
    required this.id,
    required this.namaOlahraga,
    required this.tipe,
    this.protokolTes,
    this.durasiDetik,
    required this.tanggal,
    required this.waktuMulai,
    required this.waktuBerakhir,
    required this.status,
    required this.sudahSubmit,
  });

  factory SesiTesModel.fromJson(Map<String, dynamic> json) {
    return SesiTesModel(
      id: json['id'],
      namaOlahraga: json['nama_olahraga'] ?? '-',
      tipe: json['tipe'] ?? 'poin',
      protokolTes: json['protokol_tes'],
      durasiDetik: json['durasi_detik'] != null ? int.tryParse(json['durasi_detik'].toString()) : null,
      tanggal: json['tanggal'] ?? '',
      waktuMulai: json['waktu_mulai'] ?? '',
      waktuBerakhir: json['waktu_berakhir'] ?? '',
      status: json['status'] ?? 'belum_mulai',
      sudahSubmit: json['sudah_submit'] ?? false,
    );
  }
}