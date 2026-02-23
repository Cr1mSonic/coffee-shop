import 'package:flutter/material.dart';
import '../models/coffee_shop.dart';
import '../theme.dart';
import '../widgets/gradient_background.dart';
import '../widgets/fancy_app_bar.dart';

class CoffeeDetailsScreen extends StatelessWidget {
  final CoffeeShop shop;

  const CoffeeDetailsScreen({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: FancyAppBar(
        title: shop.name,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.beige),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GradientBackground(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.lightBrown),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      shop.address,
                      style: const TextStyle(
                        fontFamily: 'OpenSans',
                        color: AppColors.beige,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange),
                  Text(
                    shop.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: AppColors.beige,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                "Отзывы",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  color: AppColors.lightBrown,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Тут можно добавить список отзывов или форму для добавления.",
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
