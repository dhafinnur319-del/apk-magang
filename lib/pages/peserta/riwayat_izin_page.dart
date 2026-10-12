import 'package:flutter/material.dart';
import '../../models/izin_model.dart';
import '../../services/izin_service.dart';

class RiwayatIzinPage extends StatelessWidget {
  const RiwayatIzinPage({super.key});

  // ============================================================
  // DESIGN SYSTEM — SAMA DENGAN DASHBOARD PESERTA
  // ============================================================
  static const Color _bgColor = Color(0xFFFAF7F1);
  static const Color _primaryBrown = Color(0xFF5A3218);
  static const Color _textPrimary = Color(0xFF302015);
  static const Color _textSecondary = Color(0xFF786B60);
  static const Color _borderColor = Color(0xFFE2D6C8);
  static const Color _cream = Color(0xFFF0E5D7);
  static const Color _iconBg = Color(0xFFF3E8DA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final horizontalPadding = isMobile ? 20.0 : 44.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  children: [
                    // ==========================================
                    // HEADER
                    // ==========================================
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 16,
                      ),
                      child: Container(
                        height: 60,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _borderColor,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back),
                              iconSize: 22,
                              color: _primaryBrown,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Riwayat Izin',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ==========================================
                    // CONTENT
                    // ==========================================
                    Expanded(
                      child: StreamBuilder<List<IzinModel>>(
                        stream: IzinService().riwayatIzinUser(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: _primaryBrown,
                              ),
                            );
                          }

                          final data = snapshot.data ?? [];

                          if (data.isEmpty) {
                            return _buildEmptyState();
                          }

                          return ListView.separated(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                              vertical: 16,
                            ),
                            itemCount: data.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, i) {
                              return _buildIzinItem(data[i]);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // IZIN ITEM
  // ============================================================
  Widget _buildIzinItem(IzinModel izin) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: _primaryBrown,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // Middle: Jenis • Tanggal + Alasan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${izin.jenis}  •  ${izin.tanggal}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  izin.alasan,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Status badge
          _buildStatusBadge(izin.status),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================
  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String label;

    final s = status.toLowerCase();

    if (s == 'disetujui' || s == 'approved') {
      bgColor = const Color(0xFFDDEBD5);
      textColor = const Color(0xFF35652F);
      icon = Icons.check_circle;
      label = 'Disetujui';
    } else if (s == 'ditolak' || s == 'rejected') {
      bgColor = const Color(0xFFF8D8D5);
      textColor = const Color(0xFFB94035);
      icon = Icons.cancel;
      label = 'Ditolak';
    } else {
      bgColor = const Color(0xFFF8E2B8);
      textColor = const Color(0xFF8A5A35);
      icon = Icons.schedule;
      label = 'Menunggu';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: _cream,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: _primaryBrown,
                size: 44,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum ada riwayat izin',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Riwayat pengajuan izin akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: _textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}