// lib/providers/news_provider.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/news_model.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class NewsProvider extends ChangeNotifier {
  List<Berita> _news = [];
  bool _isLoading = false;

  List<Berita> get news => _news;
  bool get isLoading => _isLoading;

  // ========================================================
  // LOAD NEWS — HARUS KIRIM TOKEN SEKARANG
  // ========================================================
  Future<void> loadNews(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;

      // FIX 1: Check if token is not null before calling API
      if (token != null) {
        _news = await ApiService.getAllNews(token);
      } else {
        print("Error loadNews: Token is null, skipping API call.");
      }
    } catch (e) {
      print("Error loadNews: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // ========================================================
  // CREATE NEWS → LALU REFRESH DAFTAR BERITA
  // ========================================================
  Future<bool> addNewsAndRefresh({
    required String title,
    required String content,
    required String category,
    required Uint8List imageBytes,
    required String imageFilename,
    required String token,
    required BuildContext context,
  }) async {
    final success = await ApiService.createNews(
      token: token,
      title: title,
      content: content,
      category: category,
      imageBytes: imageBytes,
      imageFilename: imageFilename,
    );

    if (success) {
      await loadNews(context); // Refresh data
    }

    return success;
  }
}