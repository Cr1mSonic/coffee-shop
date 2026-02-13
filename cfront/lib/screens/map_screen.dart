<<<<<<< HEAD
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
=======
﻿import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
>>>>>>> 9e3e8e6 (fortnite commit)
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
<<<<<<< HEAD
=======
import 'package:shared_preferences/shared_preferences.dart';
>>>>>>> 9e3e8e6 (fortnite commit)

import '../theme.dart';

/// =======================
/// МОДЕЛЬ КОФЕЙНИ
/// =======================
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

/// =======================
/// ЭКРАН КАРТЫ
/// =======================
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

<<<<<<< HEAD
class _MapScreenState extends State<MapScreen>
    with TickerProviderStateMixin {
  final MapController mapController = MapController();

  List<CoffeeShopInfo> coffeeShops = [];
=======
class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final List<CoffeeShopInfo> coffeeShops = [];
>>>>>>> 9e3e8e6 (fortnite commit)
  bool isLoading = true;

  /// 🔹 ФИЛЬТРЫ И СОРТИРОВКА
  double _minRating = 0.0;
  String _sortType = 'По умолчанию';

  String? _userEmail;
  String? _userRole;
  final String backendBase = 'http://172.20.10.2:8080';
  double _minRating = 0.0;

  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadUserContext();
    _loadCoffeeShopsFromBackend();
  }

