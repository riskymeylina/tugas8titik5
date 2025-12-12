// lib/models/news_model.dart
import 'dart:io';
class Berita {
  final int id;
  final String judul;
  final String deskripsiLengkap;
  final String gambarUrl;
  final String kategori;
  final String waktu;
  final String? quote;
  final String? penulis;

  Berita({
    required this.id,
    required this.judul,
    required this.deskripsiLengkap,
    required this.gambarUrl,
    required this.kategori,
    required this.waktu,
    this.quote,
    this.penulis,
  });
  static String get host {
  try {
    if (const bool.fromEnvironment('dart.library.io', defaultValue: false)) {
      // Platform dari dart:io hanya jalan di Mobile/Desktop
      if (Platform.isAndroid) return '10.0.2.2';
      if (Platform.isIOS) return 'localhost';
    }
  } catch (_) {}

  // Flutter Web / fallback
  return 'localhost'; // ganti ke IP server jika backend bukan lokal
}


  factory Berita.fromJson(Map<String, dynamic> json) {
    return Berita(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      judul: json['title'] ?? 'Tanpa Judul',
      deskripsiLengkap: json['content'] ?? json['deskripsi_lengkap'] ?? '',
      gambarUrl: json['image'] != null
          ? 'http://$host:8000/api/image/${json['image']}'
          : 'https://via.placeholder.com/300',
      kategori: json['category'] ?? 'Umum',
      waktu: json['created_at_human'] ?? 'Baru saja',
      quote: json['quote'],
      penulis: json['author']?['name'] ?? json['penulis'] ?? 'Anonim',
    );
  }
}