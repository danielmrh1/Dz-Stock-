// lib/data/models/credit.dart
class Credit {
  final int? id;
  final int customerId;
  final int saleId;
  final double amount;
  final double paidAmount;
  final double balance;
  final String status;
  final DateTime createdAt;

  Credit({
    this.id,
    required this.customerId,
    required this.saleId,
    required this.amount,
    required this.paidAmount,
    required this.balance,
    required this.status,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Credit.fromMap(Map<String, Object?> map) {
    return Credit(
      id: map['id'] as int?,
      customerId: map['customer_id'] as int,
      saleId: map['sale_id'] as int,
      amount: (map['amount'] as num).toDouble(),
      paidAmount: (map['paid_amount'] as num).toDouble(),
      balance: (map['balance'] as num).toDouble(),
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'customer_id': customerId,
        'sale_id': saleId,
        'amount': amount,
        'paid_amount': paidAmount,
        'balance': balance,
        'status': status,
        'created_at': createdAt.toIso8601String(),
      };
}
