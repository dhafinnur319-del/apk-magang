import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'peserta/dashboard_peserta.dart';
import 'admin/dashboard_admin.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    final user = await AuthService().getUserData();

    if (!mounted) return;
    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else if (user.role == 'admin' || user.role == 'pembimbing') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardAdmin()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPeserta()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 80, color: Colors.blue),
            SizedBox(height: 16),
            Text('SIMAGANG BAPENDA JATENG',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}