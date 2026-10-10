import 'package:flutter/material.dart';
import '../../models/absensi_model.dart';
import '../../services/absensi_service.dart';

class DataAbsensiPage extends StatefulWidget {
  const DataAbsensiPage({super.key});

  @override
  State<DataAbsensiPage> createState() => _DataAbsensiPageState();
}

class _DataAbsensiPageState extends State<DataAbsensiPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(); // <-- TAMBAHAN
  String _submittedQuery = '';
  String _selectedStatus = 'Semua';

  // Warna Design System BAPENDA
  final Color _bgColor = const Color(0xFFFAF7F1);
  final Color _primaryBrown = const Color(0xFF5A3218);
  final Color _textPrimary = const Color(0xFF302015);
  final Color _textSecondary = const Color(0xFF786B60);
  final Color _borderColor = const Color(0xFFE2D6C8);
  final Color _avatarBg = const Color(0xFFF0E5D7);
  final Color _dividerColor = const Color(0xFFE5DDD3);

  static const List<String> _statusOptions = [
    'Semua',
    'Hadir',
    'Terlambat',
    'Izin',
    'Sakit',
    'Alfa',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose(); // <-- TAMBAHAN
    super.dispose();
  }

  void _onSearchSubmitted(String value) {
    setState(() {
      _submittedQuery = value.trim();
    });
    // Pakai focusNode, bukan FocusScope
    _searchFocusNode.unfocus();
  }

  // Warna badge status
  ({Color bg, Color fg}) _statusColors(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return (bg: const Color(0xFFDDEBD8), fg: const Color(0xFF29602C));
      case 'terlambat':
        return (bg: const Color(0xFFF1E1CB), fg: const Color(0xFF75461F));
      case 'izin':
        return (bg: const Color(0xFFE8DED2), fg: const Color(0xFF6A4A31));
      case 'sakit':
        return (bg: const Color(0xFFF7D2D0), fg: const Color(0xFFB82C29));
      case 'alfa':
      case 'alpha':
        return (bg: const Color(0xFFE5E1DC), fg: const Color(0xFF51483F));
      default:
        return (bg: const Color(0xFFE5E1DC), fg: const Color(0xFF51483F));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      // Penting: resizeToAvoidBottomInset agar layout tidak "nyangkut"
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: StreamBuilder<List<AbsensiModel>>(
                    stream: AbsensiService().semuaAbsensi(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF5A3218),
                            strokeWidth: 2,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return _buildEmptyState(
                          icon: Icons.error_outline,
                          title: 'Terjadi kesalahan',
                          description: 'Gagal memuat data absensi.',
                        );
                      }

                      final allData = snapshot.data ?? [];

                      final sorted = [...allData]..sort(
                          (a, b) => b.tanggal.compareTo(a.tanggal),
                        );

                      final filtered = sorted.where((a) {
                        final matchQuery = _submittedQuery.isEmpty ||
                            a.nama
                                .toLowerCase()
                                .contains(_submittedQuery.toLowerCase());
                        final matchStatus = _selectedStatus == 'Semua' ||
                            a.status.toLowerCase() ==
                                _selectedStatus.toLowerCase();
                        return matchQuery && matchStatus;
                      }).toList();

                      return Column(
                        children: [
                          _buildSearchSection(),
                          Expanded(
                            child: _buildAbsensiList(
                              context,
                              filtered,
                              allData.isEmpty,
                            ),
                          ),
                        ],
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

  // --- HEADER ---
  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back,
              color: _primaryBrown,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Data Absensi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
              ),
            ),
          ),
          Icon(
            Icons.account_balance,
            color: _primaryBrown,
            size: 26,
          ),
        ],
      ),
    );
  }

  // --- SEARCH & FILTER ---
  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 6),
      child: Row(
        children: [
          Expanded(
            // GestureDetector agar tap di mana saja fokus ke TextField
            child: GestureDetector(
              onTap: () {
                _searchFocusNode.requestFocus();
              },
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _borderColor, width: 1.2),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode, // <-- PASANG FOCUS NODE
                  textInputAction: TextInputAction.search,
                  onSubmitted: _onSearchSubmitted,
                  style: TextStyle(fontSize: 14, color: _textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Cari peserta...',
                    hintStyle:
                        TextStyle(color: _textSecondary, fontSize: 14),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      child: Icon(Icons.search,
                          color: _primaryBrown, size: 20),
                    ),
                    // Tombol clear (X) jika ada teks
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close,
                                color: Color(0xFF786B60), size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _submittedQuery = '');
                            },
                          )
                        : null,
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: 0, minHeight: 0),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _borderColor, width: 1.2),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.filter_alt_outlined,
                  color: _primaryBrown, size: 20),
              onPressed: _showFilterSheet,
            ),
          ),
        ],
      ),
    );
  }

  // --- FILTER BOTTOM SHEET ---
  void _showFilterSheet() {
    // Pastikan keyboard tertutup saat buka filter
    _searchFocusNode.unfocus();

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
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: _borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Filter Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _statusOptions.map((status) {
                    final isSelected = _selectedStatus == status;
                    return ChoiceChip(
                      label: Text(status),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _selectedStatus = status);
                        Navigator.pop(context);
                      },
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : _textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                      backgroundColor: Colors.white,
                      selectedColor: _primaryBrown,
                      side: BorderSide(
                        color: isSelected ? _primaryBrown : _borderColor,
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _borderColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      setState(() => _selectedStatus = 'Semua');
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Reset Filter',
                      style: TextStyle(
                        color: _primaryBrown,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- ATTENDANCE LIST ---
  Widget _buildAbsensiList(
    BuildContext context,
    List<AbsensiModel> data,
    bool isAllEmpty,
  ) {
    if (isAllEmpty) {
      return _buildEmptyState(
        icon: Icons.event_busy_outlined,
        title: 'Belum ada data absensi',
        description: 'Data absensi akan muncul di sini.',
      );
    }

    if (data.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off_outlined,
        title: 'Data tidak ditemukan',
        description: 'Tidak ada data yang sesuai dengan pencarian.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final a = data[index];
        final colors = _statusColors(a.status);
        final masuk = (a.jamMasuk == null || a.jamMasuk!.isEmpty)
            ? '-'
            : a.jamMasuk!;
        final pulang = (a.jamPulang == null || a.jamPulang!.isEmpty)
            ? '-'
            : a.jamPulang!;

        return Container(
          constraints: const BoxConstraints(minHeight: 72),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: _dividerColor, width: 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _avatarBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: const Color(0xFF6A3A18),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        a.nama,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${a.tanggal}  •  Masuk: $masuk',
                        style: TextStyle(
                          fontSize: 12,
                          color: _textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Pulang: $pulang',
                        style: TextStyle(
                          fontSize: 12,
                          color: _textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                constraints: const BoxConstraints(minWidth: 72),
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  a.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors.fg,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- EMPTY STATE ---
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}