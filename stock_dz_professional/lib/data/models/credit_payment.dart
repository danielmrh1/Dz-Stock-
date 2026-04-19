// lib/data/models/credit_payment.dart
class CreditPayment {
  final int? id;
  final int creditId;
  final double amount;
  final DateTime date;
  final String? method;
  final String? note;

  CreditPayment({
    this.id,
    required this.creditId,
    required this.amount,
    DateTime? date,
    this.method,
    this.note,
  }) : date = date ?? DateTime.now();

  factory CreditPayment.fromMap(Map<String, Object?> map) {
    return CreditPayment(
      id: map['id'] as int?,
      creditId: map['credit_id'] as int,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      method: map['method'] as String?,
      note: map['note'] as String?,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'credit_id': creditId,
        'amount': amount,
        'date': date.toIso8601String(),
        'method': method,
        'note': note,
      };
}
