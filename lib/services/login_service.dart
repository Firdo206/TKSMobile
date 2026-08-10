import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_service.dart';
import 'token_service.dart';

class LoginService {
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiService.siswaLogin),
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "username": username,
              "password": password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        // Response bukan JSON valid (misal server error HTML, atau 502/504 dari hosting)
        return {
          "success": false,
          "message": "Server tidak merespons dengan benar (kode ${response.statusCode}). Coba lagi nanti.",
        };
      }

      if (response.statusCode == 200) {
        await TokenService().saveToken(data["token"]);

        return {
          "success": true,
          "message": data["message"],
          "siswa": data["siswa"],
        };
      }

      return {
        "success": false,
        "message": data["message"] ?? "Username atau password salah",
      };
    } on SocketException {
      return {
        "success": false,
        "message": "Tidak ada koneksi internet. Periksa jaringan kamu dan coba lagi.",
      };
    } on HttpException {
      return {
        "success": false,
        "message": "Gagal terhubung ke server. Coba lagi nanti.",
      };
    } on FormatException {
      return {
        "success": false,
        "message": "Respons server tidak valid. Coba lagi nanti.",
      };
    } catch (e) {
      // Termasuk TimeoutException dari .timeout(), dan error tak terduga lainnya
      final isTimeout = e.toString().toLowerCase().contains('timeout');
      return {
        "success": false,
        "message": isTimeout
            ? "Koneksi ke server terlalu lama. Periksa internet kamu dan coba lagi."
            : "Terjadi kesalahan, coba lagi. (${e.runtimeType})",
      };
    }
  }
}