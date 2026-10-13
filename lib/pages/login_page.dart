import 'package:flutter/material.dart';
import '../services/auth_service.dart';
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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  // ===== Pesan error (ditampilkan di atas tombol LOGIN) =====
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Email dan password wajib diisi!');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final user = await AuthService().login(email, password);
    if (!mounted) return;
    setState(() => _loading = false);

    if (user == null) {
      setState(() => _errorMessage = 'Email atau password salah!');
      return;
    }

    if (user.role == 'admin' || user.role == 'pembimbing') {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const DashboardAdmin()));
    } else {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const DashboardPeserta()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    // Tinggi foto background bagian atas (bukan full screen)
    final double photoHeight = size.height * 0.55;

    return Scaffold(
      backgroundColor: _Palette.ivory,
      body: Stack(
        children: [
          // ===================================================
          // Layer 1: FOTO BACKGROUND (HANYA BAGIAN ATAS)
          // ===================================================
          // Ganti gambar di: assets/images/login_background.png
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: photoHeight,
            child: Image.asset(
              'assets/images/login_background.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: _Palette.ivory);
              },
            ),
          ),

          // ===================================================
          // Layer 2: Fade ivory di SELURUH area foto
          // - Tipis di atas (foto masih terlihat)
          // - Semakin tebal ke bawah
          // - Sangat tebal di 120px terakhir (menyatu ke background)
          // ===================================================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: photoHeight,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _Palette.ivory.withValues(alpha: 0.10),
                    _Palette.ivory.withValues(alpha: 0.15),
                    _Palette.ivory.withValues(alpha: 0.30),
                    _Palette.ivory.withValues(alpha: 0.55),
                    _Palette.ivory.withValues(alpha: 0.85),
                    _Palette.ivory,
                  ],
                  stops: const [
                    0.0,
                    0.35,
                    0.60,
                    0.80,
                    0.92,
                    1.0,
                  ],
                ),
              ),
            ),
          ),

          // ===================================================
          // Layer 2b: Overlay ivory halus di SELURUH area foto
          // ===================================================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: photoHeight - 120,
            child: Container(
              color: _Palette.ivory.withValues(alpha: 0.15),
            ),
          ),

          // ===================================================
          // Layer 3: Kurva dekorasi top-left
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
          // Layer 4: Kurva dekorasi bottom-right
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
          // Layer 5: Konten
          // ===================================================
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmall ? 28 : 50,
                    vertical: 20,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: (constraints.maxHeight - 40)
                          .clamp(0.0, double.infinity),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ===== Top row =====
                            const _TopBar(),

                            SizedBox(height: isSmall ? 20 : 32),

                            // ===== Logo & Branding =====
                            _Branding(isSmall: isSmall),

                            SizedBox(height: isSmall ? 24 : 36),

                            // ===== Email field =====
                            _InputField(
                              controller: _emailController,
                              hint: 'Email',
                              icon: Icons.mail_outline,
                              keyboardType: TextInputType.emailAddress,
                              height: isSmall ? 64 : 76,
                            ),

                            SizedBox(height: isSmall ? 16 : 22),

                            // ===== Password field =====
                            _InputField(
                              controller: _passwordController,
                              hint: 'Password',
                              icon: Icons.lock_outline,
                              obscure: _obscurePassword,
                              height: isSmall ? 64 : 76,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: _Palette.textSecondary,
                                  size: 22,
                                ),
                                onPressed: () => setState(() =>
                                    _obscurePassword = !_obscurePassword),
                              ),
                            ),

                            // ===== Pesan error (jika ada) =====
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 14),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFFB94036),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],

                            SizedBox(height: isSmall ? 16 : 22),

                            // ===== Tombol LOGIN =====
                            _LoginButton(
                              loading: _loading,
                              height: isSmall ? 68 : 82,
                              onTap: _loading ? null : _login,
                            ),

                            SizedBox(height: isSmall ? 32 : 48),

                            // ===== Bottom branding =====
                            const _BottomBranding(),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(22, -30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Melayani\nDengan Hati',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              height: 1.35,
              color: _Palette.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.local_florist_outlined,
            color: _Palette.brownPrimary,
            size: 22,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Branding tengah — Logo toga + SIMAGANG + BAPPEDA
// ============================================================
class _Branding extends StatelessWidget {
  final bool isSmall;
  const _Branding({required this.isSmall});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ===== Logo toga SIMAGANG =====
        SizedBox(
          width: isSmall ? 80 : 100,
          height: isSmall ? 80 : 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 0,
                child: Icon(
                  Icons.school,
                  size: isSmall ? 56 : 70,
                  color: _Palette.brownPrimary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isSmall ? 6 : 10),

        // ===== SIMAGANG =====
        SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              'SIMAGANG',
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                fontSize: isSmall ? 36 : 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
                color: _Palette.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),

        // ===== BAPENDA PROV JAWA TENGAH =====
        SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              'BAPENDA PROV JAWA TENGAH',
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                fontSize: isSmall ? 12 : 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 5,
                color: _Palette.brownPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ===== Ornamental divider =====
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 50, height: 1.2, color: _Palette.brownLight),
            const SizedBox(width: 8),
            Icon(
              Icons.local_florist,
              size: 14,
              color: _Palette.brownPrimary,
            ),
            const SizedBox(width: 8),
            Container(width: 50, height: 1.2, color: _Palette.brownLight),
          ],
        ),
      ],
    );
  }
}

// ============================================================
// Input field
// ============================================================
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final double height;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.height,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: _Palette.ivory,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _Palette.border, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            width: height - 22,
            height: height - 22,
            decoration: BoxDecoration(
              color: _Palette.softBeige,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: _Palette.brownPrimary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboardType,
              style: const TextStyle(
                fontSize: 16,
                color: _Palette.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: _Palette.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
              ),
            ),
          ),
          if (suffix != null) ...[
            suffix!,
            const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// Tombol LOGIN
// ============================================================
class _LoginButton extends StatelessWidget {
  final bool loading;
  final double height;
  final VoidCallback? onTap;

  const _LoginButton({
    required this.loading,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _Palette.brownPrimary,
      borderRadius: BorderRadius.circular(55),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(55),
        splashColor: _Palette.brownLight.withValues(alpha: 0.3),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(55),
            boxShadow: [
              BoxShadow(
                color: _Palette.brownPrimary.withValues(alpha: 0.22),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      color: _Palette.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'LOGIN',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: _Palette.white,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(width: 14),
                      Icon(
                        Icons.arrow_forward,
                        color: _Palette.white,
                        size: 22,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Bottom branding
// ============================================================
class _BottomBranding extends StatelessWidget {
  const _BottomBranding();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SizedBox(height: 6),
          SizedBox(
            width: 40,
            child: Divider(
              color: _Palette.brownPrimary,
              height: 1,
              thickness: 1.2,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Kolaborasi Perencanaan\nuntuk Jawa Tengah Maju.',
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: _Palette.textSecondary,
              height: 1.5,
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