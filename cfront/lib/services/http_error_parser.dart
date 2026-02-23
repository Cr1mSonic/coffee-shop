import 'dart:convert';

class HttpErrorParser {
  static String messageFromBody(String body, {String fallback = 'Ошибка запроса'}) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
        final error = decoded['error'];
        if (error is String && error.trim().isNotEmpty) {
          return error;
        }
      }
    } catch (_) {
      // ignore parse errors and return fallback
    }
    return fallback;
  }
}
