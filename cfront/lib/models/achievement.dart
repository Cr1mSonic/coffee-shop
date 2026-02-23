class Achievement {
  final String title;
  final String description;
  final String icon;
  bool unlocked;

  Achievement({
    required this.title,
    required this.description,
    required this.icon,
    this.unlocked = false,
  });
}
