import 'dart:convert';
import 'package:http/http.dart' as http;
import 'http_error_parser.dart';

class ApiService {
  static const String baseUrl = 'http://172.20.10.2:8080/api/auth';

  /// 🟢 Регистрация
  static Future<Map<String, dynamic>> register(
    String email,
    String password,
  ) async {
    return _post('$baseUrl/register', {'email': email, 'password': password});
  }

  /// 🟢 Логин
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    return _post('$baseUrl/login', {'email': email, 'password': password});
  }

  /// 🔄 Восстановление пароля
  static Future<Map<String, dynamic>> forgotPassword(
    String email,
    String newPassword,
  ) async {
    return _post('$baseUrl/forgot-password', {
      'email': email,
      'password': newPassword,
    });
  }

  static Future<Map<String, dynamic>> _post(
    String url,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    return {
      'success': false,
      'message': HttpErrorParser.messageFromBody(
        response.body,
        fallback: 'Ошибка запроса (${response.statusCode})',
      ),
    };
  }
}
