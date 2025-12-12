// lib/widgets/news_content_sheet.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/news_model.dart';
import '../services/api_service.dart';

class NewsContentSheet extends StatelessWidget {
  final Berita berita;
  final ScrollController? scrollController;

  const NewsContentSheet({
    super.key,
    required this.berita,
    required this.scrollController,
  });

  static const double _imageHeight = 250.0;

  // --- FUNGSI GAMBAR FINAL ---
  Widget _buildDetailImage(String url) {
    return Image.network(
      url,
      height: _imageHeight,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, e, stack) => Container(
        height: _imageHeight,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.broken_image_outlined, color: Colors.grey),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl = (berita.gambarUrl != null && berita.gambarUrl!.isNotEmpty)
        ? '${berita.gambarUrl}'
        : '';
        print('Debug: Image URL - $imageUrl');

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Center(
              child: Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[350],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),

          // Konten Utama
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),

                  // Posted By
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.red,
                        child: Text(
                          'N',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('posted by ', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      Text(
                        berita.penulis ?? 'Anonim',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Judul
                  Text(
                    berita.judul,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Waktu + Kategori
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        berita.waktu,
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          berita.kategori,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Quote
                  if (berita.quote != null && berita.quote!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: const Border(left: BorderSide(color: Colors.red, width: 4)),
                      ),
                      child: Text(
                        '"${berita.quote!}"',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Gambar
                  if (imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildDetailImage(imageUrl),
                    ),

                  const SizedBox(height: 16),

                  // Deskripsi (preview)
                  Text(
                    berita.deskripsiLengkap,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                    maxLines: 5,
                    overflow: TextOverflow.fade,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
