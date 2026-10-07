class UserModel {
  final String id;
  final String nama;
  final String username;
  final String email;
  final String role;
  final String noHp;

  UserModel({
    required this.id,
    required this.nama,
    required this.username,
    required this.email,
    required this.role,
    required this.noHp,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      nama: data['nama'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'peserta',
      noHp: data['no_hp'] ?? '',
    );
  }
}
