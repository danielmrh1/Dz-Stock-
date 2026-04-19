// lib/data/models/product.dart
class Product {
  final int? id;
  final String name;
  final String? barcode;
  final String? category;
  final String? brand;
  final double defaultPurchasePrice;
  final double defaultSellingPrice;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    this.id,
    required this.name,
    this.barcode,
    this.category,
    this.brand,
    this.defaultPurchasePrice = 0,
    this.defaultSellingPrice = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Product copyWith({
    int? id,
    String? name,
    String? barcode,
    String? category,
    String? brand,
    double? defaultPurchasePrice,
    double? defaultSellingPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      defaultPurchasePrice: defaultPurchasePrice ?? this.defaultPurchasePrice,
      defaultSellingPrice: defaultSellingPrice ?? this.defaultSellingPrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Product.fromMap(Map<String, Object?> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      barcode: map['barcode'] as String?,
      category: map['category'] as String?,
      brand: map['brand'] as String?,
      defaultPurchasePrice: (map['default_purchase_price'] as num?)?.toDouble() ?? 0,
      defaultSellingPrice: (map['default_selling_price'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'category': category,
      'brand': brand,
      'default_purchase_price': defaultPurchasePrice,
      'default_selling_price': defaultSellingPrice,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
