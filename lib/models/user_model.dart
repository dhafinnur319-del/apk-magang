class UserModel {
  final String id;
  final String nama;
  final String username;
  final String email;
  final String role;
  final String noHp;
  final String gender; // <-- FIELD BARU

  UserModel({
    required this.id,
    required this.nama,
    required this.username,
    required this.email,
    required this.role,
    required this.noHp,
    required this.gender, // <-- TAMBAHAN
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      nama: data['nama'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'peserta',
      noHp: data['no_hp'] ?? '',
      gender: data['gender'] ?? '', // <-- TAMBAHAN
    );
  }

  // Helper untuk menampilkan gender dalam Bahasa Indonesia
  String get genderLabel {
    switch (gender.toLowerCase()) {
      case 'male':
        return 'Laki-laki';
      case 'female':
        return 'Perempuan';
      default:
        return '-';
    }
  }
}