import 'dart:typed_data';
import 'dart:convert';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../theme.dart';
import 'home_screen.dart';
import '../services/coffee_service.dart';
import '../models/coffee_shop.dart';
import '../widgets/gradient_background.dart';
import '../widgets/fancy_app_bar.dart';

class Achievement {
  final String title;
  final String description;
  bool unlocked;

  Achievement({
    required this.title,
    required this.description,
    this.unlocked = false,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'unlocked': unlocked,
      };

  static Achievement fromJson(Map<String, dynamic> m) => Achievement(
        title: m['title'] ?? '',
        description: m['description'] ?? '',
        unlocked: m['unlocked'] ?? false,
      );
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? email;
  String? nickname;
  Uint8List? avatarBytes;

  int visitedCafes = 0;
  double avgRating = 0;
  String? coffeeRecommendation;

  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();
  String _settingsMessage = '';

  late ConfettiController _confettiController;

  final String apiBase = "http://172.20.10.2:8080/api/auth";

  final List<Achievement> achievements = [
    Achievement(
        title: 'Кофейный новичок',
        description: 'Оставь первый отзыв или посети кофейню ☕'),
    Achievement(
        title: 'Городской дегустатор', description: 'Посети 5 разных кофеен'),
    Achievement(title: 'Комментатор', description: 'Напиши 10 комментариев'),
    Achievement(title: 'Мастер вкуса', description: 'Средний рейтинг выше 4.5'),
  ];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _loadUserEmailAndProfile();
    _getCoffeeRecommendation();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  /// 🧾 Загрузка email и профиля
  Future<void> _loadUserEmailAndProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('userEmail');

    if (savedEmail == null) {
      setState(() => _settingsMessage = 'Пользователь не найден');
      return;
    }

    setState(() => email = savedEmail);
    await _loadProfile();
  }

