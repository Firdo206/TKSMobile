import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_service.dart';
import 'token_service.dart';

class ProfileSiswaService {
  Future<Map<String, dynamic>> getProfile() async {
    final token = await TokenService().getToken();

    final response = await http.get(
      Uri.parse(ApiService.siswaMe),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return {"success": true, "data": jsonDecode(response.body)};
    }

    final data = jsonDecode(response.body);
    return {"success": false, "message": data["message"] ?? "Gagal memuat profil"};
  }
}