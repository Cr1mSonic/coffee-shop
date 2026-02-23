import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';

import '../theme.dart';
import '../services/http_error_parser.dart';
import '../services/achievements_service.dart';

class CoffeeShopInfo {
  final int id;
  final String name;
  final String address;
  final LatLng location;
  double rating;
  final List<String> comments;
  final List<File> photos;

  CoffeeShopInfo({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.rating,
    required this.comments,
    required this.photos,
  });

  factory CoffeeShopInfo.fromJson(Map<String, dynamic> json) {
    return CoffeeShopInfo(
      id: json['id'],
      name: json['name'],
      address: json['address'] ?? '',
      location: LatLng(
        (json['lat'] as num).toDouble(),
        (json['lng'] as num).toDouble(),
      ),
      rating: (json['rating'] as num).toDouble(),
      comments: [],
      photos: [],
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final List<CoffeeShopInfo> coffeeShops = [];
  final MapController _mapController = MapController();

  bool isLoading = true;
  double _minRating = 0.0;

  String? _userEmail;
  String? _userRole;
  final String backendBase = 'http://172.20.10.2:8080';

  @override
  void initState() {
    super.initState();
    _loadUserContext();
    _loadCoffeeShopsFromBackend();
  }

  bool get _isAdmin => _userRole == 'ADMIN';
  List<CoffeeShopInfo> get _filteredShops =>
      coffeeShops.where((s) => s.rating >= _minRating).toList();

  Future<void> _processVisitAchievement(CoffeeShopInfo shop) async {
    if (_userEmail == null) return;
    final unlocked = await AchievementsService.recordVisit(
      _userEmail!,
      shop.id,
    );
    if (!mounted || unlocked.isEmpty) return;
    for (final achievement in unlocked) {
      if (!mounted) break;
      await _showAchievementDialog(achievement);
    }
  }

  Future<void> _processReviewAchievement(double rating) async {
    if (_userEmail == null) return;
    final unlocked = await AchievementsService.recordReview(
      _userEmail!,
      rating,
    );
    if (!mounted || unlocked.isEmpty) return;
    for (final achievement in unlocked) {
      if (!mounted) break;
      await _showAchievementDialog(achievement);
    }
  }

  Future<void> _showAchievementDialog(AchievementDefinition achievement) async {
    final confetti = ConfettiController(duration: const Duration(seconds: 2));
    confetti.play();
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'achievement',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) {
        return Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: confetti,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.08,
                numberOfParticles: 35,
                maxBlastForce: 25,
                minBlastForce: 10,
                shouldLoop: false,
              ),
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 28),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.beige,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      achievement.icon,
                      style: const TextStyle(fontSize: 44),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Достижение открыто!',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppColors.darkBrown,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      achievement.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: AppColors.mediumBrown,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      achievement.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.darkBrown),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Круто'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
    confetti.dispose();
  }

