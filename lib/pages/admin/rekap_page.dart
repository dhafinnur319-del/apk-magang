import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/absensi_model.dart';
import '../../models/izin_model.dart';
import '../../services/absensi_service.dart';
import '../../services/izin_service.dart';

class RekapPage extends StatefulWidget {
  const RekapPage({super.key});

  @override
  State<RekapPage> createState() => _RekapPageState();
}

class _RekapPageState extends State<RekapPage> {
  // ---------- THEME ----------
  static const Color _bgColor = Color(0xFFFAF7F1);
  static const Color _primaryBrown = Color(0xFF5A3218);
  static const Color _textPrimary = Color(0xFF302015);
  static const Color _textSecondary = Color(0xFF786B60);
  static const Color _borderColor = Color(0xFFE2D6C8);
  static const Color _avatarBg = Color(0xFFF0E5D7);
  static const Color _dividerColor = Color(0xFFE5DDD3);

  // ---------- STATE ----------
  String? _selectedParticipant;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  // Hari kerja: Senin(1) s/d Jumat(5)
  static const Set<int> _workDays = {1, 2, 3, 4, 5};

  // ---------- HELPER BULAN ----------
  static const List<String> _bulanIndo = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  String _monthLabel(DateTime d) => '${_bulanIndo[d.month - 1]} ${d.year}';

  int _daysInMonth(DateTime d) => DateTime(d.year, d.month + 1, 0).day;

  /// Hitung total hari kerja (Senin–Jumat) dalam bulan tertentu.
  int _workDaysInMonth(DateTime d) {
    final lastDay = _daysInMonth(d);
    int count = 0;
    for (int i = 1; i <= lastDay; i++) {
      final date = DateTime(d.year, d.month, i);
      if (_workDays.contains(date.weekday)) count++;
    }
    return count;
  }

  // ---------- HELPER STATUS ----------
  String _normalizeStatus(String raw) {
    final s = raw.toLowerCase().trim();
    if (s == 'hadir') return 'Hadir';
    if (s == 'terlambat') return 'Terlambat';
    if (s == 'izin') return 'Izin';
    if (s == 'sakit') return 'Sakit';
    if (s == 'alfa' || s == 'alpha') return 'Alfa';
    return 'Alfa';
  }

  ({Color bg, Color fg, IconData icon}) _statusStyle(String status) {
    switch (status) {
      case 'Hadir':
        return (bg: const Color(0xFFDDEBD8), fg: const Color(0xFF29602C), icon: Icons.check_circle);
      case 'Terlambat':
        return (bg: const Color(0xFFF1E1CB), fg: const Color(0xFF75461F), icon: Icons.schedule);
      case 'Izin':
        return (bg: const Color(0xFFE8DED2), fg: const Color(0xFF6A4A31), icon: Icons.description);
      case 'Sakit':
        return (bg: const Color(0xFFF7D2D0), fg: const Color(0xFFB82C29), icon: Icons.medical_services);
      case 'Alfa':
      default:
        return (bg: const Color(0xFFE5E1DC), fg: const Color(0xFF51483F), icon: Icons.person_off);
    }
  }

  DateTime? _parseTanggal(String t) {
    try {
      return DateTime.parse(t);
    } catch (_) {
      return null;
    }
  }

  bool _isInSelectedMonth(String tanggalStr) {
    final d = _parseTanggal(tanggalStr);
    if (d == null) return false;
    return d.year == _selectedMonth.year && d.month == _selectedMonth.month;
  }

