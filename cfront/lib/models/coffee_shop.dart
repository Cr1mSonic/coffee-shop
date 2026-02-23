class CoffeeShop {
  final int id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final double rating;

  CoffeeShop({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.rating,
  });

  factory CoffeeShop.fromMap(Map<String, dynamic> map) => CoffeeShop(
        id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 0,
        name: map['name'] ?? '',
        address: map['address'] ?? '',
        lat: (map['lat'] ?? 0).toDouble(),
        lng: (map['lng'] ?? 0).toDouble(),
        rating: (map['rating'] ?? 0).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'address': address,
        'lat': lat,
        'lng': lng,
        'rating': rating,
      };

  @override
  String toString() =>
      '$name\n$address\nРейтинг: ${rating.toStringAsFixed(1)}';
}