  /// 🧾 Загрузка профиля
  Future<void> _loadProfile() async {
    if (email == null) return;

    try {
      final url = Uri.parse('$apiBase/user/$email');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            nickname = data['nickname'] ?? email;
            _nicknameController.text = nickname ?? '';
            if (data['avatar'] != null) {
              avatarBytes = base64Decode(data['avatar']);
            }
          });
        } else {
          setState(() => _settingsMessage = 'Профиль не найден');
        }
      } else {
        setState(() => _settingsMessage = 'Ошибка при загрузке профиля');
      }
    } catch (e) {
      debugPrint('Ошибка загрузки профиля: $e');
      setState(() => _settingsMessage = 'Ошибка соединения с сервером');
    }
  }

  /// ☕ Рекомендация кофе
  Future<void> _getCoffeeRecommendation() async {
    try {
      final service = CoffeeService();
      final shops = await service.loadCoffeeShops();
      if (shops.isNotEmpty) {
        final now = DateTime.now();
        CoffeeShop recommended;
        if (now.hour < 12) {
          shops.sort((a, b) => b.rating.compareTo(a.rating));
          recommended = shops.first;
        } else {
          recommended = shops[Random().nextInt(shops.length)];
        }
        setState(() {
          coffeeRecommendation =
              'Рекомендуем сегодня: ${recommended.name} (рейтинг: ${recommended.rating.toStringAsFixed(1)})';
        });
      } else {
        setState(() => coffeeRecommendation = 'Нет рекомендаций на сегодня.');
      }
    } catch (_) {
      setState(() => coffeeRecommendation = 'Нет рекомендаций на сегодня.');
    }
  }

  /// 🔐 Смена пароля
  Future<void> _changePassword() async {
    if (email == null) return;
    final newPassword = _passwordController.text.trim();
    if (newPassword.isEmpty) {
      setState(() => _settingsMessage = 'Введите новый пароль');
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('$apiBase/user/$email/password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'password': newPassword}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          _settingsMessage = 'Пароль успешно изменён!';
          _passwordController.clear();
        });
      } else {
        setState(() => _settingsMessage = data['message'] ?? 'Ошибка при смене пароля');
      }
    } catch (e) {
      setState(() => _settingsMessage = 'Ошибка соединения с сервером');
    }
  }

  /// ✍️ Смена никнейма
  Future<void> _changeNickname() async {
    if (email == null) return;
    final newNick = _nicknameController.text.trim();
    if (newNick.isEmpty) {
      setState(() => _settingsMessage = 'Введите никнейм');
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('$apiBase/user/$email/nickname'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nickname': newNick}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          nickname = newNick;
          _settingsMessage = 'Никнейм обновлён!';
        });
      } else {
        setState(() => _settingsMessage = data['message'] ?? 'Ошибка при обновлении ника');
      }
    } catch (e) {
      setState(() => _settingsMessage = 'Ошибка соединения с сервером');
    }
  }

  /// 🖼️ Изменить аватар
  Future<void> _pickAvatar() async {
    if (email == null) return;
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.bytes != null) {
      final bytes = result.files.single.bytes!;
      final encoded = base64Encode(bytes);

      try {
        final response = await http.put(
          Uri.parse('$apiBase/user/$email/avatar'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'avatar': encoded}),
        );

        final data = jsonDecode(response.body);
        if (response.statusCode == 200 && data['success'] == true) {
          setState(() {
            avatarBytes = bytes;
            _settingsMessage = 'Аватар обновлён!';
          });
        } else {
          setState(() => _settingsMessage = data['message'] ?? 'Ошибка при обновлении аватара');
        }
      } catch (e) {
        setState(() => _settingsMessage = 'Ошибка соединения с сервером');
      }
    }
  }

  /// 🚪 Выход
  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userEmail');

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? avatarProvider;
    if (avatarBytes != null) avatarProvider = MemoryImage(avatarBytes!);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: FancyAppBar(
        title: 'Профиль',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.beige),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          },
        ),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.beige.withOpacity(0.2),
                      backgroundImage: avatarProvider,
                      child: avatarProvider == null
                          ? const Icon(Icons.person,
                              size: 60, color: AppColors.beige)
                          : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.lightBrown),
                      onPressed: _pickAvatar,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  nickname ?? email ?? 'Загрузка...',
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      color: AppColors.beige,
                      fontSize: 20),
                ),
                const SizedBox(height: 32),
                _SettingsSection(
                  nicknameController: _nicknameController,
                  passwordController: _passwordController,
                  onChangeNickname: _changeNickname,
                  onChangePassword: _changePassword,
                  onLogout: _logout,
                  settingsMessage: _settingsMessage,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _getCoffeeRecommendation,
                  icon: const Icon(Icons.coffee, color: AppColors.beige),
                  label: const Text(
                    'Получить рекомендацию кофе',
                    style: TextStyle(
                        color: AppColors.beige,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mediumBrown,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      elevation: 6),
                ),
                if (coffeeRecommendation != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: AppColors.mediumBrown.withOpacity(0.8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.coffee,
                              color: AppColors.beige, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              coffeeRecommendation!,
                              style: const TextStyle(
                                  color: AppColors.beige,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final TextEditingController nicknameController;
  final TextEditingController passwordController;
  final VoidCallback onChangeNickname;
  final VoidCallback onChangePassword;
  final VoidCallback onLogout;
  final String settingsMessage;

  const _SettingsSection({
    required this.nicknameController,
    required this.passwordController,
    required this.onChangeNickname,
    required this.onChangePassword,
    required this.onLogout,
    required this.settingsMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.lightBrown.withOpacity(0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Настройки',
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBrown,
                    fontSize: 18)),
            const SizedBox(height: 12),
            TextField(
              controller: nicknameController,
              decoration: InputDecoration(
                hintText: 'Ваш никнейм',
                hintStyle: const TextStyle(color: AppColors.darkBrown),
                filled: true,
                fillColor: AppColors.beige.withOpacity(0.2),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
              style: const TextStyle(color: AppColors.darkBrown),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
                onPressed: onChangeNickname,
                icon: const Icon(Icons.edit, color: AppColors.beige),
                label: const Text('Сменить ник'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mediumBrown,
                    foregroundColor: AppColors.beige,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 6)),
            const SizedBox(height: 12),
            TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                    hintText: 'Новый пароль',
                    hintStyle: const TextStyle(color: AppColors.darkBrown),
                    filled: true,
                    fillColor: AppColors.beige.withOpacity(0.2),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
                style: const TextStyle(color: AppColors.darkBrown)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
                onPressed: onChangePassword,
                icon: const Icon(Icons.lock_reset, color: AppColors.beige),
                label: const Text('Сменить пароль'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mediumBrown,
                    foregroundColor: AppColors.beige,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 6)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout, color: AppColors.beige),
                label: const Text('Выйти'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: AppColors.beige,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 6)),
            if (settingsMessage.isNotEmpty)
              Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(settingsMessage,
                      style: TextStyle(
                          color: settingsMessage.contains('успешно')
                              ? Colors.green
                              : Colors.redAccent))),
          ],
        ),
      ),
    );
  }
}
