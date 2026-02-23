import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/onboarding_screen.dart';

void main() {
  runApp(const CoffeeApp());
}

class CoffeeApp extends StatelessWidget {
  const CoffeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee Radar',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const OnboardingScreen(),
    );
  }
}
