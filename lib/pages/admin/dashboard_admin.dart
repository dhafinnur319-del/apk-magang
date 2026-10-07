import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../login_page.dart';
import 'data_peserta_page.dart';
import 'data_absensi_page.dart';
import 'rekap_page.dart';
import 'izin_admin_page.dart';

class DashboardAdmin extends StatelessWidget {
  const DashboardAdmin({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    if (!context.mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _logout(context)),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: [
          _menu(context, Icons.people, 'Data Peserta',
              const DataPesertaPage()),
          _menu(context, Icons.list_alt, 'Data Absensi',
              const DataAbsensiPage()),
          _menu(context, Icons.report, 'Izin',
              const IzinAdminPage()),
          _menu(context, Icons.bar_chart, 'Rekap Absensi', 
              const RekapPage()),
        ],
      ),
    );
  }

  Widget _menu(
      BuildContext context, IconData icon, String label, Widget page) {
    return InkWell(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => page)),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.blue),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}