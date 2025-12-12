// lib/services/api_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/news_model.dart';
import '../models/comment_model.dart';

class ApiService {
static String get host {
  try {
    if (const bool.fromEnvironment('dart.library.io', defaultValue: false)) {
      // Platform dari dart:io hanya jalan di Mobile/Desktop
      if (Platform.isAndroid) return '10.218.85.36';
      // if (Platform.isAndroid) return '10.0.2.2';
      if (Platform.isIOS) return 'localhost';
    }
  } catch (_) {}

  // Flutter Web 
  return 'localhost'; 
}


  // BASE URL API
  static String get baseUrl => 'http://$host:8000/api';

  // PRINT DEBUG
  static void _log(String message) {
    print('[ApiService] $message');
  }

  //  BERITA
  static Future<List<Berita>> getAllNews(String token) async {
  try {
    final url = Uri.parse('$baseUrl/news');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      _log('Response body in getAllNews: ${response.body}');
      
      dynamic dataToProcess = json;
      if (json is Map && json.containsKey('data')) {
        dataToProcess = json['data'];
      }
      
      if (dataToProcess is List) {
        return dataToProcess.map((e) => Berita.fromJson(e)).toList();
      } else {
        _log('Failed: Expected List or Map with "data" key, got unexpected type: ${dataToProcess.runtimeType}');
      }
      
    } else {
      _log('Failed: ${response.statusCode}');
      _log('Response body: ${response.body}');
    }
  } catch (e) {
    _log('Error getAllNews: $e');
  }
  return [];
}


  static Future<Berita?> getNewsDetail(int id, String token) async {
  try {
    final url = Uri.parse('$baseUrl/news/$id');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return Berita.fromJson(data);
    }
  } catch (e) {
    _log('Error getNewsDetail: $e');
  }
  return null;
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

    // Header
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    // Field
    request.fields.addAll({
      'title': title,
      'content': content,
      'category': category,
    });

    // FILE UPLOAD dari BYTES 
    request.files.add(
      http.MultipartFile.fromBytes(
        'gambar',
        imageBytes,
        filename: imageFilename,
      ),
    );

    _log('Mengirim berita ke $url ...');

    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200 || response.statusCode == 201) {
      _log('Berita berhasil dibuat!');
      return true;
    } else {
      _log('Gagal buat berita: ${response.statusCode}');
      _log(response.body);
      return false;
    }
  } catch (e) {
    _log('Error createNews: $e');
    return false;
  }
}


  // KOMENTAR
  static Future<List<Comment>> getComments(int newsId, String token) async {
  try {
    final url = Uri.parse('$baseUrl/news/$newsId/comments');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body)['comments'] ?? [];
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
      final url = Uri.parse('$baseUrl/news/$newsId/comments');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'content': content}),
      );

      final success = response.statusCode == 201 || response.statusCode == 200;
      _log(success ? 'Komentar berhasil ditambah' : 'Gagal komentar: ${response.statusCode}');
      return success;
    } catch (e) {
      _log('Error addComment: $e');
      return false;
    }
  }

  // AUTH (LOGIN & REGISTER)
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://$host:8000/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'token': data['token'], 'user': data['user']};
      }
      return {'success': false, 'message': 'Email atau password salah'};
    } catch (e) {
      return {'success': false, 'message': 'Tidak bisa terhubung ke server'};
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://$host:8000/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,

        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return await login(email, password); // otomatis login
      }
      return {'success': false, 'message': 'Registrasi gagal'};
    } catch (e) {
      return {'success': false, 'message': 'Tidak bisa terhubung ke server'};
    }
  }
}