class IzinModel {
  final String id;
  final String userId;
  final String nama;
  final String tanggal;
  final String jenis;
  final String alasan;
  final String? lampiran;
  final String status;
  final String keterangan;

  IzinModel({
    required this.id,
    required this.userId,
    required this.nama,
    required this.tanggal,
    required this.jenis,
    required this.alasan,
    this.lampiran,
    required this.status,
    required this.keterangan,
  });

  factory IzinModel.fromMap(String id, Map<String, dynamic> data) {
    return IzinModel(
      id: id,
      userId: data['user_id'] ?? '',
      nama: data['nama'] ?? '',
      tanggal: data['tanggal'] ?? '',
      jenis: data['jenis'] ?? 'Izin',
      alasan: data['alasan'] ?? '',
      lampiran: data['lampiran'],
      status: data['status'] ?? 'Menunggu',
      keterangan: data['keterangan'] ?? '',
    );
  }
}