<<<<<<< HEAD
  /// =======================
  /// ЗАГРУЗКА КОФЕЕН
  /// =======================
  Future<void> fetchCoffeeShops() async {
    try {
      final response = await http.get(
        Uri.parse('http://172.20.10.2:8080/api/coffee-shops'),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          coffeeShops =
              data.map((e) => CoffeeShopInfo.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Ошибка загрузки данных');
=======
  bool get _isAdmin => _userRole == 'ADMIN';
  List<CoffeeShopInfo> get _filteredShops =>
      coffeeShops.where((s) => s.rating >= _minRating).toList();

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
        coffeeShops.clear();
        coffeeShops.addAll(
          data.map((e) => CoffeeShopInfo.fromJson(e)),
        );
        debugPrint('Загружено кофеен (backend): ${coffeeShops.length}');
        setState(() => isLoading = false);
        return;
>>>>>>> 9e3e8e6 (fortnite commit)
      }

      debugPrint('Backend error: ${res.statusCode}');
    } catch (e) {
      debugPrint('Ошибка загрузки backend: $e');
    }

    // fallback to local JSON
    try {
      final jsonString =
          await rootBundle.loadString('lib/data/coffee_shops.json');
      final List data = jsonDecode(jsonString);

      coffeeShops.clear();
      coffeeShops.addAll(
        data.map((e) => CoffeeShopInfo.fromJson(e)),
      );

      debugPrint('Загружено кофеен (json): ${coffeeShops.length}');
      setState(() => isLoading = false);
    } catch (e) {
      debugPrint('Ошибка загрузки JSON: $e');
      setState(() => isLoading = false);
    }
  }

<<<<<<< HEAD
  /// =======================
  /// ФИЛЬТРАЦИЯ + СОРТИРОВКА
  /// =======================
  List<CoffeeShopInfo> get filteredShops {
    List<CoffeeShopInfo> list = coffeeShops
        .where((shop) => shop.rating >= _minRating)
        .toList();

    switch (_sortType) {
      case 'По алфавиту (А–Я)':
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'По алфавиту (Я–А)':
        list.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'По рейтингу ↑':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'По рейтингу ↓':
        list.sort((a, b) => a.rating.compareTo(b.rating));
        break;
    }
    return list;
  }

  /// =======================
  /// ДОБАВЛЕНИЕ ФОТО
  /// =======================
  Future<void> _pickImage(
      CoffeeShopInfo shop, StateSetter modalSetState) async {
=======
  Future<void> _createCoffeeShop(CoffeeShopInfo shop) async {
    if (_userEmail == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No admin email found. Please login.')),
      );
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

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          CoffeeShopInfo created;
          if (body['coffeeShop'] is Map<String, dynamic>) {
            created = CoffeeShopInfo.fromJson(
              Map<String, dynamic>.from(body['coffeeShop']),
            );
          } else {
            final nextId = coffeeShops.isEmpty
                ? 1
                : coffeeShops
                        .map((s) => s.id)
                        .reduce((a, b) => a > b ? a : b) +
                    1;
            created = CoffeeShopInfo(
              id: nextId,
              name: shop.name,
              address: shop.address,
              location: shop.location,
              rating: shop.rating,
              comments: [],
              photos: [],
            );
          }
          setState(() => coffeeShops.add(created));
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(body['message'] ?? 'Create failed')),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${res.statusCode}')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection error')),
      );
    }
  }

  Future<bool> _deleteCoffeeShop(CoffeeShopInfo shop) async {
    if (_userEmail == null) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No admin email found. Please login.')),
      );
      return false;
    }

    try {
      final uri = Uri.parse(
        '$backendBase/api/coffee-shops/${shop.id}?adminEmail=$_userEmail',
      );
      final res = await http.delete(uri);

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          setState(() => coffeeShops.removeWhere((s) => s.id == shop.id));
          return true;
        } else {
          if (!mounted) return false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(body['message'] ?? 'Delete failed')),
          );
        }
      } else {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${res.statusCode}')),
        );
      }
    } catch (_) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection error')),
      );
    }

    return false;
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
        title: const Text('Add coffee shop'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: latController,
                decoration: const InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: lngController,
                decoration: const InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: ratingController,
                decoration: const InputDecoration(labelText: 'Rating'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final address = addressController.text.trim();
              final lat = double.tryParse(latController.text.trim());
              final lng = double.tryParse(lngController.text.trim());
              final rating =
                  double.tryParse(ratingController.text.trim()) ?? 4.5;

              if (name.isEmpty || address.isEmpty || lat == null || lng == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fill all fields correctly.')),
                );
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
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  /// 📸 Добавление фото
  Future<void> _pickImage(
      CoffeeShopInfo shop, StateSetter setModalState) async {
>>>>>>> 9e3e8e6 (fortnite commit)
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      modalSetState(() {
        shop.photos.add(File(picked.path));
      });
    }
  }

  /// =======================
  /// BOTTOM SHEET КОФЕЙНИ
  /// =======================
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
          builder: (context, modalSetState) =>
              SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color:
                          AppColors.mediumBrown.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
<<<<<<< HEAD
                Text(
                  shop.name,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: AppColors.darkBrown,
                  ),
                ),
                const SizedBox(height: 12),

                /// 📸 ФОТО
=======
                Row(
                  children: [
                    const Icon(Icons.local_cafe,
                        color: AppColors.mediumBrown, size: 32),
                    const SizedBox(width: 12),
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
                  ],
                ),
                const SizedBox(height: 12),

                // 📸 Фото
