import 'package:flutter/material.dart';

import '../../models/hasil_tes_model.dart';
import '../../services/sesi_tes_service.dart';

class RiwayatTesPage extends StatefulWidget {
  const RiwayatTesPage({super.key});

  @override
  State<RiwayatTesPage> createState() => _RiwayatTesPageState();
}

class _RiwayatTesPageState extends State<RiwayatTesPage> {
  static const Color primaryColor = Color(0xFF10B981);
  static const Color darkBg = Color(0xFF090D16);
  static const Color darkCard = Color(0xFF0D1322);

  final SesiTesService _sesiTesService = SesiTesService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  List<HasilTesModel> _riwayat = [];
  String _selectedGrade = 'Semua';

  static const List<String> _gradeOptions = ['Semua', 'A', 'AB', 'B', 'BC', 'C', 'D'];

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRiwayat() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _sesiTesService.getRiwayatTes();

    if (!mounted) return;

    if (result['success'] == true) {
      final List data = result['data'] ?? [];
      setState(() {
        _riwayat = data.map((e) => HasilTesModel.fromJson(e)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'] ?? 'Gagal memuat riwayat tes';
        _isLoading = false;
      });
    }
  }

  List<HasilTesModel> get _filteredRiwayat {
    final keyword = _searchController.text.trim().toLowerCase();
    return _riwayat.where((item) {
      final matchSearch =
          keyword.isEmpty || item.namaOlahraga.toLowerCase().contains(keyword);
      final matchGrade = _selectedGrade == 'Semua' ||
          (item.grade?.toUpperCase() == _selectedGrade);
      return matchSearch && matchGrade;
    }).toList();
  }

  String _formatTanggal(String tanggal) {
    try {
      final date = DateTime.parse(tanggal);
      const bulan = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${date.day} ${bulan[date.month - 1]} ${date.year}';
    } catch (_) {
      return tanggal;
    }
  }

  String _formatNilai(double nilai, String tipe) {
    final isDetik = tipe.toLowerCase() == 'waktu' || tipe.toLowerCase() == 'detik';
    if (isDetik) {
      final menit = nilai ~/ 60;
      final detik = (nilai % 60).toStringAsFixed(0);
      if (menit > 0) {
        return '$menit menit $detik detik';
      }
      return '$detik detik';
    }
    final isBulat = nilai == nilai.roundToDouble();
    return isBulat ? nilai.toStringAsFixed(0) : nilai.toStringAsFixed(2);
  }

  Color _gradeColor(String? grade) {
    switch (grade?.toUpperCase()) {
      case 'A':
        return const Color(0xFF34D399);
      case 'AB':
        return const Color(0xFFA3E635);
      case 'B':
        return const Color(0xFFFBBF24);
      case 'BC':
        return const Color(0xFFFB923C);
      case 'C':
        return const Color(0xFFF87171);
      case 'D':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Riwayat Tes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Decorative glow, senada dengan dashboard & halaman login
          Positioned(
            top: -100,
            right: -80,
            child: _GlowBlob(color: primaryColor.withOpacity(0.15), size: 280),
          ),
          Positioned(
            bottom: -120,
            left: -80,
            child: _GlowBlob(
              color: const Color(0xFF3B82F6).withOpacity(0.12),
              size: 300,
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              color: primaryColor,
              backgroundColor: darkCard,
              onRefresh: _loadRiwayat,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 120, 20, 24),
        children: [
          Icon(Icons.error_outline_rounded,
              size: 48, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.55)),
          ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
              onPressed: _loadRiwayat,
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: BorderSide(color: primaryColor.withOpacity(0.4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ),
        ],
      );
    }

    if (_riwayat.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 120, 20, 24),
        children: [
          Icon(Icons.history_rounded,
              size: 48, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 12),
          Text(
            'Belum ada riwayat tes',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.55)),
          ),
        ],
      );
    }

    final filtered = _filteredRiwayat;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SearchField(controller: _searchController, darkCard: darkCard),
                const SizedBox(height: 12),
                _GradeFilterRow(
                  options: _gradeOptions,
                  selected: _selectedGrade,
                  accentColor: primaryColor,
                  darkCard: darkCard,
                  onSelected: (grade) => setState(() => _selectedGrade = grade),
                ),
                const SizedBox(height: 8),
                Text(
                  '${filtered.length} dari ${_riwayat.length} riwayat',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        if (filtered.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded,
                      size: 40, color: Colors.white.withOpacity(0.25)),
                  const SizedBox(height: 10),
                  Text(
                    'Tidak ada riwayat yang cocok',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = filtered[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RiwayatCard(
                      title: item.namaOlahraga,
                      subtitle: _formatTanggal(item.tanggal),
                      trailing: _formatNilai(item.nilaiHasil, item.tipe),
                      grade: item.grade ?? '-',
                      gradeColor: _gradeColor(item.grade),
                      darkCard: darkCard,
                    ),
                  );
                },
                childCount: filtered.length,
              ),
            ),
          ),
      ],
    );
  }
}

/// Kolom pencarian nama olahraga, senada dengan gaya kartu dashboard.
class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final Color darkCard;

  const _SearchField({required this.controller, required this.darkCard});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Cari nama olahraga...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.4)),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.4)),
                  onPressed: controller.clear,
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

/// Baris chip untuk filter berdasarkan grade nilai.
class _GradeFilterRow extends StatelessWidget {
  final List<String> options;
  final String selected;
  final Color accentColor;
  final Color darkCard;
  final ValueChanged<String> onSelected;

  const _GradeFilterRow({
    required this.options,
    required this.selected,
    required this.accentColor,
    required this.darkCard,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final grade = options[index];
          final isSelected = grade == selected;
          return GestureDetector(
            onTap: () => onSelected(grade),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? accentColor.withOpacity(0.15) : darkCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? accentColor.withOpacity(0.5)
                      : Colors.white.withOpacity(0.08),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                grade == 'Semua' ? 'Semua' : 'Grade $grade',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? accentColor : Colors.white.withOpacity(0.6),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Kartu riwayat tes, mengikuti gaya visual _MenuCard di dashboard.
class _RiwayatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailing;
  final String grade;
  final Color gradeColor;
  final Color darkCard;

  const _RiwayatCard({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.grade,
    required this.gradeColor,
    required this.darkCard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: gradeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: gradeColor.withOpacity(0.3)),
            ),
            alignment: Alignment.center,
            child: Text(
              grade,
              style: TextStyle(
                color: gradeColor,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.45),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            trailing,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
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
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0)],
        ),
      ),
    );
  }
}