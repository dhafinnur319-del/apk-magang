import 'package:flutter/material.dart';
import '../../models/absensi_model.dart';
import '../../services/absensi_service.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Absensi')),
      body: StreamBuilder<List<AbsensiModel>>(
        stream: AbsensiService().riwayatUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(child: Text('Belum ada riwayat absensi'));
          }
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, i) {
              final a = data[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(a.tanggal),
                  subtitle: Text('Masuk: ${a.jamMasuk ?? '-'}  |  Pulang: ${a.jamPulang ?? '-'}'),
                  trailing: Chip(
                    label: Text(a.status),
                    backgroundColor: a.status == 'Hadir'
                        ? Colors.green.shade100
                        : a.status == 'Terlambat'
                            ? Colors.orange.shade100
                            : Colors.grey.shade200,
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