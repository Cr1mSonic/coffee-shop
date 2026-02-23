import 'package:flutter/material.dart';
import 'auth_screen.dart';
import '../widgets/responsive_frame.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4B2C20), Color(0xFF8B5E3C), Color(0xFFD3A36A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: ResponsiveFrame(
            maxWidth: 720,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 80),
                    Image.asset('assets/images/logo.png', height: 120),
                    const SizedBox(height: 30),
                    const Text(
                      'Coffee Radar',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Найди лучшие кофейни Астаны рядом с тобой.\n'
                      'Следи за скидками и сохраняй любимые места!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AuthScreen(),
                          ),
                        );
                      },
                      child: const Text('Начать'),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '© 2025 Coffee Radar',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
