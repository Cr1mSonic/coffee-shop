import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/achievements_service.dart';
import '../theme.dart';
import 'home_screen.dart';
import '../widgets/gradient_background.dart';
import '../widgets/fancy_app_bar.dart';
import '../widgets/responsive_frame.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;
  String _message = '';

  /// 🔐 Проверка длины пароля
  bool _isPasswordValid(String password) {
    if (password.length < 6) {
      _message = 'Пароль должен быть не менее 6 символов';
      return false;
    }
    if (password.length > 32) {
      _message = 'Пароль не должен превышать 32 символа';
      return false;
    }
    return true;
  }

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _message = 'Пожалуйста, заполните все поля.');
      return;
    }

    if (!_isPasswordValid(password)) {
      setState(() {});
      return;
    }

    try {
      final result = _isLogin
          ? await ApiService.login(email, password)
          : await ApiService.register(email, password);

      if (result['success'] == true) {
        if (_isLogin) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userEmail', email);
          if (result['role'] != null) {
            await prefs.setString('userRole', result['role']);
          }

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          await AchievementsService.recordRegistered(email);
          setState(() {
            _message = 'Регистрация успешна! Теперь войдите.';
            _isLogin = true;
          });
        }
      } else {
        setState(() => _message = result['message'] ?? 'Ошибка авторизации');
      }
    } catch (e) {
      setState(() => _message = 'Ошибка соединения с сервером');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: FancyAppBar(title: _isLogin ? 'Вход' : 'Регистрация'),
      body: GradientBackground(
        child: ResponsiveFrame(
          maxWidth: 520,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Icon(
                  Icons.local_cafe_rounded,
                  size: ResponsiveFrame.isTablet(context) ? 96 : 80,
                  color: AppColors.beige.withOpacity(0.9),
                ),
                const SizedBox(height: 24),

                /// 📧 Email
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    filled: true,
                    fillColor: AppColors.mediumBrown.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  style: const TextStyle(color: AppColors.beige),
                ),

                const SizedBox(height: 20),

                /// 🔑 Пароль
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Пароль (6–32 символа)',
                    filled: true,
                    fillColor: AppColors.mediumBrown.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  style: const TextStyle(color: AppColors.beige),
                ),

                const SizedBox(height: 20),

                if (_message.isNotEmpty)
                  Text(
                    _message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          _message.contains('Ошибка') ||
                              _message.contains('Пароль')
                          ? Colors.redAccent
                          : AppColors.beige,
                    ),
                  ),

                const SizedBox(height: 20),

                /// 🔐 Вход / регистрация
                ElevatedButton(
                  onPressed: _handleAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mediumBrown,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    _isLogin ? 'Войти' : 'Зарегистрироваться',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.beige,
                    ),
                  ),
                ),

                /// 🔄 Переключение режимов
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                      _message = '';
                    });
                  },
                  child: Text(
                    _isLogin
                        ? 'Нет аккаунта? Зарегистрируйтесь'
                        : 'Уже есть аккаунт? Войти',
                    style: const TextStyle(color: AppColors.beige),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
