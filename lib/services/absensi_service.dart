import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../models/absensi_model.dart';
import 'cloudinary_service.dart';

class AbsensiService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // ⚠️ GANTI dengan koordinat Bappeda Jawa Tengah
  static const double kantorLat = -6.9932;
  static const double kantorLng = 110.4203;
  static const double radiusMeter = 100;

  String _today() {
    final n = DateTime.now();
    return "${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}";
  }

  String _now() {
    final n = DateTime.now();
    return "${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}";
  }

  Future<Position?> ambilLokasi() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return null;
    }
    if (perm == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  double jarakKeKantor(Position pos) => Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        kantorLat,
        kantorLng,
      );

  Future<String> absenMasuk({
    required String nama,
    required Position pos,
    required File foto,
  }) async {
    final uid = _auth.currentUser!.uid;
    final tanggal = _today();

    final existing = await _firestore
        .collection('absensi')
        .where('user_id', isEqualTo: uid)
        .where('tanggal', isEqualTo: tanggal)
        .get();
    if (existing.docs.isNotEmpty) return 'Anda sudah absen masuk hari ini';

    final fotoUrl = await CloudinaryService.uploadFile(
      foto,
      folder: 'simagang/absensi',
    );
    if (fotoUrl == null) return 'Gagal upload foto';

    final now = DateTime.now();
    final jamMasuk = now.hour * 60 + now.minute;
    final batas = 7 * 60 + 30;
    final status = jamMasuk <= batas ? 'Hadir' : 'Terlambat';

    await _firestore.collection('absensi').add({
      'user_id': uid,
      'nama': nama,
      'tanggal': tanggal,
      'jam_masuk': _now(),
      'jam_pulang': null,
      'status': status,
      'latitude': pos.latitude,
      'longitude': pos.longitude,
      'foto_masuk': fotoUrl,
      'created_at': FieldValue.serverTimestamp(),
    });

    return 'Absen masuk berhasil: ${_now()}';
  }

  Future<String> absenPulang({Position? pos, File? foto}) async {
    final uid = _auth.currentUser!.uid;
    final tanggal = _today();

    final snapshot = await _firestore
        .collection('absensi')
        .where('user_id', isEqualTo: uid)
        .where('tanggal', isEqualTo: tanggal)
        .get();
    if (snapshot.docs.isEmpty) return 'Anda belum absen masuk hari ini';

    final doc = snapshot.docs.first;
    if (doc.data()['jam_pulang'] != null) {
      return 'Anda sudah absen pulang hari ini';
    }

    String? fotoUrl;
    if (foto != null) {
      fotoUrl = await CloudinaryService.uploadFile(
        foto,
        folder: 'simagang/absensi',
      );
    }

    await doc.reference.update({
      'jam_pulang': _now(),
      if (pos != null) 'latitude_pulang': pos.latitude,
      if (pos != null) 'longitude_pulang': pos.longitude,
      if (fotoUrl != null) 'foto_pulang': fotoUrl,
    });

    return 'Absen pulang berhasil: ${_now()}';
  }

  Future<AbsensiModel?> getAbsenHariIni() async {
    final uid = _auth.currentUser!.uid;
    final snapshot = await _firestore
        .collection('absensi')
        .where('user_id', isEqualTo: uid)
        .where('tanggal', isEqualTo: _today())
        .get();
    if (snapshot.docs.isEmpty) return null;
    return AbsensiModel.fromMap(
        snapshot.docs.first.id, snapshot.docs.first.data());
  }

  Stream<List<AbsensiModel>> riwayatUser() {
    final uid = _auth.currentUser!.uid;
    return _firestore
        .collection('absensi')
        .where('user_id', isEqualTo: uid)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => AbsensiModel.fromMap(d.id, d.data()))
          .toList();
      list.sort((a, b) => b.tanggal.compareTo(a.tanggal));
      return list;
    });
  }

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