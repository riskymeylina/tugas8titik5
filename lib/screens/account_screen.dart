// lib/screens/account_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/logout_widget.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Akun Saya', style: TextStyle(color: Colors.black87)),
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Profil User ===
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 34,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.username ?? 'Nama Pengguna',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            auth.email ?? 'user@news.com',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // === Pengaturan ===
            const Text(
              'Pengaturan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: LogoutListTile(
                leading: const Icon(Icons.logout_outlined, color: Colors.red),
                title: 'Logout',
                subtitle: 'Keluar dari akun Anda dan kembali ke halaman login',
              ),
            ),

            const SizedBox(height: 12),

            // Bisa tambah opsi lain nanti
            // Card(
            //   child: ListTile(
            //     leading: Icon(Icons.dark_mode),
            //     title: Text('Mode Gelap'),
            //     trailing: Switch(value: false, onChanged: (_) {}),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}