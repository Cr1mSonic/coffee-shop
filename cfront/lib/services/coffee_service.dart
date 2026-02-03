import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/coffee_shop.dart';

class CoffeeService {
  Future<List<CoffeeShop>> loadCoffeeShops() async {
    final data = await rootBundle.loadString('lib/data/coffee_shops.json');
    final List<dynamic> jsonResult = json.decode(data);
    return jsonResult.map((e) => CoffeeShop.fromMap(e)).toList();
  }
}
