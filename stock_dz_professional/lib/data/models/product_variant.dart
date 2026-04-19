// lib/data/models/product_variant.dart
class ProductVariant {
  final int? id;
  final int productId;
  final String? color;
  final String? size;
  final String? sku;
  final String? barcode;
  final double purchasePrice;
  final double sellingPrice;
  final int stockQty;
  final int reorderLevel;

  ProductVariant({
    this.id,
    required this.productId,
    this.color,
    this.size,
    this.sku,
    this.barcode,
    this.purchasePrice = 0,
    this.sellingPrice = 0,
    this.stockQty = 0,
    this.reorderLevel = 0,
  });

  ProductVariant copyWith({
    int? id,
    int? productId,
    String? color,
    String? size,
    String? sku,
    String? barcode,
    double? purchasePrice,
    double? sellingPrice,
    int? stockQty,
    int? reorderLevel,
  }) {
    return ProductVariant(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      color: color ?? this.color,
      size: size ?? this.size,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stockQty: stockQty ?? this.stockQty,
      reorderLevel: reorderLevel ?? this.reorderLevel,
    );
  }

  factory ProductVariant.fromMap(Map<String, Object?> map) {
    return ProductVariant(
      id: map['id'] as int?,
      productId: map['product_id'] as int,
      color: map['color'] as String?,
      size: map['size'] as String?,
      sku: map['sku'] as String?,
      barcode: map['barcode'] as String?,
      purchasePrice: (map['purchase_price'] as num?)?.toDouble() ?? 0,
      sellingPrice: (map['selling_price'] as num?)?.toDouble() ?? 0,
      stockQty: (map['stock_qty'] as num?)?.toInt() ?? 0,
      reorderLevel: (map['reorder_level'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'color': color,
      'size': size,
      'sku': sku,
      'barcode': barcode,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'stock_qty': stockQty,
      'reorder_level': reorderLevel,
    };
  }
}
