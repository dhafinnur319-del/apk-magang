import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'peserta/dashboard_peserta.dart';
import 'admin/dashboard_admin.dart';

// ============================================================
// Palet warna — SIMAGANG BAPPEDA JAWA TENGAH
// ============================================================
class _Palette {
  static const brownPrimary = Color(0xFF633815);
  static const brownDark = Color(0xFF4A2815);
  static const brownMedium = Color(0xFF80502C);
  static const brownLight = Color(0xFFB88A5D);
  static const cream = Color(0xFFF5EFE6);
  static const ivory = Color(0xFFFCFAF6);
  static const softBeige = Color(0xFFE9DDCE);
  static const border = Color(0xFFE4D6C5);
  static const textPrimary = Color(0xFF4A2B19);
  static const textSecondary = Color(0xFF806F61);
  static const white = Color(0xFFFFFFFF);
}

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
    return Scaffold(
      backgroundColor: _Palette.ivory,
      body: Stack(
        children: [
          // ===================================================
          // Layer 1: Dekorasi kurva top-left
          // ===================================================
          Positioned(
            top: -80,
            left: -80,
            child: CustomPaint(
              size: const Size(260, 260),
              painter: _TopLeftCurvePainter(
                color: _Palette.brownPrimary.withValues(alpha: 0.35),
              ),
            ),
          ),

          // ===================================================
          // Layer 2: Dekorasi kurva bottom-right
          // ===================================================
          Positioned(
            bottom: -60,
            right: -60,
            child: CustomPaint(
              size: const Size(300, 300),
              painter: _BottomRightCurvePainter(
                color: _Palette.brownPrimary.withValues(alpha: 0.15),
              ),
            ),
          ),

          // ===================================================
          // Layer 3: Konten
          // ===================================================
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ===== Logo toga SIMAGANG =====
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Positioned(
                          top: 0,
                          child: Icon(
                            Icons.school,
                            size: 84,
                            color: _Palette.brownPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ===== SIMAGANG =====
                  const Text(
                    'SIMAGANG',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                      color: _Palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ===== BAPPEDA JAWA TENGAH =====
                  const Text(
                    'BAPENDA PROVINSI JAWA TENGAH',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 4,
                      color: _Palette.brownPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ===== Ornamental divider =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 1.2,
                        color: _Palette.brownLight,
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.local_florist,
                        size: 14,
                        color: _Palette.brownPrimary,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 50,
                        height: 1.2,
                        color: _Palette.brownLight,
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),

                  // ===== Loading indicator =====
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      color: _Palette.brownPrimary,
                      strokeWidth: 2.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CustomPainter: kurva top-left
// ============================================================
class _TopLeftCurvePainter extends CustomPainter {
  final Color color;
  _TopLeftCurvePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width * 0.6, 0);
    path.cubicTo(
      size.width * 0.4, size.height * 0.3,
      size.width * 0.3, size.height * 0.6,
      0, size.height * 0.8,
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TopLeftCurvePainter oldDelegate) =>
      oldDelegate.color != color;
}

// ============================================================
// CustomPainter: kurva bottom-right
// ============================================================
class _BottomRightCurvePainter extends CustomPainter {
  final Color color;
  _BottomRightCurvePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width, size.height);
    path.lineTo(size.width * 0.4, size.height);
    path.cubicTo(
      size.width * 0.6, size.height * 0.7,
      size.width * 0.7, size.height * 0.4,
      size.width, size.height * 0.2,
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BottomRightCurvePainter oldDelegate) =>
      oldDelegate.color != color;
}