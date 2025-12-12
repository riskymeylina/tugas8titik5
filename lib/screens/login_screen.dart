// lib/screens/login_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  bool loading = false;
  bool hidePass = true;

  @override
  void dispose() {
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (emailC.text.trim().isEmpty || passC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan password harus diisi!")),
      );
      return;
    }

    setState(() => loading = true);

    final auth = context.read<AuthProvider>();
    final result = await auth.loginUser(
      email: emailC.text.trim(),
      password: passC.text.trim(),
    );

    setState(() => loading = false);

    if (result == "success") {
      // Login berhasil → langsung ke Home dan hapus semua stack
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } else {
      // Tampilkan error dari server
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          SizedBox.expand(
            child: Image.network(
              "https://images.unsplash.com/photo-1520607162513-77705c0f0d4a?w=1500&auto=format&fit=crop&q=80",
              fit: BoxFit.cover,
            ),
          ),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.6),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Login Card dengan Glassmorphism
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.30),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                    border: Border.all(color: Colors.white.withOpacity(0.35)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Masuk ke NewsScope",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Ikuti berita terbaru setiap hari.",
                        style: TextStyle(fontSize: 15, color: Colors.white70),
                      ),
                      const SizedBox(height: 26),

                      _label("Email"),
                      const SizedBox(height: 6),
                      _input(emailC),

                      const SizedBox(height: 18),

                      _label("Password"),
                      const SizedBox(height: 6),
                      _input(
                        passC,
                        isPassword: true,
                        hidePass: hidePass,
                        toggle: () => setState(() => hidePass = !hidePass),
                      ),

                      const SizedBox(height: 26),

                      // Tombol Login
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: loading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRed,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          child: loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "Masuk",
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Link ke Register
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/register'),
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(fontSize: 15, color: Colors.white),
                              children: [
                                TextSpan(text: "Belum punya akun? "),
                                TextSpan(
                                  text: "Daftar sekarang",
                                  style: TextStyle(
                                    color: AppColors.primaryRed,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String t) => Text(
        t,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      );

  Widget _input(
    TextEditingController c, {
    bool isPassword = false,
    bool hidePass = true,
    VoidCallback? toggle,
  }) {
    return TextField(
      controller: c,
      obscureText: isPassword ? hidePass : false,
      keyboardType: isPassword ? TextInputType.visiblePassword : TextInputType.emailAddress,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  hidePass ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black87,
                ),
                onPressed: toggle,
              )
            : null,
      ),
    );
  }
}