// lib/providers/news_provider.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/news_model.dart';
import '../services/api_service.dart';

class NewsProvider extends ChangeNotifier {
  List<Berita> _news = [];
  bool _isLoading = false;

  List<Berita> get news => _news;
  bool get isLoading => _isLoading;

  // LOAD NEWS
  // ========================================================
  Future<void> loadNews(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetchedNews = await ApiService.getAllNews(token);
      _news = fetchedNews;
    } catch (e) {
      debugPrint('Error loadNews in NewsProvider: $e');
      // Opsional: bisa tambah _news = [] jika ingin kosongkan saat error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========================================================
  // CREATE NEWS + REFRESH LIST
  // ========================================================
  Future<bool> addNewsAndRefresh({
    required String title,
    required String content,
    required String category,
    required Uint8List imageBytes,
    required String imageFilename,
    required String token,
  }) async {
    try {
      final success = await ApiService.createNews(
        token: token,
        title: title,
        content: content,
        category: category,
        imageBytes: imageBytes,
        imageFilename: imageFilename,
      );

      if (success) {
        await loadNews(token); // Refresh full list dari server
      }
      return success;
    } catch (e) {
      debugPrint('Error addNews in NewsProvider: $e');
      return false;
    }
  }

  // ========================================================
  // DELETE NEWS + OPTIMISTIC UPDATE
  // ========================================================
  Future<bool> deleteNewsAndRefresh({
    required int newsId,
    required String token,
  }) async {
    // Optimistic update: hapus dulu dari UI (cepat terasa responsif)
    final originalLength = _news.length;
    _news.removeWhere((item) => item.id == newsId);
    notifyListeners();

    try {
      final success = await ApiService.deleteNews(newsId, token);

      if (!success) {
        // Jika gagal di server, kembalikan data (rollback)
        await loadNews(token);
        debugPrint('Delete failed, rolled back local data.');
      } else {
        debugPrint('Berita ID $newsId berhasil dihapus dari database dan UI.');
      }
      return success;
    } catch (e) {
      // Rollback jika error
      await loadNews(token);
      debugPrint('Error deleteNews in NewsProvider: $e');
      return false;
    }
  }
}