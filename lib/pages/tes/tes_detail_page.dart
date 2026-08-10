import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../services/sesi_tes_service.dart';

class TesDetailPage extends StatefulWidget {
  final int sesiTesId;

  const TesDetailPage({super.key, required this.sesiTesId});

  @override
  State<TesDetailPage> createState() => _TesDetailPageState();
}

class _TesDetailPageState extends State<TesDetailPage> {
  static const Color primaryColor = Color(0xFF10B981);
  static const Color accentBlue = Color(0xFF60A5FA);
  static const Color darkBg = Color(0xFF090D16);
  static const Color darkCard = Color(0xFF0D1322);

  final SesiTesService _service = SesiTesService();

  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _detail;

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _stopwatchTimer;
  Duration _elapsed = Duration.zero;
  bool _isRunning = false;
  bool _hasStopped = false;

  int _poin = 0;
  Timer? _countdownTimer;
  int _sisaDetik = 0;
  bool _poinTesBerjalan = false;
  bool _autoSubmitting = false;

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  @override
  void dispose() {
    _stopwatchTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _service.getSesiTesDetail(widget.sesiTesId);

    if (result["success"] == true) {
      setState(() {
        _detail = result["data"];
        _sisaDetik = _detail!['durasi_detik'] != null
            ? int.tryParse(_detail!['durasi_detik'].toString()) ?? 0
            : 0;
        _loading = false;
      });
    } else {
      setState(() {
        _error = result["message"];
        _loading = false;
      });
    }
  }

