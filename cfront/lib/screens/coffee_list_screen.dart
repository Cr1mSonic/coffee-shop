import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../models/coffee_shop.dart';
import '../theme.dart';
import '../widgets/fancy_app_bar.dart';
import '../widgets/gradient_background.dart';
import '../widgets/responsive_frame.dart';

class CoffeeListScreen extends StatefulWidget {
  const CoffeeListScreen({super.key});

  @override
  State<CoffeeListScreen> createState() => _CoffeeListScreenState();
}

class _CoffeeListScreenState extends State<CoffeeListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final String _backendBase = 'http://172.20.10.2:8080';

  bool _isLoading = true;
  bool _sortAscending = true;
  String _searchQuery = '';
  List<CoffeeShop> _shops = [];

  @override
  void initState() {
    super.initState();
    _loadCoffeeShops();
    _searchController.addListener(() {
      setState(
        () => _searchQuery = _searchController.text.trim().toLowerCase(),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCoffeeShops() async {
    try {
      final response = await http.get(
        Uri.parse('$_backendBase/api/coffee-shops'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final parsed = data
            .map((e) => CoffeeShop.fromMap(Map<String, dynamic>.from(e)))
            .toList();
        setState(() {
          _shops = parsed;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {
      // ignore and fallback below
    }

    try {
      final localData = await rootBundle.loadString(
        'lib/data/coffee_shops.json',
      );
      final List<dynamic> data = jsonDecode(localData);
      final parsed = data
          .map((e) => CoffeeShop.fromMap(Map<String, dynamic>.from(e)))
          .toList();
      setState(() {
        _shops = parsed;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось загрузить список кофеен'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<CoffeeShop> get _filteredShops {
    final filtered = _searchQuery.isEmpty
        ? List<CoffeeShop>.from(_shops)
        : _shops.where((shop) {
            final name = shop.name.toLowerCase();
            final address = shop.address.toLowerCase();
            return name.contains(_searchQuery) ||
                address.contains(_searchQuery);
          }).toList();

    filtered.sort((a, b) {
      final result = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      return _sortAscending ? result : -result;
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final shops = _filteredShops;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: FancyAppBar(
        title: 'Список кофеен',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.beige),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GradientBackground(
        child: ResponsiveFrame(
          maxWidth: 860,
          child: Column(
            children: [
              const SizedBox(height: 90),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Поиск по названию или адресу',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () => _searchController.clear(),
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.sort_by_alpha, color: AppColors.lightBrown),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _sortAscending = !_sortAscending);
                    },
                    icon: Icon(
                      _sortAscending
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: AppColors.lightBrown,
                      size: 18,
                    ),
                    label: Text(
                      _sortAscending ? 'Сортировка: А-Я' : 'Сортировка: Я-А',
                      style: const TextStyle(
                        color: AppColors.lightBrown,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : shops.isEmpty
                    ? const Center(
                        child: Text(
                          'Ничего не найдено',
                          style: TextStyle(
                            color: AppColors.beige,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: shops.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, index) {
                          final shop = shops[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.beige.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.local_cafe,
                                color: AppColors.mediumBrown,
                              ),
                              title: Text(
                                shop.name,
                                style: const TextStyle(
                                  color: AppColors.darkBrown,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                shop.address,
                                style: const TextStyle(
                                  color: AppColors.mediumBrown,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    shop.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: AppColors.darkBrown,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
