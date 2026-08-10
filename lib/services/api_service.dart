class ApiService {
 static const String baseUrl = "https://iqipjok.my.id/api";
  // URL
  static const String siswaLogin = "$baseUrl/siswa/login";
  static const String siswaLogout = "$baseUrl/siswa/logout";
  static const String siswaMe = "$baseUrl/siswa/me";
  static String get sesiTesList => "$baseUrl/siswa/sesi-tes";
  static String sesiTesDetail(int id) => "$baseUrl/siswa/sesi-tes/$id";
  static String sesiTesSubmitHasil(int id) => "$baseUrl/siswa/sesi-tes/$id/hasil";
  static String get riwayatTes => "$baseUrl/siswa/riwayat-tes";
}