import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/news_model.dart';
import '../models/comment_model.dart';

class ApiService {
  static String get host {
    if (kIsWeb) return 'localhost';
    try {
      if (Platform.isAndroid) return '10.0.2.2';
      if (Platform.isIOS) return 'localhost';
    } catch (_) {}
    return 'localhost';
  }

  static String get baseUrl => 'http://$host:8000/api';

  static void _log(String message) {
    debugPrint('[ApiService] $message');
  }

  static Map<String, String> _getHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      // Jangan tambahkan Content-Type application/json di sini jika menggunakan Multipart
    };
  }

  // ======================
  // BERITA (CRUD)
  // ======================

  static Future<List<Berita>> getAllNews(String token) async {
    try {
      final url = Uri.parse('$baseUrl/news');
      final response = await http.get(url, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List data = jsonResponse is Map ? (jsonResponse['data'] ?? []) : jsonResponse;
        return data.map((e) => Berita.fromJson(e)).toList();
      }
    } catch (e) {
      _log('Error getAllNews: $e');
    }
    return [];
  }

  static Future<bool> createNews({
    required String token,
    required String title,
    required String content,
    required String category,
    required Uint8List imageBytes,
    required String imageFilename,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/news');
      var request = http.MultipartRequest('POST', url);
      
      request.headers.addAll(_getHeaders(token));

      request.fields['title'] = title;
      request.fields['content'] = content;
      request.fields['category'] = category;

      request.files.add(
        http.MultipartFile.fromBytes(
          'gambar',
          imageBytes,
          filename: imageFilename,
        ),
      );

      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed);
      
      _log('Create News Status: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      _log('Error createNews: $e');
      return false;
    }
  }

  static Future<bool> updateNews({
    required int id,
    required String judul,
    required String isi,
    required String kategori,
    required String token,
    Uint8List? imageBytes,
    String? imageFilename,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/news/$id');
      
      // Laravel Multipart seringkali gagal jika menggunakan PUT murni, 
      // gunakan POST dengan field _method = PUT.
      var request = http.MultipartRequest('POST', url);
      
      request.headers.addAll(_getHeaders(token));

      request.fields['_method'] = 'PUT'; // Method Spoofing PENTING
      request.fields['title'] = judul;
      request.fields['content'] = isi;
      request.fields['category'] = kategori;

      if (imageBytes != null && imageFilename != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'gambar', 
            imageBytes,
            filename: imageFilename,
          ),
        );
      }

      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed);
      
      _log('Update News Status: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      _log('Error updateNews: $e');
      return false;
    }
  }

  static Future<bool> deleteNews(int id, String token) async {
    try {
      final url = Uri.parse('$baseUrl/news/$id');
      final response = await http.delete(url, headers: _getHeaders(token));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      _log('Error deleteNews: $e');
      return false;
    }
  }

  // ======================
  // KOMENTAR (CRUD)
  // ======================

  static Future<List<Comment>> getComments(int newsId, String token) async {
    try {
      final url = Uri.parse('$baseUrl/comments/news/$newsId');
      final response = await http.get(url, headers: _getHeaders(token));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List list = jsonResponse is Map 
            ? (jsonResponse['comments'] ?? jsonResponse['data'] ?? []) 
            : jsonResponse;
        return list.map((e) => Comment.fromJson(e)).toList();
      }
    } catch (e) {
      _log('Error getComments: $e');
    }
    return [];
  }

  static Future<bool> addComment({
    required int newsId,
    required String content,
    required String token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/comments');
      final response = await http.post(
        url,
        headers: {
          ..._getHeaders(token),
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'body': content, 'news_id': newsId}), 
      );
      _log('Add Comment Status: ${response.statusCode} - ${response.body}');
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      _log('Error addComment: $e');
      return false;
    }
  }

  static Future<bool> updateComment({
    required int commentId,
    required String content,
    required String token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/comments/$commentId');
      final response = await http.put(
        url,
        headers: {
          ..._getHeaders(token),
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'body': content}), 
      );

      _log('Update Comment Status: ${response.statusCode}');
      if (response.statusCode == 422) _log('Validation Error: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      _log('Error updateComment: $e');
      return false;
    }
  }

  static Future<bool> deleteComment(int commentId, String token) async {
    try {
      final url = Uri.parse('$baseUrl/comments/$commentId');
      final response = await http.delete(url, headers: _getHeaders(token));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      _log('Error deleteComment: $e');
      return false;
    }
  }

  // ======================
  // AUTHENTICATION
  // ======================

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'token': data['token'], 'user': data['user']};
      }
      return {'success': false, 'message': data['message'] ?? 'Email atau password salah'};
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return await login(email, password);
      }

      final data = jsonDecode(response.body);
      return {'success': false, 'message': data['message'] ?? 'Registrasi gagal'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan sistem'};
    }
  }
}