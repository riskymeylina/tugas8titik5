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
  final int? userId;

  Berita({
    required this.id,
    required this.judul,
    required this.deskripsiLengkap,
    required this.gambarUrl,
    required this.kategori,
    required this.waktu,
    this.quote,
    this.penulis,
    this.userId,
  });

  static String get host {
    try {
      if (const bool.fromEnvironment('dart.library.io', defaultValue: false)) {
        if (Platform.isAndroid) return '10.0.2.2';
        if (Platform.isIOS) return 'localhost';
      }
    } catch (_) {}
    return 'localhost';
  }

  factory Berita.fromJson(Map<String, dynamic> json) {
    String rawTime = json['created_at_human'] ?? json['created_at'] ?? '';
    String formattedTime = rawTime.isNotEmpty 
        ? rawTime 
        : formatRelativeTime(json['created_at']); // Gunakan method public

    return Berita(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      judul: json['title'] ?? 'Tanpa Judul',
      deskripsiLengkap: json['content'] ?? '',
      gambarUrl: json['image'] != null
          ? 'http://$host:8000/api/image/${json['image']}'
          : 'https://via.placeholder.com/300',
      kategori: json['category'] ?? 'Umum',
      waktu: formattedTime,
      quote: json['quote'],
      penulis: json['author']?['name'] ?? json['penulis'] ?? 'Anonim',
      userId: json['user_id'] ?? json['author']?['id'],
    );
  }

  // METHOD INI DIPINDAH JADI PUBLIC STATIC
  static String formatRelativeTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Baru saja';
    try {
      final DateTime date = DateTime.parse(dateString);
      final DateTime now = DateTime.now();
      final Duration diff = now.difference(date);

      if (diff.inDays >= 7) {
        return '${date.day}/${date.month}/${date.year}';
      } else if (diff.inDays > 0) {
        return diff.inDays == 1 ? 'Kemarin' : '${diff.inDays} hari lalu';
      } else if (diff.inHours > 0) {
        return '${diff.inHours} jam lalu';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes} menit lalu';
      } else {
        return 'Baru saja';
      }
    } catch (e) {
      return 'Baru saja';
    }
  }
}