  void _showNotice(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  Future<void> _loadUserContext() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('userEmail');
      _userRole = prefs.getString('userRole');
    });
  }

  Future<void> _loadCoffeeShopsFromBackend() async {
    try {
      final uri = Uri.parse('$backendBase/api/coffee-shops');
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        coffeeShops
          ..clear()
          ..addAll(data.map((e) => CoffeeShopInfo.fromJson(e)));

        setState(() => isLoading = false);
        return;
      }
    } catch (_) {
      // fallback below
    }

    try {
      final jsonString = await rootBundle.loadString(
        'lib/data/coffee_shops.json',
      );
      final List data = jsonDecode(jsonString);

      coffeeShops
        ..clear()
        ..addAll(data.map((e) => CoffeeShopInfo.fromJson(e)));
    } catch (_) {
      _showNotice('Не удалось загрузить кофейни', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _createCoffeeShop(CoffeeShopInfo shop) async {
    if (_userEmail == null) {
      _showNotice('Выполните вход в админ-аккаунт', isError: true);
      return;
    }

    try {
      final uri = Uri.parse(
        '$backendBase/api/coffee-shops?adminEmail=$_userEmail',
      );
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': shop.name,
          'address': shop.address,
          'lat': shop.location.latitude,
          'lng': shop.location.longitude,
          'rating': shop.rating,
        }),
      );

      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        final created = CoffeeShopInfo.fromJson(
          Map<String, dynamic>.from(body['coffeeShop']),
        );
        setState(() => coffeeShops.add(created));
        _showNotice('Кофейня добавлена');
      } else {
        _showNotice(
          HttpErrorParser.messageFromBody(
            res.body,
            fallback: 'Не удалось добавить кофейню',
          ),
          isError: true,
        );
      }
    } catch (_) {
      _showNotice('Ошибка соединения с сервером', isError: true);
    }
  }

  Future<bool> _deleteCoffeeShop(CoffeeShopInfo shop) async {
    if (_userEmail == null) {
      _showNotice('Выполните вход в админ-аккаунт', isError: true);
      return false;
    }

    try {
      final uri = Uri.parse(
        '$backendBase/api/coffee-shops/${shop.id}?adminEmail=$_userEmail',
      );
      final res = await http.delete(uri);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        setState(() => coffeeShops.removeWhere((s) => s.id == shop.id));
        _showNotice('Кофейня удалена');
        return true;
      }

      _showNotice(
        HttpErrorParser.messageFromBody(
          res.body,
          fallback: 'Не удалось удалить кофейню',
        ),
        isError: true,
      );
    } catch (_) {
      _showNotice('Ошибка соединения с сервером', isError: true);
    }

    return false;
  }

  Future<void> _rateCoffeeShop(CoffeeShopInfo shop, double rating) async {
    if (_userEmail == null) {
      _showNotice('Сначала войдите в аккаунт', isError: true);
      return;
    }

    try {
      final uri = Uri.parse(
        '$backendBase/api/coffee-shops/${shop.id}/rate?userEmail=$_userEmail',
      );
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'rating': rating}),
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final updated = body['coffeeShop'];
        if (updated is Map) {
          final map = Map<String, dynamic>.from(updated);
          setState(() {
            shop.rating = (map['rating'] as num).toDouble();
          });
        }
        _showNotice('Оценка сохранена');
        return;
      }

      _showNotice(
        HttpErrorParser.messageFromBody(
          res.body,
          fallback: 'Не удалось поставить оценку',
        ),
        isError: true,
      );
    } catch (_) {
      _showNotice('Ошибка соединения с сервером', isError: true);
    }
  }

  void _showAddCoffeeShopDialog() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final latController = TextEditingController();
    final lngController = TextEditingController();
    final ratingController = TextEditingController(text: '4.5');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Добавить кофейню'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Название'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Адрес'),
              ),
              TextField(
                controller: latController,
                decoration: const InputDecoration(labelText: 'Широта'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: lngController,
                decoration: const InputDecoration(labelText: 'Долгота'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: ratingController,
                decoration: const InputDecoration(labelText: 'Рейтинг'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final address = addressController.text.trim();
              final lat = double.tryParse(latController.text.trim());
              final lng = double.tryParse(lngController.text.trim());
              final rating =
                  double.tryParse(ratingController.text.trim()) ?? 4.5;

              if (name.isEmpty ||
                  address.isEmpty ||
                  lat == null ||
                  lng == null) {
                _showNotice('Заполните поля корректно', isError: true);
                return;
              }

              final temp = CoffeeShopInfo(
                id: 0,
                name: name,
                address: address,
                location: LatLng(lat, lng),
                rating: rating,
                comments: [],
                photos: [],
              );

              Navigator.pop(context);
              _createCoffeeShop(temp);
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(
    CoffeeShopInfo shop,
    StateSetter modalSetState,
  ) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      modalSetState(() {
        shop.photos.add(File(picked.path));
      });
    }
  }

  void _showCoffeeShopInfo(BuildContext context, CoffeeShopInfo shop) {
    final commentController = TextEditingController();
    double userRating = 5.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.beige.withOpacity(0.97),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (context, modalSetState) => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        shop.name,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: AppColors.darkBrown,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            shop.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkBrown,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  shop.address,
                  style: const TextStyle(
                    color: AppColors.mediumBrown,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                if (shop.photos.isNotEmpty)
                  SizedBox(
                    height: 180,
                    child: PageView.builder(
                      itemCount: shop.photos.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(shop.photos[i], fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                Center(
                  child: TextButton.icon(
                    onPressed: () => _pickImage(shop, modalSetState),
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Добавить фото'),
                  ),
                ),
                const Divider(),
                const Text(
                  'Комментарии:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...shop.comments.map((c) => Text('• $c')),
                const Divider(),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    hintText: 'Ваш комментарий',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Ваша оценка:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkBrown,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      userRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBrown,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: userRating,
                  min: 1.0,
                  max: 5.0,
                  divisions: 8,
                  label: userRating.toStringAsFixed(1),
                  activeColor: AppColors.mediumBrown,
                  onChanged: (value) {
                    modalSetState(() {
                      userRating = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    if (commentController.text.isNotEmpty) {
                      modalSetState(() {
                        shop.comments.add(commentController.text);
                      });
                    }
                    await _rateCoffeeShop(shop, userRating);
                    await _processReviewAchievement(userRating);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Оставить отзыв и оценку'),
                ),
                if (_isAdmin) ...[
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final deleted = await _deleteCoffeeShop(shop);
                      if (deleted && context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text('Удалить кофейню'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.mediumBrown,
        title: const Text('Карта кофеен'),
        actions: [
          PopupMenuButton<double>(
            onSelected: (value) => setState(() => _minRating = value),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 0.0, child: Text('Все рейтинги')),
              PopupMenuItem(value: 4.5, child: Text('Рейтинг 4.5+')),
              PopupMenuItem(value: 4.7, child: Text('Рейтинг 4.7+')),
              PopupMenuItem(value: 4.9, child: Text('Рейтинг 4.9+')),
            ],
            icon: const Icon(Icons.filter_list, color: AppColors.beige),
          ),
        ],
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: _showAddCoffeeShopDialog,
              backgroundColor: AppColors.mediumBrown,
              child: const Icon(Icons.add, color: AppColors.beige),
            )
          : null,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _filteredShops.isNotEmpty
                    ? _filteredShops.first.location
                    : const LatLng(51.169392, 71.449074),
                zoom: 12,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://cartodb-basemaps-a.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png',
                ),
                MarkerLayer(
                  markers: _filteredShops.map((shop) {
                    return Marker(
                      point: shop.location,
                      width: 44,
                      height: 44,
                      rotate: true,
                      child: GestureDetector(
                        onTap: () async {
                          await _processVisitAchievement(shop);
                          if (!mounted) return;
                          _showCoffeeShopInfo(this.context, shop);
                        },
                        child: const Icon(
                          Icons.local_cafe,
                          color: Colors.brown,
                          size: 36,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }
}
