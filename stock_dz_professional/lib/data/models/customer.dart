// lib/data/models/customer.dart
class Customer {
  final int? id;
  final String name;
  final String? phone;
  final String? notes;

  Customer({
    this.id,
    required this.name,
    this.phone,
    this.notes,
  });

  factory Customer.fromMap(Map<String, Object?> map) {
    return Customer(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      notes: map['notes'] as String?,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'notes': notes,
      };
}
