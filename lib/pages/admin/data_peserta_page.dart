import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../peserta/profil_page.dart'; // Sesuaikan path jika berbeda

class DataPesertaPage extends StatefulWidget {
  const DataPesertaPage({super.key});

  @override
  State<DataPesertaPage> createState() => _DataPesertaPageState();
}

class _DataPesertaPageState extends State<DataPesertaPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _submittedQuery = '';

  // Filter gender pakai kode internal 'male'/'female'
  String _selectedGender = 'all'; // 'all' | 'male' | 'female'

  // Warna Design System BAPENDA
  final Color _bgColor = const Color(0xFFFAF7F1);
  final Color _primaryBrown = const Color(0xFF5A3218);
  final Color _textPrimary = const Color(0xFF302015);
  final Color _textSecondary = const Color(0xFF786B60);
  final Color _borderColor = const Color(0xFFE2D6C8);
  final Color _avatarBg = const Color(0xFFF0E5D7);
  final Color _dividerColor = const Color(0xFFE5DDD3);

  // Opsi filter: value = kode internal, label = teks tampilan
  static const List<Map<String, String>> _genderOptions = [
    {'value': 'all', 'label': 'Semua'},
    {'value': 'male', 'label': 'Laki-laki'},
    {'value': 'female', 'label': 'Perempuan'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String value) {
    setState(() {
      _submittedQuery = value.trim();
    });
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('role', isEqualTo: 'peserta')
                        .snapshots(),
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
                        return const Center(
                          child: Text('Terjadi kesalahan saat memuat data.'),
                        );
                      }

                      final docs = snapshot.data?.docs ?? [];

                      final filteredDocs = docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;

                        // --- Filter Search (nama / email) ---
                        final nama =
                            (data['nama'] ?? '').toString().toLowerCase();
                        final email =
                            (data['email'] ?? '').toString().toLowerCase();
                        final query = _submittedQuery.toLowerCase();
                        final matchQuery = query.isEmpty ||
                            nama.contains(query) ||
                            email.contains(query);

                        // --- Filter Gender ---
                        final gender =
                            (data['gender'] ?? '').toString().toLowerCase();
                        final matchGender = _selectedGender == 'all' ||
                            gender == _selectedGender;

                        return matchQuery && matchGender;
                      }).toList();

                      return Column(
                        children: [
                          _buildSearchSection(),
                          Expanded(
                            child: _buildParticipantList(
                                context, filteredDocs, docs.isEmpty),
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
              'Data Peserta',
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
            child: GestureDetector(
              onTap: () => _searchFocusNode.requestFocus(),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _borderColor, width: 1.2),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
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
          // Filter button
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
              onPressed: _showGenderFilterSheet,
            ),
          ),
        ],
      ),
    );
  }

  // --- GENDER FILTER BOTTOM SHEET ---
  void _showGenderFilterSheet() {
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
                  'Filter Gender',
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
                  children: _genderOptions.map((option) {
                    final value = option['value']!;
                    final label = option['label']!;
                    final isSelected = _selectedGender == value;

                    return ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _selectedGender = value);
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
                      setState(() => _selectedGender = 'all');
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

  // --- PARTICIPANT LIST ---
  Widget _buildParticipantList(BuildContext context,
      List<QueryDocumentSnapshot> filteredDocs, bool isAllDataEmpty) {
    if (isAllDataEmpty) {
      return _buildEmptyState(
        icon: Icons.group_add_outlined,
        title: 'Belum ada peserta',
        description: 'Data peserta akan muncul di sini.',
      );
    }

    if (filteredDocs.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off_outlined,
        title: 'Peserta tidak ditemukan',
        description: 'Tidak ada peserta yang sesuai dengan pencarian/filter.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredDocs.length,
      itemBuilder: (context, index) {
        final doc = filteredDocs[index];
        final data = doc.data() as Map<String, dynamic>;
        final nama = data['nama'] ?? '-';
        final email = data['email'] ?? '-';
        final noHp = data['no_hp'] ?? '-';

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilPage(userId: doc.id),
              ),
            );
          },
          child: Container(
            height: 72,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        nama,
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
                        '$email • $noHp',
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
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: _primaryBrown,
                ),
              ],
            ),
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