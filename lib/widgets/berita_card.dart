// lib/widgets/berita_card.dart
import 'package:flutter/material.dart';
import '../models/news_model.dart';
import '../app_colors.dart';

class BeritaCard extends StatelessWidget {
  final Berita berita;
  final VoidCallback onTap;

  const BeritaCard({super.key, required this.berita, required this.onTap});

  @override
  Widget build(BuildContext context) {
    print('Rendering BeritaCard for: ${berita.gambarUrl}');
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                berita.gambarUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 160,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(berita.kategori, style: TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                      const Spacer(),
                      Text(berita.waktu, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(berita.judul, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(berita.penulis ?? 'Anonim', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}