import 'package:flutter/material.dart';
import '../../models/izin_model.dart';
import '../../services/izin_service.dart';

class IzinAdminPage extends StatelessWidget {
  const IzinAdminPage({super.key});

  Color _warna(String status) {
    if (status == 'Disetujui') return Colors.green.shade100;
    if (status == 'Ditolak') return Colors.red.shade100;
    return Colors.orange.shade100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengajuan Izin')),
      body: StreamBuilder<List<IzinModel>>(
        stream: IzinService().semuaIzin(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          if (data.isEmpty) {
            return const Center(child: Text('Belum ada pengajuan'));
          }
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, i) {
              final izin = data[i];
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ExpansionTile(
                  title: Text('${izin.nama} — ${izin.jenis}'),
                  subtitle: Text('Tanggal: ${izin.tanggal}'),
                  trailing: Chip(
                    label: Text(izin.status),
                    backgroundColor: _warna(izin.status),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Alasan: ${izin.alasan}'),
                          if (izin.keterangan.isNotEmpty)
                            Text('Keterangan: ${izin.keterangan}'),
                          if (izin.lampiran != null) ...[
                            const SizedBox(height: 8),
                            const Text('Lampiran:'),
                            Image.network(
                              izin.lampiran!,
                              height: 150,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () => IzinService()
                                    .updateStatus(izin.id, 'Disetujui'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green),
                                child: const Text('Setujui'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => IzinService()
                                    .updateStatus(izin.id, 'Ditolak'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                child: const Text('Tolak'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}