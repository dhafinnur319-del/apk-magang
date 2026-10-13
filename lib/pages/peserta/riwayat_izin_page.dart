import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
                              return _buildIzinItem(context, data[i]);
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
  Widget _buildIzinItem(BuildContext context, IzinModel izin) {
    return InkWell(
      onTap: () => _showDetailDialog(context, izin),
      borderRadius: BorderRadius.circular(14),
      child: Container(
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
      ),
    );
  }

  // ============================================================
  // DETAIL DIALOG — menampilkan info + tombol Lihat Lampiran
  // ============================================================
  void _showDetailDialog(BuildContext context, IzinModel izin) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- Title bar ----
                  Row(
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        color: _primaryBrown,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Detail Pengajuan',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(Icons.close),
                        iconSize: 20,
                        color: _textSecondary,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: _borderColor, height: 1),
                  const SizedBox(height: 16),

                  // ---- Jenis ----
                  _detailRow('Jenis', izin.jenis),
                  const SizedBox(height: 12),

                  // ---- Tanggal ----
                  _detailRow('Tanggal', izin.tanggal),
                  const SizedBox(height: 12),

                  // ---- Status ----
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 80,
                        child: Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 13,
                            color: _textSecondary,
                          ),
                        ),
                      ),
                      _buildStatusBadge(izin.status),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ---- Alasan ----
                  _detailRow('Alasan', izin.alasan),
                  const SizedBox(height: 12),

                  // ---- Keterangan ----
                  if (izin.keterangan.isNotEmpty)
                    _detailRow('Keterangan', izin.keterangan),

                  const SizedBox(height: 20),

                  // ---- Tombol Lihat Lampiran ----
                  if (izin.lampiran != null &&
                      izin.lampiran!.isNotEmpty) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          _openLampiran(context, izin.lampiran!);
                        },
                        icon: const Icon(
                          Icons.image_outlined,
                          size: 20,
                        ),
                        label: const Text(
                          'Lihat Lampiran',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _primaryBrown,
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: _primaryBrown,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: _cream,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: _textSecondary,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Tidak ada lampiran',
                            style: TextStyle(
                              fontSize: 13,
                              color: _textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: _textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // OPEN LAMPIRAN — pakai url_launcher (Web & Mobile)
  // ============================================================
  Future<void> _openLampiran(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL lampiran tidak valid')),
      );
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak bisa membuka lampiran')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka lampiran: $e')),
      );
    }
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