>>>>>>> 9e3e8e6 (fortnite commit)
                if (shop.photos.isNotEmpty)
                  SizedBox(
                    height: 180,
                    child: PageView.builder(
                      controller:
                          PageController(viewportFraction: 0.9),
                      itemCount: shop.photos.length,
                      itemBuilder: (_, i) => Padding(
<<<<<<< HEAD
                        padding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(16),
=======
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
>>>>>>> 9e3e8e6 (fortnite commit)
                          child: Image.file(
                            shop.photos[i],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
<<<<<<< HEAD

                Center(
                  child: TextButton.icon(
                    onPressed: () =>
                        _pickImage(shop, modalSetState),
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Добавить фото'),
=======

                Center(
                  child: TextButton.icon(
                    onPressed: () => _pickImage(shop, setModalState),
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Добавить фото'),
                  ),
                ),

                const Divider(),

                const Text(
                  'Комментарии:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ...shop.comments.map((c) => Text('• $c')),

                const Divider(),

                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    hintText: 'Ваш комментарий',
>>>>>>> 9e3e8e6 (fortnite commit)
                  ),
                ),

                const Divider(),
                const Text(
                  'Комментарии:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

<<<<<<< HEAD
                ...shop.comments.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(c),
                  ),
                ),

                const Divider(),
                Row(
                  children: [
                    const Text('Ваша оценка:'),
                    const SizedBox(width: 8),
                    DropdownButton<double>(
                      value: userRating,
                      items: [5, 4.5, 4, 3.5, 3, 2.5, 2, 1.5, 1]
                          .map(
                            (v) => DropdownMenuItem(
                              value: v.toDouble(),
                              child: Text(v.toString()),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          modalSetState(() => userRating = v);
                        }
                      },
                    ),
                    const Icon(Icons.star, color: Colors.amber),
                  ],
                ),

                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    hintText: 'Ваш комментарий...',
                  ),
                  minLines: 1,
                  maxLines: 3,
                ),

                const SizedBox(height: 12),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final text =
                          commentController.text.trim();
                      if (text.isNotEmpty) {
                        setState(() {
                          shop.comments.add(text);
                          shop.rating =
                              (shop.rating + userRating) / 2;
                        });
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('Оставить отзыв'),
=======
                ElevatedButton(
                  onPressed: () {
                    if (commentController.text.isNotEmpty) {
                      setState(() {
                        shop.comments.add(commentController.text);
                        shop.rating = (shop.rating + userRating) / 2;
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Оставить отзыв'),
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
                    label: const Text('Delete coffee shop'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
>>>>>>> 9e3e8e6 (fortnite commit)
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// =======================
  /// UI
  /// =======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.mediumBrown,
        title: const Text('Карта кофеен'),
        actions: [
          PopupMenuButton<double>(
            onSelected: (value) {
              setState(() => _minRating = value);
            },
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
                    : const LatLng(43.238949, 76.889709),
                zoom: 12,
              ),
              children: [
<<<<<<< HEAD
                /// 🗺 КАРТА
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    center: filteredShops.isNotEmpty
                        ? filteredShops.first.location
                        : LatLng(51.1694, 71.4491),
                    zoom: 12,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://cartodb-basemaps-a.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png',
                      userAgentPackageName:
                          'com.example.flutter_application_2',
                    ),
                    MarkerLayer(
                      markers: filteredShops.map((shop) {
                        return Marker(
                          point: shop.location,
                          width: 44,
                          height: 44,
                          child: GestureDetector(
                            onTap: () =>
                                _showCoffeeShopInfo(context, shop),
                            child: const Icon(
                              Icons.local_cafe,
                              size: 36,
                              color: Colors.brown,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                /// 🔽 ФИЛЬТРЫ
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          AppColors.beige.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text('Рейтинг ≥'),
                            const SizedBox(width: 8),
                            DropdownButton<double>(
                              value: _minRating,
                              items: [0, 3, 3.5, 4, 4.5]
                                  .map(
                                    (v) => DropdownMenuItem(
                                      value: v.toDouble(),
                                      child: Text(
                                          v == 0 ? 'Любой' : '$v'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() => _minRating = v);
                                }
                              },
                            ),
                          ],
                        ),
                        DropdownButton<String>(
                          value: _sortType,
                          isExpanded: true,
                          items: const [
                            'По умолчанию',
                            'По алфавиту (А–Я)',
                            'По алфавиту (Я–А)',
                            'По рейтингу ↑',
                            'По рейтингу ↓',
                          ]
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _sortType = v);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
=======
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
                      child: GestureDetector(
                        onTap: () => _showCoffeeShopInfo(context, shop),
                        child: const Icon(
                          Icons.local_cafe,
                          color: Colors.brown,
                          size: 36,
                        ),
                      ),
                    );
                  }).toList(),
>>>>>>> 9e3e8e6 (fortnite commit)
                ),
              ],
            ),
    );
  }
}