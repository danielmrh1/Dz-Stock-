// lib/data/models/sale.dart
class Sale {
  final int? id;
  final DateTime date;
  final int? customerId;
  final double total;
  final double profit;
  final String paymentType;
  final String? notes;

  Sale({
    this.id,
    DateTime? date,
    this.customerId,
    required this.total,
    required this.profit,
    required this.paymentType,
    this.notes,
  }) : date = date ?? DateTime.now();

  factory Sale.fromMap(Map<String, Object?> map) {
    return Sale(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      customerId: map['customer_id'] as int?,
      total: (map['total'] as num).toDouble(),
      profit: (map['profit'] as num).toDouble(),
      paymentType: map['payment_type'] as String,
      notes: map['notes'] as String?,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'customer_id': customerId,
        'total': total,
        'profit': profit,
        'payment_type': paymentType,
        'notes': notes,
      };
}
