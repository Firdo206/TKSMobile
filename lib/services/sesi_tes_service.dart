import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_service.dart';
import 'token_service.dart';

class SesiTesService {
  Future<Map<String, String>> _authHeaders() async {
    final token = await TokenService().getToken();
    return {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
      "ngrok-skip-browser-warning": "true",
    };
  }

  Future<Map<String, dynamic>> getSesiTesList() async {
    try {
      final response = await http.get(
        Uri.parse(ApiService.sesiTesList),
        headers: await _authHeaders(),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "data": data["data"]};
      }

      return {"success": false, "message": data["message"] ?? "Gagal memuat sesi tes"};
    } catch (e) {
      return {"success": false, "message": "Tidak dapat terhubung ke server. Cek koneksi Anda."};
    }
  }

  Future<Map<String, dynamic>> getSesiTesDetail(int id) async {
    try {
      final response = await http.get(
        Uri.parse(ApiService.sesiTesDetail(id)),
        headers: await _authHeaders(),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "data": data["data"]};
      }

      return {"success": false, "message": data["message"] ?? "Gagal memuat detail sesi"};
    } catch (e) {
      return {"success": false, "message": "Tidak dapat terhubung ke server. Cek koneksi Anda."};
    }
  }

  Future<Map<String, dynamic>> submitHasil(int sesiTesId, double nilaiHasil) async {
    try {
      final response = await http.post(
        Uri.parse(ApiService.sesiTesSubmitHasil(sesiTesId)),
        headers: await _authHeaders(),
        body: jsonEncode({"nilai_hasil": nilaiHasil}),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {"success": true, "data": data["data"]};
      }

      return {"success": false, "message": data["message"] ?? "Gagal mengirim hasil"};
    } catch (e) {
      return {"success": false, "message": "Tidak dapat terhubung ke server. Cek koneksi Anda."};
    }
  }

  Future<Map<String, dynamic>> getRiwayatTes() async {
    try {
      final response = await http.get(
        Uri.parse(ApiService.riwayatTes),
        headers: await _authHeaders(),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "data": data["data"]};
      }

      return {"success": false, "message": data["message"] ?? "Gagal memuat riwayat tes"};
    } catch (e) {
      return {"success": false, "message": "Tidak dapat terhubung ke server. Cek koneksi Anda."};
    }
  }
}