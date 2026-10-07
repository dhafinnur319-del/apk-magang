import 'package:flutter/material.dart';
import '../../models/izin_model.dart';
import '../../services/izin_service.dart';

class RiwayatIzinPage extends StatelessWidget {
  const RiwayatIzinPage({super.key});

  Color _warna(String status) {
    if (status == 'Disetujui') return Colors.green.shade100;
    if (status == 'Ditolak') return Colors.red.shade100;
    return Colors.orange.shade100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Izin')),
      body: StreamBuilder<List<IzinModel>>(
        stream: IzinService().riwayatIzinUser(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          if (data.isEmpty) {
            return const Center(child: Text('Belum ada pengajuan izin'));
          }
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, i) {
              final izin = data[i];
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text('${izin.jenis}  •  ${izin.tanggal}'),
                  subtitle: Text(izin.alasan),
                  trailing: Chip(
                    label: Text(izin.status),
                    backgroundColor: _warna(izin.status),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}