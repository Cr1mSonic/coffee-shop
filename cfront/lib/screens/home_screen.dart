import 'package:flutter/material.dart';
import '../theme.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import 'coffee_list_screen.dart';
import '../widgets/gradient_background.dart';
import '../widgets/fancy_app_bar.dart';
import '../widgets/responsive_frame.dart';
import 'ai_chat_screen.dart';
import 'dart:math';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: const FancyAppBar(title: 'Coffee Radar'),
      body: GradientBackground(
        child: ResponsiveFrame(
          maxWidth: 760,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 84),
                Hero(
                  tag: 'logo',
                  child: Icon(
                    Icons.local_cafe_rounded,
                    size: 100,
                    color: AppColors.beige.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Добро пожаловать в Coffee Radar!',
                  style: TextStyle(
                    color: AppColors.beige,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Исследуй кофейни Астаны и открывай новые места для вдохновения ☕',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.lightBrown,
                    fontSize: 16,
                    fontFamily: 'OpenSans',
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MapScreen()),
                    );
                  },
                  icon: const Icon(Icons.map, color: AppColors.beige),
                  label: const Text('Карта кофеен'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mediumBrown,
                    foregroundColor: AppColors.beige,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 6,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CoffeeListScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.list_alt, color: AppColors.beige),
                  label: const Text('Список кофеен'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mediumBrown,
                    foregroundColor: AppColors.beige,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 6,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                  icon: const Icon(
                    Icons.person_rounded,
                    color: AppColors.beige,
                  ),
                  label: const Text('Профиль'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mediumBrown,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 8,
                    shadowColor: AppColors.darkBrown.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AIChatScreen()),
                    );
                  },
                  icon: const Icon(Icons.smart_toy, color: AppColors.beige),
                  label: const Text('Чат с ИИ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mediumBrown,
                    foregroundColor: AppColors.beige,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 6,
                  ),
                ),
                const SizedBox(height: 40),

                // 🎡 Колесо кофе
                const CoffeeWheel(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===============================
// 🎡 Виджет Колесо Кофе
// ===============================
class CoffeeWheel extends StatefulWidget {
  const CoffeeWheel({super.key});

  @override
  State<CoffeeWheel> createState() => _CoffeeWheelState();
}

class _CoffeeWheelState extends State<CoffeeWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<String> coffeeOptions = [
    'Латте',
    'Капучино',
    'Эспрессо',
    'Раф',
    'Американо',
    'Мокко',
    'Флэт уайт',
    'Макиато',
  ];

  double _angle = 0;
  String? _selectedCoffee;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    );
  }

  void _spinWheel() {
    final random = Random();
    final randomAngle = random.nextDouble() * pi * 6 + pi * 2;
    final index = random.nextInt(coffeeOptions.length);

    setState(() {
      _selectedCoffee = coffeeOptions[index];
      _angle = randomAngle;
    });

    _controller.reset();
    _controller.forward();

    Future.delayed(const Duration(seconds: 4), () {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.beige,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            '☕ Твой напиток дня!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              color: AppColors.darkBrown,
            ),
          ),
          content: Text(
            'Сегодня попробуй: $_selectedCoffee!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.mediumBrown,
              fontSize: 18,
              fontFamily: 'OpenSans',
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mediumBrown,
                foregroundColor: AppColors.beige,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Спасибо!'),
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          '🎡 Колесо кофе',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.beige,
          ),
        ),
        const SizedBox(height: 16),
        Stack(
          alignment: Alignment.center,
          children: [
            RotationTransition(
              turns: Tween(
                begin: 0.0,
                end: _angle / (2 * pi),
              ).animate(_animation),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const SweepGradient(
                    colors: [
                      Colors.brown,
                      Colors.orangeAccent,
                      Colors.brown,
                      Colors.orangeAccent,
                      Colors.brown,
                    ],
                    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                  ),
                  border: Border.all(color: AppColors.beige, width: 4),
                ),
                child: Stack(
                  children: List.generate(coffeeOptions.length, (i) {
                    final angle = (2 * pi / coffeeOptions.length) * i;
                    return Transform.rotate(
                      angle: angle,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            coffeeOptions[i],
                            style: const TextStyle(
                              color: AppColors.beige,
                              fontFamily: 'OpenSans',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.amber, size: 40),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _spinWheel,
          icon: const Icon(Icons.coffee, color: AppColors.beige),
          label: const Text('Крутить колесо'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mediumBrown,
            foregroundColor: AppColors.beige,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 6,
          ),
        ),
      ],
    );
  }
}
