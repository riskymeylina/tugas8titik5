import 'package:flutter/material.dart';
import '../storage_service.dart';
import '../app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'NewsScope',
      'subtitle': 'Portal berita terbaru, cepat, dan terpercaya.',
    },
    {
      'title': 'Update Harian',
      'subtitle': 'Tetap terhubung dengan informasi penting setiap hari.',
    },
    {
      'title': 'Akurat & Terpercaya',
      'subtitle': 'Baca berita dari sumber yang kredibel dan objektif.',
    },
  ];

  // Gambar utama onboarding (sama untuk semua halaman)
  final String _onboardingImage =
      'https://images.unsplash.com/photo-1504711434969-e33886168f5c?auto=format&fit=crop&w=1200&q=80';

  void _completeOnboarding() async {
    await StorageService.completeOnboarding();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Background dengan satu gambar untuk semua page
          Positioned.fill(
            child: Image.network(
              _onboardingImage,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) =>
                  progress == null
                      ? child
                      : Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        ),
              errorBuilder: (_, __, ___) =>
                  Container(color: Colors.grey.shade800),
            ),
          ),

          /// Overlay gelap biar teks terlihat
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.05),
                    Colors.black.withOpacity(0.65),
                  ],
                ),
              ),
            ),
          ),

          /// Konten Onboarding
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (_, i) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 120),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _pages[i]['title']!,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _pages[i]['subtitle']!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          /// Tombol Next + Mulai Membaca
          Positioned(
            bottom: 40,
            left: 28,
            right: 28,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        'Start Reading',
                        style: TextStyle(
                          color: AppColors.primaryRed,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.ease,
                      );
                    } else {
                      _completeOnboarding();
                    }
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: AppColors.primaryRed,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
