class SiswaProfileModel {
  final int id;
  final String nama;
  final String nomorAbsen;
  final String jenisKelamin;
  final String? kelas;
  final String username;

  SiswaProfileModel({
    required this.id,
    required this.nama,
    required this.nomorAbsen,
    required this.jenisKelamin,
    this.kelas,
    required this.username,
  });

  factory SiswaProfileModel.fromJson(Map<String, dynamic> json) {
    return SiswaProfileModel(
      id: json['id'],
      nama: json['nama'] ?? '-',
      nomorAbsen: json['nomor_absen']?.toString() ?? '-',
      jenisKelamin: json['jenis_kelamin'] ?? '-',
      kelas: json['kelas'],
      username: json['username'] ?? '-',
    );
  }
}