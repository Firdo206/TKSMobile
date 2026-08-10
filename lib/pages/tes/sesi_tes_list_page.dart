import 'package:flutter/material.dart';

import '../../models/sesi_tes_model.dart';
import '../../services/sesi_tes_service.dart';
import 'tes_detail_page.dart';

class SesiTesListPage extends StatefulWidget {
  const SesiTesListPage({super.key});

  @override
  State<SesiTesListPage> createState() => _SesiTesListPageState();
}

class _SesiTesListPageState extends State<SesiTesListPage> {
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
        return Colors.green;
      case 'selesai':
        return Colors.grey;
      default:
        return Colors.orange;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sesi Tes')),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(child: Text(_error!))
            : _sesiList.isEmpty
            ? const Center(child: Text('Belum ada sesi tes untuk kelasmu.'))
            : ListView.builder(
                itemCount: _sesiList.length,
                itemBuilder: (context, index) {
                  final sesi = _sesiList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(sesi.namaOlahraga),
                      subtitle: Text(
                        '${sesi.tanggal}  •  ${sesi.waktuMulai} - ${sesi.waktuBerakhir}'
                        '${sesi.protokolTes != null ? '\n${sesi.protokolTes}' : ''}',
                      ),
                      isThreeLine: sesi.protokolTes != null,
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(
                                sesi.status,
                              ).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _statusLabel(sesi.status),
                              style: TextStyle(
                                color: _statusColor(sesi.status),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (sesi.sudahSubmit)
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                'Sudah dikirim',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                        ],
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TesDetailPage(sesiTesId: sesi.id),
                          ),
                        );
                        _loadData(); // refresh list pas balik dari detail
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