  // ---------- BUILD ----------
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
                  // Gabungkan 3 stream: users, absensi, izin
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('role', isEqualTo: 'peserta')
                        .snapshots(),
                    builder: (context, userSnap) {
                      if (userSnap.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: _primaryBrown, strokeWidth: 2),
                        );
                      }
                      if (userSnap.hasError) return _buildErrorState();

                      final userDocs = userSnap.data?.docs ?? [];
                      final participantList = userDocs
                          .map((d) => (d.data() as Map<String, dynamic>)['nama']?.toString() ?? '')
                          .where((n) => n.isNotEmpty)
                          .toList()
                        ..sort();

                      return StreamBuilder<List<AbsensiModel>>(
                        stream: AbsensiService().semuaAbsensi(),
                        builder: (context, absSnap) {
                          return StreamBuilder<List<IzinModel>>(
                            stream: IzinService().semuaIzin(),
                            builder: (context, izinSnap) {
                              final isWaiting =
                                  absSnap.connectionState == ConnectionState.waiting ||
                                  izinSnap.connectionState == ConnectionState.waiting;
                              if (isWaiting) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: _primaryBrown, strokeWidth: 2),
                                );
                              }
                              if (absSnap.hasError || izinSnap.hasError) {
                                return _buildErrorState();
                              }

                              final allAbsensi = absSnap.data ?? [];
                              final allIzin = izinSnap.data ?? [];

                              return ListView(
                                padding: const EdgeInsets.only(bottom: 24),
                                children: [
                                  _buildParticipantSelector(participantList),
                                  if (_selectedParticipant == null)
                                    _buildInitialEmptyState()
                                  else
                                    ..._buildSelectedContent(allAbsensi, allIzin),
                                ],
                              );
                            },
                          );
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

  // ---------- HEADER ----------
  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _borderColor, width: 1)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: _primaryBrown, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Rekap Absensi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                color: _textPrimary)),
          ),
          const Icon(Icons.account_balance, color: _primaryBrown, size: 26),
        ],
      ),
    );
  }

  // ---------- SELECTOR ----------
  Widget _buildParticipantSelector(List<String> participants) {
    final hasSelection = _selectedParticipant != null;
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _showParticipantPicker(participants),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _borderColor, width: 1.2),
            ),
            child: Row(
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: const BoxDecoration(
                    color: _avatarBg, shape: BoxShape.circle),
                  child: const Icon(Icons.person,
                    color: Color(0xFF6A3A18), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        hasSelection ? _selectedParticipant! : 'Pilih Peserta Magang',
                        style: const TextStyle(fontSize: 14,
                          fontWeight: FontWeight.bold, color: _textPrimary),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasSelection ? 'Ketuk untuk ganti peserta'
                          : 'Silakan pilih peserta untuk melihat rekap',
                        style: const TextStyle(fontSize: 12,
                          color: _textSecondary),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down,
                  color: _primaryBrown, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showParticipantPicker(List<String> participants) {
    if (participants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada peserta terdaftar.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: _bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: _borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text('Pilih Peserta (${participants.length})',
                  style: const TextStyle(fontSize: 16,
                    fontWeight: FontWeight.bold, color: _textPrimary)),
                const SizedBox(height: 12),
                ...participants.map((name) {
                  final isSelected = _selectedParticipant == name;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () {
                      setState(() => _selectedParticipant = name);
                      Navigator.pop(context);
                    },
                    leading: Container(
                      width: 38, height: 38,
                      decoration: const BoxDecoration(
                        color: _avatarBg, shape: BoxShape.circle),
                      child: const Icon(Icons.person,
                        color: Color(0xFF6A3A18), size: 20),
                    ),
                    title: Text(name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: _textPrimary, fontSize: 14)),
                    trailing: isSelected ? const Icon(Icons.check,
                      color: _primaryBrown, size: 18) : null,
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------- INITIAL EMPTY ----------
  Widget _buildInitialEmptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Column(
        children: [
          Container(
            width: 140, height: 140,
            decoration: const BoxDecoration(
              color: _avatarBg, shape: BoxShape.circle),
            child: const Icon(Icons.assignment_ind_outlined,
              size: 70, color: _primaryBrown),
          ),
          const SizedBox(height: 24),
          const Text('Belum ada peserta yang dipilih',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
              color: _textPrimary)),
          const SizedBox(height: 8),
          const Text(
            'Silakan pilih peserta magang terlebih dahulu\nuntuk melihat rekap absensi.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, height: 1.5,
              color: _textSecondary)),
        ],
      ),
    );
  }

  // ---------- SELECTED CONTENT (LOGIKA ALFA DI SINI) ----------
  List<Widget> _buildSelectedContent(
      List<AbsensiModel> allAbsensi, List<IzinModel> allIzin) {
    final name = _selectedParticipant!;

    // 1. Ambil absensi peserta di bulan terpilih
    final absensiPeserta = allAbsensi
        .where((a) =>
            a.nama.toLowerCase() == name.toLowerCase() &&
            _isInSelectedMonth(a.tanggal))
        .toList();

    // 2. Ambil izin DISETUJUI peserta di bulan terpilih
    final izinDisetujui = allIzin.where((i) {
      return i.nama.toLowerCase() == name.toLowerCase() &&
          i.status.toLowerCase() == 'disetujui' &&
          _isInSelectedMonth(i.tanggal);
    }).toList();

    // 3. Counter status
    final counts = <String, int>{
      'Hadir': 0, 'Terlambat': 0, 'Izin': 0, 'Sakit': 0, 'Alfa': 0,
    };
    final Set<String> tanggalSudahDihitung = {};

    // 3a. Dari koleksi absensi
    for (final a in absensiPeserta) {
      final key = _normalizeStatus(a.status);
      counts[key] = (counts[key] ?? 0) + 1;
      tanggalSudahDihitung.add(a.tanggal);
    }

    // 3b. Tambahan dari koleksi izin yang DISETUJUI
    //     (hindari double-count kalau tanggal sudah ada di absensi)
    for (final i in izinDisetujui) {
      if (tanggalSudahDihitung.contains(i.tanggal)) continue;
      final jenis = i.jenis.toLowerCase();
      final key = (jenis == 'sakit') ? 'Sakit' : 'Izin';
      counts[key] = (counts[key] ?? 0) + 1;
      tanggalSudahDihitung.add(i.tanggal);
    }

    // 4. HITUNG ALFA OTOMATIS
    final totalHariKerja = _workDaysInMonth(_selectedMonth);
    final totalTercatat = counts['Hadir']! + counts['Terlambat']! +
        counts['Izin']! + counts['Sakit']!;
    final alfa = (totalHariKerja - totalTercatat).clamp(0, totalHariKerja);
    counts['Alfa'] = alfa;

    // 5. Data untuk Ringkasan
    final hadirCount = counts['Hadir']!;
    final progress =
        totalHariKerja == 0 ? 0.0 : hadirCount / totalHariKerja;

    // 6. Riwayat absensi (dari koleksi absensi saja)
    final sortedAbsensi = [...absensiPeserta]
      ..sort((a, b) => b.tanggal.compareTo(a.tanggal));

    return [
      _buildMonthSelector(),
      _buildSummaryCards(counts),
      _buildRingkasanCard(
        hadirCount: hadirCount,
        workDays: totalHariKerja,
        progress: progress,
      ),
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 20, 16, 6),
        child: Text('Riwayat Absensi',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
            color: _textPrimary)),
      ),
      if (sortedAbsensi.isEmpty)
        _buildNoDataState()
      else
        ...sortedAbsensi.map(_buildAttendanceItem),
    ];
  }

  // ---------- MONTH SELECTOR ----------
  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: _showMonthPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _borderColor, width: 1.2),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, size: 20, color: _primaryBrown),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(_monthLabel(_selectedMonth),
                    style: const TextStyle(fontSize: 14,
                      fontWeight: FontWeight.bold, color: _textPrimary)),
                ),
                const Icon(Icons.keyboard_arrow_down,
                  color: _primaryBrown, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMonthPicker() {
    final now = DateTime.now();
    final months = List.generate(12, (i) => DateTime(now.year, i + 1));

    showModalBottomSheet(
      context: context,
      backgroundColor: _bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: _borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text('Pilih Bulan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                    color: _textPrimary)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: months.map((m) {
                    final isSelected = m.year == _selectedMonth.year &&
                        m.month == _selectedMonth.month;
                    return ChoiceChip(
                      label: Text('${_bulanIndo[m.month - 1]} ${m.year}'),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _selectedMonth = m);
                        Navigator.pop(context);
                      },
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : _textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12),
                      backgroundColor: Colors.white,
                      selectedColor: _primaryBrown,
                      side: BorderSide(
                        color: isSelected ? _primaryBrown : _borderColor,
                        width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------- SUMMARY CARDS ----------
  Widget _buildSummaryCards(Map<String, int> counts) {
    const firstRow = ['Hadir', 'Terlambat', 'Izin'];
    const secondRow = ['Sakit', 'Alfa'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          Row(
            children: firstRow.asMap().entries.map((e) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: e.key == firstRow.length - 1 ? 0 : 8),
                child: _summaryCard(e.value, counts[e.value] ?? 0),
              ),
            )).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: secondRow.asMap().entries.map((e) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: e.key == secondRow.length - 1 ? 0 : 8),
                child: _summaryCard(e.value, counts[e.value] ?? 0),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, int value) {
    final style = _statusStyle(label);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor, width: 1.2),
      ),
      child: Column(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(color: style.bg, shape: BoxShape.circle),
            child: Icon(style.icon, color: style.fg, size: 18),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11,
            fontWeight: FontWeight.w600, color: _textPrimary)),
          const SizedBox(height: 2),
          Text('$value', style: const TextStyle(fontSize: 18,
            fontWeight: FontWeight.bold, color: _textPrimary)),
        ],
      ),
    );
  }

  // ---------- RINGKASAN ----------
  Widget _buildRingkasanCard({
    required int hadirCount,
    required int workDays,
    required double progress,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _borderColor, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ringkasan Kehadiran',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                color: _textPrimary)),
            const SizedBox(height: 2),
            Text('Data kehadiran dalam periode ${_monthLabel(_selectedMonth)}',
              style: const TextStyle(fontSize: 11, color: _textSecondary)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: const Color(0xFFE9E0D4),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF8A512B)),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('$hadirCount / $workDays',
                  style: const TextStyle(fontSize: 13,
                    fontWeight: FontWeight.bold, color: _textPrimary)),
                const SizedBox(width: 6),
                const Text('Hadir',
                  style: TextStyle(fontSize: 12, color: _textSecondary)),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFE5DDD3), height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _infoItem(
                    icon: Icons.calendar_month,
                    title: 'Periode',
                    value: '1 – ${_daysInMonth(_selectedMonth)} '
                        '${_bulanIndo[_selectedMonth.month - 1]} '
                        '${_selectedMonth.year}',
                  ),
                ),
                Container(width: 1, height: 34, color: const Color(0xFFE5DDD3)),
                Expanded(
                  child: _infoItem(
                    icon: Icons.schedule,
                    title: 'Total Hari Kerja',
                    value: '$workDays hari',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _primaryBrown),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 10,
                  color: _textSecondary)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w600, color: _textPrimary),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- ATTENDANCE ITEM ----------
  Widget _buildAttendanceItem(AbsensiModel a) {
    final normalized = _normalizeStatus(a.status);
    final style = _statusStyle(normalized);
    final masuk = (a.jamMasuk == null || a.jamMasuk!.isEmpty) ? '-' : a.jamMasuk!;
    final pulang = (a.jamPulang == null || a.jamPulang!.isEmpty) ? '-' : a.jamPulang!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: _dividerColor, width: 1)),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: style.bg, shape: BoxShape.circle),
              child: Icon(style.icon, color: style.fg, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.tanggal, style: const TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w600, color: _textPrimary)),
                  const SizedBox(height: 2),
                  Text('Masuk: $masuk   ·   Pulang: $pulang',
                    style: const TextStyle(fontSize: 11,
                      color: _textSecondary),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: style.bg, borderRadius: BorderRadius.circular(20)),
              child: Text(normalized, style: TextStyle(fontSize: 10,
                fontWeight: FontWeight.w600, color: style.fg)),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- NO DATA ----------
  Widget _buildNoDataState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          Icon(Icons.event_busy_outlined, size: 48, color: _borderColor),
          const SizedBox(height: 12),
          const Text('Belum ada data absensi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
              color: _textPrimary)),
          const SizedBox(height: 4),
          Text(
            'Belum ada data untuk ${_selectedParticipant ?? "peserta"} '
            'pada ${_monthLabel(_selectedMonth)}.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: _textSecondary)),
        ],
      ),
    );
  }

  // ---------- ERROR ----------
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, size: 48, color: _borderColor),
            const SizedBox(height: 12),
            const Text('Gagal memuat data',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                color: _textPrimary)),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBrown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => setState(() {}),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}