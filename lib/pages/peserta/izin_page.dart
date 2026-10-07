import 'dart:io';
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
  File? _lampiran;
  bool _loading = false;

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _tanggal = picked);
  }

  Future<void> _pilihLampiran() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _lampiran = File(picked.path));
  }

  Future<void> _kirim() async {
    if (_alasanController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Alasan wajib diisi')));
      return;
    }

    setState(() => _loading = true);
    final user = await AuthService().getUserData();
    final result = await IzinService().ajukanIzin(
      nama: user?.nama ?? '-',
      tanggal: DateFormat('yyyy-MM-dd').format(_tanggal),
      jenis: _jenis,
      alasan: _alasanController.text,
      keterangan: _keteranganController.text,
      lampiran: _lampiran,
    );
    setState(() => _loading = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
    if (result.contains('berhasil')) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengajuan Izin')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: _jenis,
            decoration: const InputDecoration(
                labelText: 'Jenis', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'Izin', child: Text('Izin')),
              DropdownMenuItem(value: 'Sakit', child: Text('Sakit')),
            ],
            onChanged: (v) => setState(() => _jenis = v!),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pilihTanggal,
            child: InputDecorator(
              decoration: const InputDecoration(
                  labelText: 'Tanggal', border: OutlineInputBorder()),
              child: Text(
                  DateFormat('dd MMMM yyyy', 'id_ID').format(_tanggal)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _alasanController,
            maxLines: 3,
            decoration: const InputDecoration(
                labelText: 'Alasan', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _keteranganController,
            maxLines: 2,
            decoration: const InputDecoration(
                labelText: 'Keterangan', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pilihLampiran,
            icon: const Icon(Icons.upload_file),
            label: Text(_lampiran == null
                ? 'Upload Lampiran'
                : 'Lampiran dipilih'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loading ? null : _kirim,
            style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50)),
            child: _loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('KIRIM PENGAJUAN'),
          ),
        ],
      ),
    );
  }
}