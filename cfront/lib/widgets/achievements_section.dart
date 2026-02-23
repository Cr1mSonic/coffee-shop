import 'package:flutter/material.dart';
import '../theme.dart';
import '../data/achievements_data.dart';

class AchievementsSection extends StatelessWidget {
  const AchievementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🏅 Достижения',
          style: TextStyle(
            fontSize: 22,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: AppColors.darkBrown,
          ),
        ),
        const SizedBox(height: 10),
        ...achievements.map((a) => Card(
              color: a.unlocked
                  ? AppColors.lightBrown.withOpacity(0.3)
                  : Colors.brown.shade50,
              child: ListTile(
                leading: Text(
                  a.icon,
                  style: const TextStyle(fontSize: 28),
                ),
                title: Text(
                  a.title,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  a.description,
                  style: TextStyle(
                    color: a.unlocked
                        ? AppColors.darkBrown
                        : Colors.brown.withOpacity(0.5),
                  ),
                ),
                trailing: Icon(
                  a.unlocked ? Icons.lock_open : Icons.lock,
                  color: a.unlocked ? AppColors.mediumBrown : Colors.grey,
                ),
              ),
            )),
      ],
    );
  }
}
