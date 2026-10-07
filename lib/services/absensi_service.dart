import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/absensi_model.dart';

class AbsensiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _today() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  String _now() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  // Absen masuk
  Future<String> absenMasuk(String nama) async {
    final uid = _auth.currentUser!.uid;
    final tanggal = _today();

    // Cek apakah sudah absen hari ini
    final existing = await _firestore
        .collection('absensi')
        .where('user_id', isEqualTo: uid)
        .where('tanggal', isEqualTo: tanggal)
        .get();

    if (existing.docs.isNotEmpty) {
      return 'Anda sudah absen masuk hari ini';
    }

    // Tentukan status: hadir atau terlambat
    final now = DateTime.now();
    final jamMasuk = now.hour * 60 + now.minute;
    final batas = 7 * 60 + 30; // 07:30
    final status = jamMasuk <= batas ? 'Hadir' : 'Terlambat';

    await _firestore.collection('absensi').add({
      'user_id': uid,
      'nama': nama,
      'tanggal': tanggal,
      'jam_masuk': _now(),
      'jam_pulang': null,
      'status': status,
      'created_at': FieldValue.serverTimestamp(),
    });

    return 'Absen masuk berhasil: ${_now()}';
  }

  // Absen pulang
  Future<String> absenPulang() async {
    final uid = _auth.currentUser!.uid;
    final tanggal = _today();

    final snapshot = await _firestore
        .collection('absensi')
        .where('user_id', isEqualTo: uid)
        .where('tanggal', isEqualTo: tanggal)
        .get();

    if (snapshot.docs.isEmpty) {
      return 'Anda belum absen masuk hari ini';
    }

    final doc = snapshot.docs.first;
    if (doc.data()['jam_pulang'] != null) {
      return 'Anda sudah absen pulang hari ini';
    }

    await doc.reference.update({'jam_pulang': _now()});
    return 'Absen pulang berhasil: ${_now()}';
  }

  // Ambil absensi hari ini
  Future<AbsensiModel?> getAbsenHariIni() async {
    final uid = _auth.currentUser!.uid;
    final snapshot = await _firestore
        .collection('absensi')
        .where('user_id', isEqualTo: uid)
        .where('tanggal', isEqualTo: _today())
        .get();

    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return AbsensiModel.fromMap(doc.id, doc.data());
  }

  // Riwayat absensi user
  Stream<List<AbsensiModel>> riwayatUser() {
    final uid = _auth.currentUser!.uid;
    return _firestore
        .collection('absensi')
        .where('user_id', isEqualTo: uid)
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AbsensiModel.fromMap(d.id, d.data()))
            .toList());
  }

  // Semua absensi (admin)
  Stream<List<AbsensiModel>> semuaAbsensi() {
    return _firestore
        .collection('absensi')
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AbsensiModel.fromMap(d.id, d.data()))
            .toList());
  }
}