import 'package:flutter/material.dart';

import '../dashboard/dashboard_page.dart';
import 'login_page.dart';
import '../../services/token_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  static const Color darkBg = Color(0xFF090D16);
  static const Color primaryColor = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: TokenService().getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: darkBg,
            body: Center(
              child: CircularProgressIndicator(color: primaryColor),
            ),
          );
        }

        final token = snapshot.data;
        if (token != null && token.isNotEmpty) {
          return const DashboardPage();
        }

        return const LoginPage();
      },
    );
  }
}