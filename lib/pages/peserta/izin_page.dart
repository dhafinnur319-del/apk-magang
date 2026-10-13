import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/izin_service.dart';

class IzinPage extends StatefulWidget {
  const IzinPage({super.key});

  @override
  State<IzinPage> createState() => _IzinPageState();
}

class _IzinPageState extends State<IzinPage> {
  final _alasanController = TextEditingController();
  final _keteranganController = TextEditingController();

  String _jenis = 'Izin';
  DateTime _tanggal = DateTime.now();
  XFile? _lampiran;
  bool _loading = false;

  // ===== Pesan error (ditampilkan di bawah field Alasan) =====
  String? _errorAlasan;

  // ============================================================
  // DESIGN SYSTEM — SAMA DENGAN DASHBOARD PESERTA
  // ============================================================
  final Color _bgColor = const Color(0xFFFAF7F1);
  final Color _primaryBrown = const Color(0xFF5A3218);
  final Color _textPrimary = const Color(0xFF302015);
  final Color _textSecondary = const Color(0xFF786B60);
  final Color _borderColor = const Color(0xFFE2D6C8);
  final Color _cream = const Color(0xFFF0E5D7);
  final Color _placeholder = const Color(0xFF9A9087);
  final Color _danger = const Color(0xFFB94036);

  @override
  void dispose() {
    _alasanController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  // ============================================================
  // DATE PICKER
  // ============================================================
  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5A3218),
              onPrimary: Colors.white,
              onSurface: Color(0xFF302015),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _tanggal = picked);
  }

  // ============================================================
  // FILE PICKER (LAMPIRAN)
  // ============================================================
  Future<void> _pilihLampiran() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() => _lampiran = picked);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih gambar: $e'),
          backgroundColor: _danger,
        ),
      );
    }
  }

  void _hapusLampiran() {
    setState(() => _lampiran = null);
  }

  // ============================================================
  // SUBMIT
  // ============================================================
  Future<void> _kirim() async {
    // Validasi alasan — tampilkan error di bawah field Alasan
    if (_alasanController.text.trim().isEmpty) {
      setState(() => _errorAlasan = 'Alasan wajib diisi');
      return;
    }

    // Reset error saat mulai submit
    setState(() {
      _errorAlasan = null;
      _loading = true;
    });

    final user = await AuthService().getUserData();
    final result = await IzinService().ajukanIzin(
      nama: user?.nama ?? '-',
      tanggal: DateFormat('yyyy-MM-dd').format(_tanggal),
      jenis: _jenis,
      alasan: _alasanController.text,
      keterangan: _keteranganController.text,
      lampiran: _lampiran,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result),
        backgroundColor:
            result.contains('berhasil') ? _primaryBrown : _danger,
      ),
    );
    if (result.contains('berhasil')) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final horizontalPadding = isMobile ? 20.0 : 44.0;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
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
                              Text(
                                'Pengajuan Izin',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: _textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ==========================================
                        // FORM: JENIS
                        // ==========================================
                        _buildLabel('Jenis'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _jenis,
                          isExpanded: true,
                          decoration: _inputDecoration(),
                          style: TextStyle(
                            fontSize: 15,
                            color: _textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: _primaryBrown,
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: 'Izin', child: Text('Izin')),
                            DropdownMenuItem(
                                value: 'Sakit', child: Text('Sakit')),
                          ],
                          onChanged: (v) =>
                              setState(() => _jenis = v ?? 'Izin'),
                        ),

                        const SizedBox(height: 20),

                        // ==========================================
                        // FORM: TANGGAL
                        // ==========================================
                        _buildLabel('Tanggal'),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pilihTanggal,
                          borderRadius: BorderRadius.circular(12),
                          child: InputDecorator(
                            decoration: _inputDecoration(
                              suffixIcon: Icon(
                                Icons.calendar_month_outlined,
                                color: _primaryBrown,
                              ),
                            ),
                            child: Text(
                              DateFormat('dd MMMM yyyy', 'id_ID')
                                  .format(_tanggal),
                              style: TextStyle(
                                fontSize: 15,
                                color: _textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ==========================================
                        // FORM: ALASAN
                        // ==========================================
                        _buildLabel('Alasan'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _alasanController,
                          minLines: 4,
                          maxLines: 6,
                          textInputAction: TextInputAction.newline,
                          onChanged: (_) {
                            // Hapus pesan error saat user mulai mengetik
                            if (_errorAlasan != null) {
                              setState(() => _errorAlasan = null);
                            }
                          },
                          style: TextStyle(
                            fontSize: 15,
                            color: _textPrimary,
                          ),
                          decoration: _inputDecoration(
                            hint: 'Masukkan alasan pengajuan izin...',
                            hasError: _errorAlasan != null,
                          ),
                        ),

                        // ===== Pesan error di bawah field Alasan =====
                        if (_errorAlasan != null) ...[
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              _errorAlasan!,
                              style: const TextStyle(
                                color: Color(0xFFB94036),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // ==========================================
                        // FORM: KETERANGAN
                        // ==========================================
                        _buildLabel('Keterangan'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _keteranganController,
                          minLines: 4,
                          maxLines: 6,
                          textInputAction: TextInputAction.newline,
                          style: TextStyle(
                            fontSize: 15,
                            color: _textPrimary,
                          ),
                          decoration: _inputDecoration(
                            hint: 'Masukkan keterangan tambahan...',
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ==========================================
                        // UPLOAD LAMPIRAN
                        // ==========================================
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: _pilihLampiran,
                            icon: const Icon(
                              Icons.file_upload_outlined,
                              size: 20,
                            ),
                            label: Text(
                              _lampiran == null
                                  ? 'Upload Lampiran'
                                  : 'Ganti Lampiran',
                              style: const TextStyle(
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

                        // Info file yang dipilih
                        if (_lampiran != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: _cream,
                              border: Border.all(
                                  color: _borderColor, width: 1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.insert_drive_file_outlined,
                                  color: _primaryBrown,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _lampiran!.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: _hapusLampiran,
                                  icon: const Icon(Icons.close),
                                  iconSize: 18,
                                  color: _danger,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 28),

                        // ==========================================
                        // SUBMIT BUTTON
                        // ==========================================
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _kirim,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryBrown,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  _primaryBrown.withValues(alpha: 0.5),
                              disabledForegroundColor:
                                  Colors.white.withValues(alpha: 0.8),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'KIRIM PENGAJUAN',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }

  InputDecoration _inputDecoration({
    String? hint,
    Widget? suffixIcon,
    bool hasError = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 15,
        color: _placeholder,
      ),
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: hasError ? _danger : _borderColor,
          width: hasError ? 1.2 : 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: hasError ? _danger : _primaryBrown,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _danger, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _danger, width: 1.5),
      ),
    );
  }
}