import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../services/api_service.dart';
import '../../services/token_service.dart';
import '../../services/logout_service.dart';
import '../auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color primaryColor = Color(0xFF10B981);
  static const Color accentBlue = Color(0xFF60A5FA);
  static const Color darkBg = Color(0xFF090D16);
  static const Color darkCard = Color(0xFF0D1322);

  bool _loading = true;
  bool _loggingOut = false;
  String? _error;

  String _nama = '-';
  String _nomorAbsen = '-';
  String _jenisKelamin = '-';
  String _kelas = '-';
  String _username = '-';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final token = await TokenService().getToken();

      final response = await http.get(
        Uri.parse(ApiService.siswaMe),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _nama = data['nama'] ?? '-';
          _nomorAbsen = data['nomor_absen']?.toString() ?? '-';
          _jenisKelamin = data['jenis_kelamin'] ?? '-';
          _kelas = data['kelas'] ?? '-';
          _username = data['username'] ?? '-';
          _loading = false;
        });
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _error = data['message'] ?? 'Gagal memuat profil';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat profil: $e';
        _loading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar', style: TextStyle(color: Colors.white)),
        content: Text(
          'Apakah kamu yakin ingin keluar?',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: TextStyle(color: Colors.white.withOpacity(0.6))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _loggingOut = true);

    try {
      await LogoutService().logout();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loggingOut = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal logout: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -80,
            child: _GlowBlob(color: primaryColor.withOpacity(0.15), size: 280),
          ),
          Positioned(
            bottom: -120,
            left: -80,
            child: _GlowBlob(color: accentBlue.withOpacity(0.12), size: 300),
          ),
          SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: primaryColor))
                : _error != null
                    ? _buildErrorState()
                    : RefreshIndicator(
                        color: primaryColor,
                        backgroundColor: darkCard,
                        onRefresh: _loadProfile,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                          children: [
                            const Text(
                              'Profil Saya',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildAvatarCard(),
                            const SizedBox(height: 20),
                            _buildInfoCard(),
                            const SizedBox(height: 20),
                            _buildLogoutButton(),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarCard() {
    final inisial = _nama.isNotEmpty && _nama != '-' ? _nama[0].toUpperCase() : '?';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor.withOpacity(0.3), width: 2),
            ),
            child: Text(
              inisial,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: primaryColor),
            ),
          ),
          const SizedBox(height: 14),
          Text(_nama, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text('@$_username', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.4))),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          _buildInfoTile(icon: Icons.badge_outlined, iconColor: primaryColor, label: 'Nomor Absen', value: _nomorAbsen),
          _divider(),
          _buildInfoTile(icon: Icons.class_outlined, iconColor: accentBlue, label: 'Kelas', value: _kelas),
          _divider(),
          _buildInfoTile(icon: Icons.wc_rounded, iconColor: const Color(0xFFF472B6), label: 'Jenis Kelamin', value: _jenisKelamin),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.white.withOpacity(0.06));

  Widget _buildInfoTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.45))),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _loggingOut ? null : _handleLogout,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFEF4444),
          side: const BorderSide(color: Color(0xFFEF4444)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: _loggingOut
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFEF4444)),
              )
            : const Icon(Icons.logout_rounded, size: 18),
        label: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(_error ?? 'Terjadi kesalahan', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _loadProfile,
              style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: BorderSide(color: Colors.white.withOpacity(0.3))),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color, color.withOpacity(0)])),
    );
  }
}