  void _startStopwatch() {
    _stopwatch.start();
    _isRunning = true;
    _stopwatchTimer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      setState(() => _elapsed = _stopwatch.elapsed);
    });
    setState(() {});
  }

  void _stopStopwatch() {
    _stopwatch.stop();
    _stopwatchTimer?.cancel();
    setState(() {
      _isRunning = false;
      _hasStopped = true;
      _elapsed = _stopwatch.elapsed;
    });
  }

  void _resetStopwatch() {
    _stopwatch.reset();
    _stopwatchTimer?.cancel();
    setState(() {
      _isRunning = false;
      _hasStopped = false;
      _elapsed = Duration.zero;
    });
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final millis = (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    return '$minutes:$seconds.$millis';
  }

  String _formatMenitDetik(int totalDetik) {
    final m = totalDetik ~/ 60;
    final s = totalDetik % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _mulaiTesPoin() {
    setState(() => _poinTesBerjalan = true);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_sisaDetik <= 1) {
        timer.cancel();
        setState(() => _sisaDetik = 0);
        _autoSubmitPoin();
      } else {
        setState(() => _sisaDetik--);
      }
    });
  }

  Future<void> _autoSubmitPoin() async {
    setState(() => _autoSubmitting = true);
    final result = await _service.submitHasil(widget.sesiTesId, _poin.toDouble());
    setState(() => _autoSubmitting = false);

    if (!mounted) return;

    if (result["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Waktu habis! Hasil terkirim otomatis. Grade: ${result["data"]["grade"]}')),
      );
      _loadDetail();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result["message"])));
    }
  }

  Future<void> _confirmAndSubmit(double nilaiHasil, String displayValue) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Kirim Hasil?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Hasil: $displayValue\n\nSetelah dikirim, hasil ini tidak bisa diubah lagi.',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: TextStyle(color: Colors.white.withOpacity(0.6))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: darkBg),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _submitting = true);
    final result = await _service.submitHasil(widget.sesiTesId, nilaiHasil);
    setState(() => _submitting = false);

    if (!mounted) return;

    if (result["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hasil terkirim! Grade: ${result["data"]["grade"]}')),
      );
      _loadDetail();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result["message"])));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: darkBg,
        body: const Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: darkBg,
        appBar: AppBar(
          backgroundColor: darkBg,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(child: Text(_error!, style: const TextStyle(color: Colors.white70))),
      );
    }

    final tipe = _detail!['tipe'];
    final status = _detail!['status'];
    final hasilSaya = _detail!['hasil_saya'];
    final namaOlahraga = _detail!['nama_olahraga'];
    final protokolTes = _detail!['protokol_tes'];

    return PopScope(
      canPop: !_poinTesBerjalan,
      child: Scaffold(
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
                    padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
                    child: Row(
                      children: [
                        if (!_poinTesBerjalan)
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                          )
                        else
                          const SizedBox(width: 48),
                        Expanded(
                          child: Text(
                            namaOlahraga,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          if (protokolTes != null)
                            Text(protokolTes, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
                          const SizedBox(height: 12),
                          if (hasilSaya != null)
                            _buildHasilTerkirim(hasilSaya, tipe)
                          else if (status != 'aktif')
                            _buildSesiTidakAktif(status)
                          else if (tipe == 'waktu')
                            _buildStopwatchUI()
                          else
                            _buildPoinUI(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHasilTerkirim(Map<String, dynamic> hasil, String tipe) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: primaryColor.withOpacity(0.3)),
              ),
              child: Icon(Icons.check_rounded, color: primaryColor, size: 44),
            ),
            const SizedBox(height: 20),
            Text('Hasil Sudah Dikirim', style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.6))),
            const SizedBox(height: 10),
            Text(
              tipe == 'waktu'
                  ? _formatDuration(Duration(
                      milliseconds: (double.parse(hasil['nilai_hasil'].toString()) * 1000).round(),
                    ))
                  : double.parse(hasil['nilai_hasil'].toString()).toStringAsFixed(0),
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: primaryColor.withOpacity(0.3)),
              ),
              child: Text(
                'Grade ${hasil['grade']}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              icon: const Icon(Icons.home_rounded, size: 18),
              label: const Text('Kembali ke Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: darkBg,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSesiTidakAktif(String status) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == 'belum_mulai' ? Icons.hourglass_empty_rounded : Icons.event_busy_rounded,
              size: 56,
              color: Colors.white.withOpacity(0.25),
            ),
            const SizedBox(height: 16),
            Text(
              status == 'belum_mulai' ? 'Sesi tes belum dimulai.' : 'Sesi tes sudah berakhir.',
              style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.5)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopwatchUI() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              color: darkCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Text(
              _formatDuration(_elapsed),
              style: const TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 32),
          if (!_isRunning && !_hasStopped)
            ElevatedButton(
              onPressed: _startStopwatch,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: darkBg,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Mulai', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          if (_isRunning)
            ElevatedButton(
              onPressed: _stopStopwatch,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Berhenti', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          if (_hasStopped && !_isRunning) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: _resetStopwatch,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: BorderSide(color: Colors.white.withOpacity(0.2)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Ulangi'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _submitting
                      ? null
                      : () => _confirmAndSubmit(_elapsed.inMilliseconds / 1000, _formatDuration(_elapsed)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: darkBg,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _submitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Text('Kirim Hasil', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPoinUI() {
    if (_autoSubmitting) {
      return const Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: primaryColor),
              SizedBox(height: 16),
              Text('Mengirim hasil...', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_poinTesBerjalan) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: (_sisaDetik <= 10 ? const Color(0xFFEF4444) : Colors.white).withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: (_sisaDetik <= 10 ? const Color(0xFFEF4444) : Colors.white).withOpacity(0.25)),
              ),
              child: Text(
                _formatMenitDetik(_sisaDetik),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: _sisaDetik <= 10 ? const Color(0xFFEF4444) : Colors.white,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          Container(
            width: 160,
            height: 160,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: darkCard,
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor.withOpacity(0.3), width: 2),
            ),
            child: Text(
              '$_poin',
              style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 28),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: (_poinTesBerjalan && _poin > 0) ? () => setState(() => _poin--) : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  disabledForegroundColor: Colors.white.withOpacity(0.2),
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                  padding: const EdgeInsets.all(18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('-1', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _poinTesBerjalan ? () => setState(() => _poin++) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: darkBg,
                  disabledBackgroundColor: primaryColor.withOpacity(0.2),
                  padding: const EdgeInsets.all(26),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text('+1', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 32),

          if (!_poinTesBerjalan)
            ElevatedButton(
              onPressed: _mulaiTesPoin,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: darkBg,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Mulai', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            )
          else
            Text(
              'Tes sedang berjalan, hasil akan otomatis\nterkirim saat waktu habis.',
              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4)),
              textAlign: TextAlign.center,
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
        gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
      ),
    );
  }
}