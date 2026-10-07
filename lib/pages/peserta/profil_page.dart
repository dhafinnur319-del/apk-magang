import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  UserModel? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await AuthService().getUserData();
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 60),
            ),
          ),
          const SizedBox(height: 24),
          _item('Nama', _user?.nama ?? '-'),
          _item('Username', _user?.username ?? '-'),
          _item('Email', _user?.email ?? '-'),
          _item('No. HP', _user?.noHp ?? '-'),
          _item('Role', _user?.role ?? '-'),
        ],
      ),
    );
  }

  Widget _item(String label, String value) {
    return Card(
      child: ListTile(
        title: Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
        subtitle: Text(value,
            style: const TextStyle(fontSize: 16, color: Colors.black)),
      ),
    );
  }
}