import 'package:flutter/material.dart';
import '../../models/izin_model.dart';
import '../../services/izin_service.dart';

class IzinAdminPage extends StatelessWidget {
  const IzinAdminPage({super.key});

  // ---------- THEME (SAMA dengan DataPesertaPage & RekapPage) ----------
  static const Color _bgColor = Color(0xFFFAF7F1);
  static const Color _primaryBrown = Color(0xFF5A3218);
  static const Color _textPrimary = Color(0xFF302015);
  static const Color _textSecondary = Color(0xFF786B60);
  static const Color _borderColor = Color(0xFFE2D6C8);
  static const Color _avatarBg = Color(0xFFF0E5D7);
  static const Color _dividerColor = Color(0xFFE5DDD3);

  // ---------- STATUS STYLE ----------
  ({Color bg, Color fg, IconData icon, String label}) _statusStyle(
      String status) {
    switch (status.toLowerCase().trim()) {
      case 'disetujui':
      case 'approved':
        return (
          bg: const Color(0xFFDDEBD8),
          fg: const Color(0xFF29602C),
          icon: Icons.check_circle,
          label: 'Disetujui',
        );
      case 'ditolak':
      case 'rejected':
        return (
          bg: const Color(0xFFF7D2D0),
          fg: const Color(0xFFB82C29),
          icon: Icons.cancel,
          label: 'Ditolak',
        );
      case 'menunggu':
      case 'pending':
      default:
        return (
          bg: const Color(0xFFF1E1CB),
          fg: const Color(0xFF75461F),
          icon: Icons.schedule,
          label: 'Menunggu',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: StreamBuilder<List<IzinModel>>(
                    stream: IzinService().semuaIzin(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: _primaryBrown,
                            strokeWidth: 2,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return _buildEmptyState(
                          icon: Icons.error_outline,
                          title: 'Terjadi kesalahan',
                          description: 'Gagal memuat data pengajuan izin.',
                        );
                      }

                      final data = snapshot.data ?? [];
                      if (data.isEmpty) {
                        return _buildEmptyState(
                          icon: Icons.inbox_outlined,
                          title: 'Belum ada pengajuan',
                          description:
                              'Pengajuan izin dari peserta akan muncul di sini.',
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, top: 12, bottom: 24),
                        itemCount: data.length,
                        itemBuilder: (context, i) {
                          return _buildIzinCard(context, data[i]);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- HEADER (SAMA dengan DataPesertaPage) ----------
  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back,
              color: _primaryBrown,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Pengajuan Izin',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
              ),
            ),
          ),
          const Icon(
            Icons.account_balance,
            color: _primaryBrown,
            size: 26,
          ),
        ],
      ),
    );
  }

  // ---------- IZIN CARD ----------
  Widget _buildIzinCard(BuildContext context, IzinModel izin) {
    final style = _statusStyle(izin.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor, width: 1.2),
      ),
      child: Theme(
        // Hilangkan divider default ExpansionTile agar tampak menyatu
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          childrenPadding:
              const EdgeInsets.fromLTRB(14, 0, 14, 14),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,

          // ---------- COLLAPSED VIEW ----------
          leading: Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: _avatarBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Color(0xFF6A3A18),
              size: 24,
            ),
          ),
          title: Text(
            izin.nama,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${izin.jenis} • ${izin.tanggal}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: _textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Status badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: style.bg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(style.icon, color: style.fg, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            style.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: style.fg,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Ganti icon default jadi chevron dengan warna tema
          iconColor: _primaryBrown,
          collapsedIconColor: _primaryBrown,

          // ---------- EXPANDED VIEW ----------
          children: [
            const Divider(color: _dividerColor, height: 20),

            // Alasan
            _detailRow(
              icon: Icons.description_outlined,
              label: 'Alasan',
              value: izin.alasan,
            ),

            // Keterangan (jika ada)
            if (izin.keterangan.isNotEmpty)
              _detailRow(
                icon: Icons.notes_outlined,
                label: 'Keterangan',
                value: izin.keterangan,
              ),

            // Lampiran (jika ada)
            if (izin.lampiran != null && izin.lampiran!.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text(
                'Lampiran',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  izin.lampiran!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1E6D8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(Icons.broken_image_outlined,
                          color: _primaryBrown, size: 32),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Tombol Aksi (hanya muncul jika status Menunggu)
            if (style.label == 'Menunggu')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFB82C29)),
                        foregroundColor: const Color(0xFFB82C29),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () =>
                          IzinService().updateStatus(izin.id, 'Ditolak'),
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text(
                        'Tolak',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBrown,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () =>
                          IzinService().updateStatus(izin.id, 'Disetujui'),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text(
                        'Setujui',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              // Jika sudah diproses, tampilkan keterangan kecil
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: style.bg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(style.icon, color: style.fg, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Pengajuan telah ${style.label.toLowerCase()}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: style.fg,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------- DETAIL ROW ----------
  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: _primaryBrown),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- EMPTY STATE ----------
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: _borderColor),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}