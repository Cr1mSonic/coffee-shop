import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../theme.dart';

/// =======================
/// МОДЕЛЬ КОФЕЙНИ
/// =======================
class CoffeeShopInfo {
  final int id;
  final String name;
  final LatLng location;
  double rating;
  final List<String> comments;
  final List<File> photos;

  CoffeeShopInfo({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.comments,
    required this.photos,
  });

  factory CoffeeShopInfo.fromJson(Map<String, dynamic> json) {
    return CoffeeShopInfo(
      id: json['id'],
      name: json['name'],
      location: LatLng(json['lat'], json['lng']),
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

class _MapScreenState extends State<MapScreen>
    with TickerProviderStateMixin {
  final MapController mapController = MapController();

  List<CoffeeShopInfo> coffeeShops = [];
  bool isLoading = true;

  /// 🔹 ФИЛЬТРЫ И СОРТИРОВКА
  double _minRating = 0.0;
  String _sortType = 'По умолчанию';

  @override
  void initState() {
    super.initState();
    fetchCoffeeShops();
  }

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
      }
    } catch (e) {
      debugPrint('Ошибка: $e');
      setState(() => isLoading = false);
    }
  }

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
                if (shop.photos.isNotEmpty)
                  SizedBox(
                    height: 180,
                    child: PageView.builder(
                      controller:
                          PageController(viewportFraction: 0.9),
                      itemCount: shop.photos.length,
                      itemBuilder: (_, i) => Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(16),
                          child: Image.file(
                            shop.photos[i],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),

                Center(
                  child: TextButton.icon(
                    onPressed: () =>
                        _pickImage(shop, modalSetState),
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Добавить фото'),
                  ),
                ),

                const Divider(),
                const Text(
                  'Комментарии:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

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
                  ),
                ),
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
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
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
                ),
              ],
            ),
    );
  }
}
