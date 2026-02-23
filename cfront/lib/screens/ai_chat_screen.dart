import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  // 🔹 Адрес бэкенда:
  // Если ты запускаешь на Windows → localhost
  // Эмулятор Android → 10.0.2.2
  // Физический телефон → IP твоего ПК в Wi-Fi (например 192.168.0.105)
  final String backendUrl = 'http://172.20.10.2:8080/api/ai/chat';

  // 🔹 Отправка сообщения пользователем
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _controller.clear();
      _isLoading = true;
    });

    try {
      final reply = await _getAiReplyFromBackend(text);
      setState(() {
        _messages.add(_ChatMessage(text: reply, isUser: false));
      });
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(
          text: 'Ошибка: не удалось получить ответ от сервера.',
          isUser: false,
        ));
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 🔹 Запрос к твоему Java Spring серверу
  Future<String> _getAiReplyFromBackend(String message) async {
    try {
      final uri = Uri.parse(backendUrl);
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}), // должен совпадать с ChatRequest.message
      );

      if (res.statusCode == 200) {
        final jsonBody = jsonDecode(res.body);
        return (jsonBody['reply'] as String?) ?? 'Пустой ответ от ИИ';
      } else {
        return 'Ошибка ${res.statusCode}: ${res.reasonPhrase}';
      }
    } catch (e) {
      return 'Ошибка соединения с сервером';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 🔹 Отрисовка сообщения в чате
  Widget _buildMessageTile(_ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: msg.isUser
              ? AppColors.mediumBrown
              : AppColors.beige.withOpacity(0.9),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: msg.isUser ? AppColors.beige : AppColors.darkBrown,
            fontFamily: 'Montserrat',
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  // 🔹 Основной UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Чат с ИИ', style: TextStyle(color: AppColors.beige)),
        backgroundColor: AppColors.mediumBrown,
        iconTheme: const IconThemeData(color: AppColors.beige),
      ),
      backgroundColor: AppColors.lightBrown.withOpacity(0.12),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageTile(msg);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Введите сообщение...',
                      filled: true,
                      fillColor: AppColors.beige.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.mediumBrown),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 🔹 Модель сообщения (локальная)
class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}
