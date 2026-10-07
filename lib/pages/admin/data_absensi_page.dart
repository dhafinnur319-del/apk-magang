import 'package:flutter/material.dart';
import '../../models/absensi_model.dart';
import '../../services/absensi_service.dart';

class DataAbsensiPage extends StatelessWidget {
  const DataAbsensiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Absensi')),
      body: StreamBuilder<List<AbsensiModel>>(
        stream: AbsensiService().semuaAbsensi(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          if (data.isEmpty) {
            return const Center(child: Text('Belum ada data absensi'));
          }
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, i) {
              final a = data[i];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(a.nama),
                subtitle: Text(
                    '${a.tanggal}  |  Masuk: ${a.jamMasuk ?? '-'}  |  Pulang: ${a.jamPulang ?? '-'}'),
                trailing: Chip(label: Text(a.status)),
              );
            },
          );
        },
      ),
    );
  }
}