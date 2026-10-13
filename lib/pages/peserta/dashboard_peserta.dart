import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../models/absensi_model.dart';
import '../../services/auth_service.dart';
import '../../services/absensi_service.dart';
import '../login_page.dart';
import 'riwayat_page.dart';
import 'profil_page.dart';
import 'izin_page.dart';
import 'riwayat_izin_page.dart';
import '../../widgets/logout_dialog.dart';

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

  // ============================================================
  // DESIGN SYSTEM COLORS — SAMA DENGAN PROFIL PAGE
  // ============================================================
  final Color _bgColor = const Color(0xFFFAF7F1);
  final Color _primaryBrown = const Color(0xFF5A3218);
  final Color _textPrimary = const Color(0xFF302015);
  final Color _textSecondary = const Color(0xFF786B60);
  final Color _borderColor = const Color(0xFFE2D6C8);
  final Color _cream = const Color(0xFFF0E5D7);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await AuthService().getUserData();
    final absen = await _absensiService.getAbsenHariIni();
    if (!mounted) return;
    setState(() {
      _user = user;
      _absen = absen;
      _loading = false;
    });
  }

  // ============================================================
  // ABSEN MASUK — GPS only (tanpa foto)
  // ============================================================
  Future<void> _absenMasuk() async {
    final pos = await _absensiService.ambilLokasi();
    if (pos == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal ambil lokasi. Aktifkan GPS.')),
      );
      return;
    }

    final jarak = _absensiService.jarakKeKantor(pos);
    if (jarak > AbsensiService.radiusMeter) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Anda di luar radius kantor (${jarak.toStringAsFixed(0)} m)')),
      );
      return;
    }

    final result = await _absensiService.absenMasuk(
      nama: _user!.nama,
      pos: pos,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(result)));
    _loadData();
  }

  // ============================================================
  // ABSEN PULANG — GPS only (tanpa foto)
  // ============================================================
  Future<void> _absenPulang() async {
    final pos = await _absensiService.ambilLokasi();

    final result = await _absensiService.absenPulang(pos: pos);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(result)));
    _loadData();
  }

  Future<void> _logout() async {
    // Tampilkan dialog konfirmasi
    final confirmed = await LogoutDialog.show(context);
    if (!confirmed) return;

    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  // ============================================================
  // STATUS BADGE WIDGET
  // ============================================================
  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'hadir':
        bgColor = const Color(0xFFDCEBD2);
        textColor = const Color(0xFF315C2F);
        label = 'Hadir';
        break;
      case 'terlambat':
        bgColor = const Color(0xFFF9DFB5);
        textColor = const Color(0xFF8A5A35);
        label = 'Terlambat';
        break;
      case 'izin':
        bgColor = const Color(0xFFDCEBD2);
        textColor = const Color(0xFF315C2F);
        label = 'Izin';
        break;
      case 'sakit':
        bgColor = const Color(0xFFF5D2CE);
        textColor = const Color(0xFFA93630);
        label = 'Sakit';
        break;
      default:
        bgColor = const Color(0xFFF1E8DC);
        textColor = _primaryBrown;
        label = 'Belum Absen';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  // ============================================================
  // ATTENDANCE CARD WIDGET
  // ============================================================
  Widget _buildAttendanceCard({
    required String title,
    required IconData icon,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _borderColor, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _primaryBrown, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: _textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTION BUTTON WIDGET
  // - Icon RATA KIRI
  // - Teks TETAP DI TENGAH
  // ============================================================
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isPrimary,
  }) {
    // Widget isi tombol: icon kiri + teks tengah
    Widget buildContent({required Color iconColor}) {
      return Stack(
        alignment: Alignment.center,
        children: [
          // ---- Icon di kiri ----
          Align(
            alignment: Alignment.centerLeft,
            child: Icon(
              icon,
              size: 20,
              color: iconColor,
            ),
          ),

          // ---- Teks di tengah ----
          Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      );
    }

    if (isPrimary) {
      return SizedBox(
        height: 52,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryBrown,
            foregroundColor: Colors.white,
            disabledBackgroundColor:
                _primaryBrown.withValues(alpha: 0.5),
            disabledForegroundColor:
                Colors.white.withValues(alpha: 0.7),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18),
          ),
          child: buildContent(iconColor: Colors.white),
        ),
      );
    } else {
      return SizedBox(
        height: 52,
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: _primaryBrown,
            backgroundColor: Colors.white,
            side: BorderSide(color: _primaryBrown, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18),
          ),
          child: buildContent(iconColor: _primaryBrown),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: _bgColor,
        body: Center(
          child: CircularProgressIndicator(color: _primaryBrown),
        ),
      );
    }

    final tanggal =
        DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: _primaryBrown,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              final horizontalPadding = isMobile ? 20.0 : 44.0;
              final maxWidth = 1200.0;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ==========================================
                          // HEADER
                          // ==========================================
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _borderColor,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'SIMAGANG',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: _textPrimary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Row(
                                  children: [
                                    _buildHeaderIcon(
                                      Icons.person_outline,
                                      () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const ProfilPage()),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    _buildHeaderIcon(
                                      Icons.calendar_month_outlined,
                                      () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const RiwayatIzinPage()),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    _buildHeaderIcon(
                                      Icons.history,
                                      () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const RiwayatPage()),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    _buildHeaderIcon(
                                      Icons.logout,
                                      _logout,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // ==========================================
                          // WELCOME SECTION
                          // ==========================================
                          Text(
                            'Selamat Datang, ${_user?.nama ?? '-'}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tanggal,
                            style: TextStyle(
                              fontSize: 14,
                              color: _textSecondary,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ==========================================
                          // ATTENDANCE SUMMARY (2-Column Grid)
                          // ==========================================
                          Row(
                            children: [
                              Expanded(
                                child: _buildAttendanceCard(
                                  title: 'MASUK',
                                  icon: Icons.login,
                                  value: _absen?.jamMasuk ?? '--:--',
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _buildAttendanceCard(
                                  title: 'PULANG',
                                  icon: Icons.logout,
                                  value: _absen?.jamPulang ?? '--:--',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // ==========================================
                          // TODAY STATUS
                          // ==========================================
                          Container(
                            height: 64,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  color: _borderColor, width: 1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: _cream,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.info_outline,
                                        color: _primaryBrown,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Status Hari Ini',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                _buildStatusBadge(
                                  _absen?.status ?? 'Belum Absen',
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ==========================================
                          // ACTION BUTTONS
                          // ==========================================
                          _buildActionButton(
                            label: 'ABSEN MASUK',
                            icon: Icons.login,
                            isPrimary: true,
                            onPressed:
                                _absen?.jamMasuk == null ? _absenMasuk : null,
                          ),
                          const SizedBox(height: 12),
                          _buildActionButton(
                            label: 'ABSEN PULANG',
                            icon: Icons.logout,
                            isPrimary: true,
                            onPressed: (_absen?.jamMasuk != null &&
                                    _absen?.jamPulang == null)
                                ? _absenPulang
                                : null,
                          ),
                          const SizedBox(height: 12),
                          _buildActionButton(
                            label: 'AJUKAN IZIN',
                            icon: Icons.note_add_outlined,
                            isPrimary: false,
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const IzinPage()),
                            ),
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: 22,
      color: _primaryBrown,
      splashRadius: 20,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}