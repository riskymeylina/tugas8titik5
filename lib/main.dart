import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_colors.dart';
import 'storage_service.dart';
import 'providers/auth_provider.dart';
import 'providers/news_provider.dart'; // <-- WAJIB IMPORT

import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_news_screen.dart';
import 'screens/news_detail_screen.dart';
import 'screens/account_screen.dart';

void main() {
  runApp(const NewsScopeApp());
}

class NewsScopeApp extends StatelessWidget {
  const NewsScopeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()), // <-- FIX DI SINI
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NewsScope',
        theme: AppTheme.light(),
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashScreen(),
          '/onboarding': (_) => const OnboardingScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const HomeScreen(),
          '/account': (_) => const AccountScreen(),
          '/add_news': (_) => const AddNewsScreen(),
          // Detail route tetap pakai push
        },
      ),
    );
  }
}
