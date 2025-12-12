// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // <-- UNTUK kIsWeb
import 'dart:io' show Platform;

class AuthProvider extends ChangeNotifier {
  // BASE URL 
  static String get baseUrl {
    if (kIsWeb) {
      // Untuk Flutter Web
      return 'http://localhost:8000/api';
    }

    if (Platform.isAndroid) {
      // Android Emulator
      // return 'http://10.0.2.2:8000/api';
      return 'http://10.218.85.36:8000/api';
    }

    // iOS / Desktop
    return 'http://localhost:8000/api';
  }


  String? _token;
  int? _userId;
  String? _username;
  String? _email;
  bool _isLoggedIn = false;

  bool get isAuthenticated => _token != null;
  String? get token => _token;
  int? get userId => _userId;
  String? get username => _username;
  String? get email => _email;
  bool get isLoggedIn => _isLoggedIn;

  AuthProvider() {
    _loadFromStorage();
  }

  // LOAD DATA DARI STORAGE
  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      _userId = prefs.getInt('user_id');
      _username = prefs.getString('username');
      _email = prefs.getString('email');
      _isLoggedIn = _token != null;

      notifyListeners();
    } catch (e) {
      print("Error loading storage: $e");
    }
  }

  // SIMPAN USER
  Future<void> _saveUser(
      String token, int userId, String name, String email) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('token', token);
    await prefs.setInt('user_id', userId);
    await prefs.setString('username', name);
    await prefs.setString('email', email);

    _token = token;
    _userId = userId;
    _username = name;
    _email = email;
    _isLoggedIn = true;

    notifyListeners();
  }

  // LOGIN USER
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        await _saveUser(
          data['token'],
          data['user']['id'],
          data['user']['name'],
          data['user']['email'],
        );

        return "success";
      }

      return jsonDecode(response.body)['message'] ?? "Login gagal";
    } catch (e) {
      return "Tidak bisa terhubung ke server: $e";
    }
  }

  
  // REGISTER USER
  Future<String> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': username,
          'email': email,
          'password': password,
          'password_confirmation': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Auto login setelah register
        return await loginUser(email: email, password: password);
      }

      return jsonDecode(response.body)['message'] ?? "Registrasi gagal";
    } catch (e) {
      return "Tidak bisa terhubung ke server";
    }
  }

  
  // LOGOUT USER
  Future<void> logout() async {
    try {
      if (_token != null) {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Authorization': 'Bearer $_token',
          },
        );
      }
    } catch (_) {}

    // CLEAR LOCAL DATA
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _token = null;
    _userId = null;
    _username = null;
    _email = null;
    _isLoggedIn = false;

    notifyListeners();
  }
}
