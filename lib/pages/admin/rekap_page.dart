import 'package:flutter/material.dart';
import '../../models/absensi_model.dart';
import '../../services/absensi_service.dart';

class RekapPage extends StatelessWidget {
  const RekapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rekap Absensi')),
      body: StreamBuilder<List<AbsensiModel>>(
        stream: AbsensiService().semuaAbsensi(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          // Group by nama
          final Map<String, Map<String, int>> rekap = {};
          for (final a in data) {
            rekap.putIfAbsent(a.nama, () => {
              'Hadir': 0, 'Terlambat': 0, 'Izin': 0, 'Sakit': 0, 'Alfa': 0,
            });
            rekap[a.nama]![a.status] = (rekap[a.nama]![a.status] ?? 0) + 1;
          }

          if (rekap.isEmpty) {
            return const Center(child: Text('Belum ada data'));
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: rekap.entries.map((e) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.key,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Hadir: ${e.value['Hadir']}  |  '
                          'Terlambat: ${e.value['Terlambat']}  |  '
                          'Izin: ${e.value['Izin']}  |  '
                          'Sakit: ${e.value['Sakit']}  |  '
                          'Alfa: ${e.value['Alfa']}'),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}