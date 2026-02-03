import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ⚠️ ВАЖНО: укажи свой IP, если тестируешь на телефоне
  static const String baseUrl = 'http://172.20.10.2:8080/api/auth';

  // 🟢 Регистрация
  static Future<Map<String, dynamic>> registerUser(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    return {
      'status': response.statusCode,
      'body': jsonDecode(response.body),
    };
  }

  // 🟢 Логин
  static Future<Map<String, dynamic>> loginUser(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    return {
      'status': response.statusCode,
      'body': jsonDecode(response.body),
    };
  }
}
