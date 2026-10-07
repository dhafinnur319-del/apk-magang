import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/izin_model.dart';
import 'cloudinary_service.dart';

class IzinService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<String> ajukanIzin({
    required String nama,
    required String tanggal,
    required String jenis,
    required String alasan,
    required String keterangan,
    File? lampiran,
  }) async {
    try {
      final uid = _auth.currentUser!.uid;
      String? lampiranUrl;

      if (lampiran != null) {
        lampiranUrl = await CloudinaryService.uploadFile(
          lampiran,
          folder: 'simagang/izin',
        );
        if (lampiranUrl == null) {
          return 'Gagal upload lampiran';
        }
      }

      await _firestore.collection('izin').add({
        'user_id': uid,
        'nama': nama,
        'tanggal': tanggal,
        'jenis': jenis,
        'alasan': alasan,
        'keterangan': keterangan,
        'lampiran': lampiranUrl,
        'status': 'Menunggu',
        'created_at': FieldValue.serverTimestamp(),
      });

      return 'Pengajuan berhasil dikirim';
    } catch (e) {
      return 'Gagal: $e';
    }
  }

  Stream<List<IzinModel>> riwayatIzinUser() {
    final uid = _auth.currentUser!.uid;
    return _firestore
        .collection('izin')
        .where('user_id', isEqualTo: uid)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => IzinModel.fromMap(d.id, d.data()))
          .toList();
      list.sort((a, b) => b.tanggal.compareTo(a.tanggal));
      return list;
    });
  }

  Stream<List<IzinModel>> semuaIzin() {
    return _firestore
        .collection('izin')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => IzinModel.fromMap(d.id, d.data()))
            .toList());
  }

  Future<void> updateStatus(String id, String status) async {
    await _firestore.collection('izin').doc(id).update({'status': status});
  }
}