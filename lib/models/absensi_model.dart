class AbsensiModel {
  final String id;
  final String userId;
  final String nama;
  final String tanggal;
  final String? jamMasuk;
  final String? jamPulang;
  final String status;

  AbsensiModel({
    required this.id,
    required this.userId,
    required this.nama,
    required this.tanggal,
    this.jamMasuk,
    this.jamPulang,
    required this.status,
  });

  factory AbsensiModel.fromMap(String id, Map<String, dynamic> data) {
    return AbsensiModel(
      id: id,
      userId: data['user_id'] ?? '',
      nama: data['nama'] ?? '',
      tanggal: data['tanggal'] ?? '',
      jamMasuk: data['jam_masuk'],
      jamPulang: data['jam_pulang'],
      status: data['status'] ?? 'Alfa',
    );
  }
}