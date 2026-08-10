import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_service.dart';
import 'token_service.dart';

class UserService {
  Future<Map<String, dynamic>?> getCurrentSiswa() async {
    final token = await TokenService().getToken();

    final response = await http.get(
      Uri.parse(ApiService.siswaMe),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return null;
  }
}