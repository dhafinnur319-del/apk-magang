import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../models/absensi_model.dart';
import '../../services/auth_service.dart';
import '../../services/absensi_service.dart';
import '../login_page.dart';
import 'riwayat_page.dart';

class DashboardPeserta extends StatefulWidget {
  const DashboardPeserta({super.key});

  @override
  State<DashboardPeserta> createState() => _DashboardPesertaState();
}

class _DashboardPesertaState extends State<DashboardPeserta> {
  UserModel? _user;
  AbsensiModel? _absen;
  final _absensiService = AbsensiService();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await AuthService().getUserData();
    final absen = await _absensiService.getAbsenHariIni();
    setState(() {
      _user = user;
      _absen = absen;
      _loading = false;
    });
  }

  Future<void> _absenMasuk() async {
    final result = await _absensiService.absenMasuk(_user!.nama);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
    _loadData();
  }

  Future<void> _absenPulang() async {
    final result = await _absensiService.absenPulang();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
    _loadData();
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final tanggal = DateFormat('EEEE, d MMMM yyyy', 'id_ID')
        .format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('SIMAGANG'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RiwayatPage())),
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Selamat Datang, ${_user?.nama ?? '-'}',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(tanggal, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _card('MASUK', _absen?.jamMasuk ?? '-'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _card('PULANG', _absen?.jamPulang ?? '-'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.blue.shade50,
              child: ListTile(
                leading: const Icon(Icons.info, color: Colors.blue),
                title: const Text('Status Hari Ini'),
                trailing: Text(
                  _absen?.status ?? 'Belum Absen',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _absen?.jamMasuk == null ? _absenMasuk : null,
              icon: const Icon(Icons.login),
              label: const Text('ABSEN MASUK'),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50)),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: (_absen?.jamMasuk != null && _absen?.jamPulang == null)
                  ? _absenPulang
                  : null,
              icon: const Icon(Icons.logout),
              label: const Text('ABSEN PULANG'),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}