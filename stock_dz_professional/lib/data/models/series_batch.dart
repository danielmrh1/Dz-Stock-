// lib/data/models/series_batch.dart
class SeriesBatch {
  final int? id;
  final int productId;
  final String? label;
  final DateTime createdAt;

  SeriesBatch({
    this.id,
    required this.productId,
    this.label,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory SeriesBatch.fromMap(Map<String, Object?> map) {
    return SeriesBatch(
      id: map['id'] as int?,
      productId: map['product_id'] as int,
      label: map['label'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'product_id': productId,
        'label': label,
        'created_at': createdAt.toIso8601String(),
      };
}

class SeriesItem {
  final int? id;
  final int seriesId;
  final int variantId;
  final int qty;

  SeriesItem({
    this.id,
    required this.seriesId,
    required this.variantId,
    required this.qty,
  });

  factory SeriesItem.fromMap(Map<String, Object?> map) {
    return SeriesItem(
      id: map['id'] as int?,
      seriesId: map['series_id'] as int,
      variantId: map['variant_id'] as int,
      qty: (map['qty'] as num).toInt(),
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'series_id': seriesId,
        'variant_id': variantId,
        'qty': qty,
      };
}
