import 'package:flutter/material.dart';
import 'dart:io';
import '../models/news_model.dart';
import '../screens/profile_screen.dart';

class NewsContentSheet extends StatelessWidget {
  final Berita berita;
  final ScrollController scrollController;

  const NewsContentSheet({
    super.key,
    required this.berita,
    required this.scrollController,
  });
  print('NewsContentSheet initialized with berita: ${berita}');

  // Helper untuk gambar
  Widget _buildImage(String url) {
    print('Loading image from URL: $url');
    const double imgHeight = 200;

    if (url.startsWith('http')) {
      return Image.network(
        url,
        width: double.infinity,
        height: imgHeight,
        fit: BoxFit.cover,
      );
    }

    try {
      final f = File(url);
      return Image.file(
        f,
        width: double.infinity,
        height: imgHeight,
        fit: BoxFit.cover,
      );
    } catch (_) {
      return Container(
        height: imgHeight,
        color: Colors.grey[200],
        child: const Icon(Icons.photo, size: 60),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[350],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Posted by
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        NetworkImage("https://via.placeholder.com/150"),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    berita.penulis ?? 'Anonim',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Judul
            Text(
              berita.judul,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),

            // Kategori + waktu
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    berita.kategori,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  berita.waktu.split(' ').first,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Gambar
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildImage(berita.gambarUrl),
            ),
            const SizedBox(height: 16),

            // Deskripsi full
            Text(
              berita.deskripsiLengkap,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
