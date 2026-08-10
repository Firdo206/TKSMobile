import 'package:http/http.dart' as http;

import 'api_service.dart';
import 'token_service.dart';

class LogoutService {
  Future<void> logout() async {
    final token = await TokenService().getToken();

    await http.post(
      Uri.parse(ApiService.siswaLogout),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    await TokenService().removeToken();
  }
}