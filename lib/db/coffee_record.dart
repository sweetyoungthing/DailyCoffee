class CoffeeRecord {
  final int? id;
  final String brand;
  final String type;
  final String size;
  final int volume;
  final int caffeine;
  final DateTime createdAt;
  final int price;

  CoffeeRecord({
    this.id,
    required this.brand,
    required this.type,
    required this.size,
    required this.volume,
    required this.caffeine,
    required this.createdAt,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'type': type,
      'size': size,
      'volume': volume,
      'caffeine': caffeine,
      'createdAt': createdAt.toIso8601String(),
      'price': price,
    };
  }

  factory CoffeeRecord.fromMap(Map<String, dynamic> map) {
    return CoffeeRecord(
      id: map['id'],
      brand: map['brand'],
      type: map['type'],
      size: map['size'],
      volume: map['volume'],
      caffeine: map['caffeine'],
      createdAt: DateTime.parse(map['createdAt']),
      price: map['price'] ?? 0,
    );
  }
} 