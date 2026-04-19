// lib/data/models/sale_item.dart
class SaleItem {
  final int? id;
  final int saleId;
  final int variantId;
  final int qty;
  final double unitPrice;
  final double purchasePriceAtSale;
  final double lineTotal;
  final double lineProfit;

  SaleItem({
    this.id,
    required this.saleId,
    required this.variantId,
    required this.qty,
    required this.unitPrice,
    required this.purchasePriceAtSale,
  })  : lineTotal = unitPrice * qty,
        lineProfit = (unitPrice - purchasePriceAtSale) * qty;

  factory SaleItem.fromMap(Map<String, Object?> map) {
    return SaleItem(
      id: map['id'] as int?,
      saleId: map['sale_id'] as int,
      variantId: map['variant_id'] as int,
      qty: (map['qty'] as num).toInt(),
      unitPrice: (map['unit_price'] as num).toDouble(),
      purchasePriceAtSale: (map['purchase_price_at_sale'] as num).toDouble(),
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'sale_id': saleId,
        'variant_id': variantId,
        'qty': qty,
        'unit_price': unitPrice,
        'purchase_price_at_sale': purchasePriceAtSale,
        'line_total': lineTotal,
        'line_profit': lineProfit,
      };
}
