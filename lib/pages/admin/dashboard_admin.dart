import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../login_page.dart';
import 'data_peserta_page.dart';
import 'data_absensi_page.dart';
import 'rekap_page.dart';
import 'izin_admin_page.dart';

class DashboardAdmin extends StatelessWidget {
  const DashboardAdmin({super.key});

  // Warna Tema
  final Color _bgColor = const Color(0xFFFAF7F1);
  final Color _primaryBrown = const Color(0xFF5A3218);
  final Color _textPrimary = const Color(0xFF302015);
  final Color _textSecondary = const Color(0xFF786B60);
  final Color _borderColor = const Color(0xFFE2D6C8);
  final Color _iconBg = const Color(0xFFF0E5D7);

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    if (!context.mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Dashboard Admin',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: _primaryBrown),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _borderColor, height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _menuCard(
            context,
            icon: Icons.people_alt_outlined,
            title: 'Data Peserta',
            subtitle: 'Kelola data peserta',
            page: const DataPesertaPage(),
          ),
          _menuCard(
            context,
            icon: Icons.list_alt_outlined,
            title: 'Data Absensi',
            subtitle: 'Lihat data kehadiran',
            page: const DataAbsensiPage(),
          ),
          _menuCard(
            context,
            icon: Icons.assignment_outlined,
            title: 'Izin',
            subtitle: 'Kelola pengajuan izin',
            page: const IzinAdminPage(),
          ),
          _menuCard(
            context,
            icon: Icons.bar_chart_outlined,
            title: 'Rekap Absensi',
            subtitle: 'Rekapitulasi absensi',
            page: const RekapPage(),
          ),
        ],
      ),
    );
  }

  Widget _menuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget page,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _primaryBrown, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: _textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: _textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: _primaryBrown,
          size: 20,
        ),
      ),
    );
  }
}