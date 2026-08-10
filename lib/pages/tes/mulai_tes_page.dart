import 'package:flutter/material.dart';

import '../../models/sesi_tes_model.dart';
import '../../services/sesi_tes_service.dart';
import 'tes_detail_page.dart';

class MulaiTesPage extends StatefulWidget {
  const MulaiTesPage({super.key});

  @override
  State<MulaiTesPage> createState() => _MulaiTesPageState();
}

class _MulaiTesPageState extends State<MulaiTesPage> {
  static const Color primaryColor = Color(0xFF10B981);
  static const Color accentBlue = Color(0xFF60A5FA);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color darkBg = Color(0xFF090D16);
  static const Color darkCard = Color(0xFF0D1322);

  final SesiTesService _service = SesiTesService();
  List<SesiTesModel> _sesiList = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _service.getSesiTesList();

    if (result["success"] == true) {
      setState(() {
        _sesiList = (result["data"] as List)
            .map((e) => SesiTesModel.fromJson(e))
            .toList();
        _loading = false;
      });
    } else {
      setState(() {
        _error = result["message"];
        _loading = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'aktif':
        return primaryColor;
      case 'selesai':
        return Colors.white.withOpacity(0.35);
      default:
        return accentAmber;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'aktif':
        return 'Aktif';
      case 'selesai':
        return 'Selesai';
      default:
        return 'Belum Mulai';
    }
  }

  IconData _tipeIcon(String tipe) {
    return tipe == 'waktu' ? Icons.timer_rounded : Icons.fitness_center_rounded;
  }

  Color _tipeColor(String tipe) {
    return tipe == 'waktu' ? accentBlue : primaryColor;
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Mulai Tes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: primaryColor,
                    backgroundColor: darkCard,
                    onRefresh: _loadData,
                    child: _loading
                        ? const Center(child: CircularProgressIndicator(color: primaryColor))
                        : _error != null
                            ? _buildErrorState()
                            : _sesiList.isEmpty
                                ? _buildEmptyState()
                                : ListView.builder(
                                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                                    itemCount: _sesiList.length,
                                    itemBuilder: (context, index) {
                                      final sesi = _sesiList[index];
                                      return _SesiTesCard(
                                        sesi: sesi,
                                        tipeIcon: _tipeIcon(sesi.tipe),
                                        tipeColor: _tipeColor(sesi.tipe),
                                        statusColor: _statusColor(sesi.status),
                                        statusLabel: _statusLabel(sesi.status),
                                        darkCard: darkCard,
                                        primaryColor: primaryColor,
                                        onTap: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => TesDetailPage(sesiTesId: sesi.id),
                                            ),
                                          );
                                          _loadData();
                                        },
                                      );
                                    },
                                  ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryColor.withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.event_note_rounded, size: 38, color: primaryColor),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Belum Ada Sesi Tes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sesi tes untuk kelasmu akan muncul di sini\nsetelah guru membuatnya.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.45), height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text(
                    _error ?? 'Terjadi kesalahan',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _loadData,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SesiTesCard extends StatelessWidget {
  final SesiTesModel sesi;
  final IconData tipeIcon;
  final Color tipeColor;
  final Color statusColor;
  final String statusLabel;
  final Color darkCard;
  final Color primaryColor;
  final VoidCallback onTap;

  const _SesiTesCard({
    required this.sesi,
    required this.tipeIcon,
    required this.tipeColor,
    required this.statusColor,
    required this.statusLabel,
    required this.darkCard,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: darkCard,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          splashColor: primaryColor.withOpacity(0.1),
          highlightColor: primaryColor.withOpacity(0.05),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: tipeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: tipeColor.withOpacity(0.25)),
                  ),
                  child: Icon(tipeIcon, color: tipeColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              sesi.namaOlahraga,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: statusColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 12, color: Colors.white.withOpacity(0.35)),
                          const SizedBox(width: 4),
                          Text(sesi.tanggal, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5))),
                          const SizedBox(width: 10),
                          Icon(Icons.schedule_rounded, size: 12, color: Colors.white.withOpacity(0.35)),
                          const SizedBox(width: 4),
                          Text(
                            '${sesi.waktuMulai} - ${sesi.waktuBerakhir}',
                            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)),
                          ),
                        ],
                      ),
                      if (sesi.protokolTes != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          sesi.protokolTes!,
                          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.35), fontStyle: FontStyle.italic),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (sesi.sudahSubmit) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.check_circle_rounded, size: 14, color: primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              'Hasil sudah dikirim',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: primaryColor),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.25)),
              ],
            ),
          ),
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
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
      ),
    );
  }
}