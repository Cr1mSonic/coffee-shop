import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AchievementDefinition {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int? target;

  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.target,
  });
}

class AchievementProgress {
  final AchievementDefinition definition;
  final bool unlocked;
  final int current;
  final int? target;

  const AchievementProgress({
    required this.definition,
    required this.unlocked,
    required this.current,
    required this.target,
  });
}

class AchievementsService {
  static const List<AchievementDefinition> definitions = [
    AchievementDefinition(
      id: 'explorer_5',
      title: 'Кофейный исследователь',
      description: 'Посетить 5 разных кофеен',
      icon: '🥇',
      target: 5,
    ),
    AchievementDefinition(
      id: 'loyal_3',
      title: 'Верный гурман',
      description: 'Посетить одну и ту же кофейню 3 раза',
      icon: '🥈',
      target: 3,
    ),
    AchievementDefinition(
      id: 'critic_10',
      title: 'Критик',
      description: 'Оставить 10 отзывов',
      icon: '🏆',
      target: 10,
    ),
    AchievementDefinition(
      id: 'first_steps',
      title: 'Первые шаги',
      description: 'Зарегистрироваться и добавить первый отзыв',
      icon: '🌟',
    ),
    AchievementDefinition(
      id: 'strict_critic',
      title: 'Строгий критик',
      description: 'Поставить 1 звезду 3 раза',
      icon: '⚡',
      target: 3,
    ),
  ];

  static Future<List<AchievementDefinition>> recordRegistered(
    String email,
  ) async {
    final state = await _loadState(email);
    state['registered'] = true;
    return _saveAndResolve(email, state);
  }

  static Future<List<AchievementDefinition>> recordVisit(
    String email,
    int shopId,
  ) async {
    final state = await _loadState(email);
    final visits = List<int>.from(state['visitedShopIds'] as List<dynamic>);
    if (!visits.contains(shopId)) {
      visits.add(shopId);
    }
    state['visitedShopIds'] = visits;

    final perShop = Map<String, dynamic>.from(state['visitsPerShop'] as Map);
    final key = shopId.toString();
    perShop[key] = (perShop[key] as int? ?? 0) + 1;
    state['visitsPerShop'] = perShop;

    return _saveAndResolve(email, state);
  }

  static Future<List<AchievementDefinition>> recordReview(
    String email,
    double rating,
  ) async {
    final state = await _loadState(email);
    state['reviewsCount'] = (state['reviewsCount'] as int? ?? 0) + 1;
    if (rating <= 1.0) {
      state['oneStarCount'] = (state['oneStarCount'] as int? ?? 0) + 1;
    }
    return _saveAndResolve(email, state);
  }

  static Future<List<AchievementProgress>> getProgress(String email) async {
    final state = await _loadState(email);
    final unlocked = Set<String>.from(state['unlocked'] as List<dynamic>);
    final visitedShopIds = List<int>.from(
      state['visitedShopIds'] as List<dynamic>,
    );
    final visitsPerShop = Map<String, dynamic>.from(
      state['visitsPerShop'] as Map,
    );
    final reviewsCount = state['reviewsCount'] as int? ?? 0;
    final oneStarCount = state['oneStarCount'] as int? ?? 0;
    final isRegistered = state['registered'] == true;
    final maxVisits = visitsPerShop.values
        .map((v) => v is int ? v : int.tryParse(v.toString()) ?? 0)
        .fold<int>(0, (a, b) => a > b ? a : b);

    return definitions.map((def) {
      switch (def.id) {
        case 'explorer_5':
          return AchievementProgress(
            definition: def,
            unlocked: unlocked.contains(def.id),
            current: visitedShopIds.length,
            target: def.target,
          );
        case 'loyal_3':
          return AchievementProgress(
            definition: def,
            unlocked: unlocked.contains(def.id),
            current: maxVisits,
            target: def.target,
          );
        case 'critic_10':
          return AchievementProgress(
            definition: def,
            unlocked: unlocked.contains(def.id),
            current: reviewsCount,
            target: def.target,
          );
        case 'first_steps':
          final current = isRegistered ? (reviewsCount > 0 ? 2 : 1) : 0;
          return AchievementProgress(
            definition: def,
            unlocked: unlocked.contains(def.id),
            current: current,
            target: 2,
          );
        case 'strict_critic':
          return AchievementProgress(
            definition: def,
            unlocked: unlocked.contains(def.id),
            current: oneStarCount,
            target: def.target,
          );
        default:
          return AchievementProgress(
            definition: def,
            unlocked: unlocked.contains(def.id),
            current: 0,
            target: def.target,
          );
      }
    }).toList();
  }

  static Future<List<AchievementDefinition>> _saveAndResolve(
    String email,
    Map<String, dynamic> state,
  ) async {
    final newlyUnlocked = _resolveUnlocks(state);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(email), jsonEncode(state));
    return newlyUnlocked;
  }

  static List<AchievementDefinition> _resolveUnlocks(
    Map<String, dynamic> state,
  ) {
    final unlocked = Set<String>.from(state['unlocked'] as List<dynamic>);
    final visitedShopIds = List<int>.from(
      state['visitedShopIds'] as List<dynamic>,
    );
    final visitsPerShop = Map<String, dynamic>.from(
      state['visitsPerShop'] as Map,
    );
    final reviewsCount = state['reviewsCount'] as int? ?? 0;
    final oneStarCount = state['oneStarCount'] as int? ?? 0;
    final isRegistered = state['registered'] == true;
    final maxVisits = visitsPerShop.values
        .map((v) => v is int ? v : int.tryParse(v.toString()) ?? 0)
        .fold<int>(0, (a, b) => a > b ? a : b);

    final newlyUnlocked = <AchievementDefinition>[];
    void unlock(String id) {
      if (!unlocked.contains(id)) {
        unlocked.add(id);
        newlyUnlocked.add(definitions.firstWhere((d) => d.id == id));
      }
    }

    if (visitedShopIds.length >= 5) unlock('explorer_5');
    if (maxVisits >= 3) unlock('loyal_3');
    if (reviewsCount >= 10) unlock('critic_10');
    if (isRegistered && reviewsCount >= 1) unlock('first_steps');
    if (oneStarCount >= 3) unlock('strict_critic');

    state['unlocked'] = unlocked.toList();
    return newlyUnlocked;
  }

  static Future<Map<String, dynamic>> _loadState(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(email));
    if (raw == null || raw.isEmpty) {
      return _initialState();
    }

    try {
      final map = Map<String, dynamic>.from(jsonDecode(raw));
      map.putIfAbsent('visitedShopIds', () => <int>[]);
      map.putIfAbsent('visitsPerShop', () => <String, int>{});
      map.putIfAbsent('reviewsCount', () => 0);
      map.putIfAbsent('oneStarCount', () => 0);
      map.putIfAbsent('registered', () => false);
      map.putIfAbsent('unlocked', () => <String>[]);
      return map;
    } catch (_) {
      return _initialState();
    }
  }

  static Map<String, dynamic> _initialState() {
    return {
      'visitedShopIds': <int>[],
      'visitsPerShop': <String, int>{},
      'reviewsCount': 0,
      'oneStarCount': 0,
      'registered': false,
      'unlocked': <String>[],
    };
  }

  static String _key(String email) => 'achievements_state_$email';
}
