import 'dart:convert';

class Product {
  String barcode;
  String name;
  double buyPrice;
  double sellPrice;
  // المخزون سيبقى Map، لكن المفتاح سيكون "المقاس_قيمةاللون"
  Map<String, int> inventory; 
  String? imagePath;

  Product({
    required this.barcode,
    required this.name,
    required this.buyPrice,
    required this.sellPrice,
    required this.inventory,
    this.imagePath,
  });

  // تحويل المنتج إلى Map لحفظه (JSON)
  // تم تحديث inventory لضمان تحويلها لـ Map صريحة عند الحفظ
  Map<String, dynamic> toMap() => {
    'barcode': barcode,
    'name': name,
    'buyPrice': buyPrice,
    'sellPrice': sellPrice,
    'inventory': Map<String, int>.from(inventory),
    'imagePath': imagePath,
  };

  // استعادة المنتج مع معالجة أخطاء الأنواع (Type Casting)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      barcode: map['barcode']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      // استخدام .toDouble() مع num لضمان عدم حدوث خطأ إذا كان الرقم صحيحاً أو عشرياً
      buyPrice: (map['buyPrice'] as num? ?? 0.0).toDouble(),
      sellPrice: (map['sellPrice'] as num? ?? 0.0).toDouble(),
      // تحويل آمن للـ Inventory لتجنب خطأ subtype of type Map
      inventory: (map['inventory'] as Map? ?? {}).map(
        (k, v) => MapEntry(k.toString(), (v as num? ?? 0).toInt()),
      ),
      imagePath: map['imagePath'],
    );
  }
}

class SaleRecord {
  final String productName;
  final String variant; 
  final double price;
  final double profit;
  final DateTime date;

  SaleRecord({
    required this.productName,
    required this.variant,
    required this.price,
    required this.profit,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'productName': productName,
    'variant': variant,
    'price': price,
    'profit': profit,
    'date': date.toIso8601String(),
  };

  factory SaleRecord.fromMap(Map<String, dynamic> map) => SaleRecord(
    productName: map['productName']?.toString() ?? 'منتج غير معروف',
    variant: map['variant']?.toString() ?? '',
    price: (map['price'] as num? ?? 0.0).toDouble(),
    profit: (map['profit'] as num? ?? 0.0).toDouble(),
    date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
  );
}

class AppData {
  static List<Product> globalProducts = [];
  static List<SaleRecord> salesHistory = [];

  static double get totalSales => salesHistory.fold(0, (sum, item) => sum + item.price);
  static double get totalProfit => salesHistory.fold(0, (sum, item) => sum + item.profit);
}