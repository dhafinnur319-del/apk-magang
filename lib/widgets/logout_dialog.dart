import 'package:flutter/material.dart';

class LogoutDialog {
  // ---------- Palet warna (sama dengan design system BAPPEDA) ----------
  static const Color _primaryBrown = Color(0xFF5A3218);
  static const Color _textPrimary = Color(0xFF302015);
  static const Color _textSecondary = Color(0xFF786B60);
  static const Color _borderColor = Color(0xFFE2D6C8);
  static const Color _danger = Color(0xFFB94036);

  /// Tampilkan dialog konfirmasi logout.
  /// Return `true` jika user menekan "Keluar", `false` jika tidak.
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ---------- Icon ----------
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0E5D7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.logout,
                      color: _primaryBrown,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ---------- Title ----------
                  const Text(
                    'Konfirmasi Keluar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ---------- Description ----------
                  const Text(
                    'Apakah Anda yakin ingin keluar dari akun ini?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: _textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ---------- Buttons ----------
                  Row(
                    children: [
                      // ---- Batal ----
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _primaryBrown,
                              backgroundColor: Colors.white,
                              side: const BorderSide(
                                color: _primaryBrown,
                                width: 1.3,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Batal',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // ---- Keluar ----
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _danger,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Keluar',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    return result ?? false;
  }
}