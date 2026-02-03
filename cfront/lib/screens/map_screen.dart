import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../theme.dart';

class CoffeeShopInfo {
  final int id;
  final String name;
  final LatLng location;
  double rating;
  final List<String> comments;
  final List<File> photos; // 📸 добавлено поле с фото

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

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  List<CoffeeShopInfo> coffeeShops = [];
  bool isLoading = true;
  int? _animatedMarkerIndex;

  @override
  void initState() {
    super.initState();
    fetchCoffeeShops();
  }

  Future<void> fetchCoffeeShops() async {
    try {
      final response = await http.get(
        Uri.parse('http://172.20.10.2:8080/api/coffee-shops'),
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          coffeeShops = data.map((e) => CoffeeShopInfo.fromJson(e)).toList();
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

  /// 📸 Добавление фото
  Future<void> _pickImage(CoffeeShopInfo shop, StateSetter setModalState) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setModalState(() {
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
          builder: (context, setModalState) => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.mediumBrown.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.mediumBrown,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star,
                              color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            shop.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppColors.beige,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 📸 Слайдер фотографий
                if (shop.photos.isNotEmpty)
                  SizedBox(
                    height: 180,
                    child: PageView.builder(
                      itemCount: shop.photos.length,
                      controller: PageController(viewportFraction: 0.9),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              shop.photos[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton.icon(
                    onPressed: () => _pickImage(shop, setModalState),
                    icon: const Icon(Icons.add_a_photo,
                        color: AppColors.mediumBrown),
                    label: const Text(
                      'Добавить фото',
                      style: TextStyle(
                        color: AppColors.mediumBrown,
                        fontFamily: 'OpenSans',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Divider(),

                const Text(
                  'Комментарии:',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.mediumBrown,
                  ),
                ),
                const SizedBox(height: 8),
                ...shop.comments.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.comment,
                            color: AppColors.mediumBrown, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            c,
                            style: const TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: 15,
                              color: AppColors.darkBrown,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                Row(
                  children: [
                    const Text(
                      'Ваша оценка:',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        color: AppColors.darkBrown,
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<double>(
                      value: userRating,
                      items: [5.0, 4.5, 4.0, 3.5, 3.0, 2.5, 2.0, 1.5, 1.0]
                          .map((v) => DropdownMenuItem<double>(
                                value: v,
                                child: Text(v.toString()),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => userRating = val);
                      },
                    ),
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                  ],
                ),
                TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    hintText: 'Ваш комментарий...',
                    filled: true,
                    fillColor: AppColors.beige.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  minLines: 1,
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final comment = commentController.text.trim();
                      if (comment.isNotEmpty) {
                        setState(() {
                          shop.comments.add(comment);
                          shop.rating = (shop.rating + userRating) / 2;
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Спасибо за отзыв!'),
                            backgroundColor: AppColors.mediumBrown,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        );
                      }
                    },
                    icon:
                        const Icon(Icons.send, color: AppColors.beige),
                    label: const Text('Оставить отзыв'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mediumBrown,
                      foregroundColor: AppColors.beige,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapController = MapController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.mediumBrown,
        title: const Text('Карта кофеен'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    center: coffeeShops.isNotEmpty
                        ? coffeeShops.first.location
                        : LatLng(51.1694, 71.4491),
                    zoom: 12,
                    minZoom: 5,
                    maxZoom: 18,
                    interactiveFlags: InteractiveFlag.all,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://cartodb-basemaps-a.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png',
                      userAgentPackageName:
                          'com.example.flutter_application_2',
                    ),
                    MarkerLayer(
                      markers: coffeeShops.asMap().entries.map(
                        (entry) {
                          final shop = entry.value;
                          final idx = entry.key;
                          final isAnimated = _animatedMarkerIndex == idx;
                          return Marker(
                            width: 44,
                            height: 44,
                            point: shop.location,
                            child: AnimatedScale(
                              scale: isAnimated ? 1.3 : 1.0,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutBack,
                              child: GestureDetector(
                                onTap: () =>
                                    _showCoffeeShopInfo(context, shop),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.brown.withOpacity(0.2),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.local_cafe,
                                    color: Colors.brown,
                                    size: 36,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.small(
                        heroTag: "zoomIn",
                        onPressed: () {
                          mapController.move(
                            mapController.center,
                            mapController.zoom + 1,
                          );
                        },
                        backgroundColor: AppColors.mediumBrown,
                        child: const Icon(Icons.add, color: AppColors.beige),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: "zoomOut",
                        onPressed: () {
                          mapController.move(
                            mapController.center,
                            mapController.zoom - 1,
                          );
                        },
                        backgroundColor: AppColors.mediumBrown,
                        child: const Icon(Icons.remove,
                            color: AppColors.beige),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
