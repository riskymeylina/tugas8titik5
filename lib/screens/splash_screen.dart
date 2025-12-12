import 'package:flutter/material.dart';
import 'dart:async';
import '../storage_service.dart';
import '../app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(milliseconds: 2500), () async {
      if (!mounted) return;

      final onboardingDone = await StorageService.isOnboardingCompleted();
      final loggedIn = await StorageService.isLoggedIn();

      if (onboardingDone && loggedIn) {
        Navigator.pushReplacementNamed(context, '/home');
      } else if (onboardingDone) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryRed,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 6))],
              ),
              child: Center(
                child: Icon(Icons.article, size: 64, color: Colors.white),
              ),
            ),
            const SizedBox(height: 26),
            const Text(
              'NewsScope',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
          ],
        ),
      ),
    );
  }
}
