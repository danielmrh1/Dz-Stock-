import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'models.dart';

class DatabaseService {
  static const String _productsKey = 'products_data';
  static const String _salesKey = 'sales_data';

  // دالة مساعدة لحفظ الصورة في مسار دائم داخل التطبيق
  static Future<String?> saveImagePermanently(String? tempPath) async {
    if (tempPath == null || tempPath.isEmpty) return null;
    
    try {
      final file = File(tempPath);
      if (!await file.exists()) return tempPath; // إذا كانت الصورة محفوظة مسبقاً

      // الحصول على مجلد المستندات الدائم
      final directory = await getApplicationDocumentsDirectory();
      final fileName = path.basename(tempPath);
      final savedImage = await file.copy('${directory.path}/$fileName');
      
      return savedImage.path;
    } catch (e) {
      print("خطأ في حفظ الصورة دائمًا: $e");
      return tempPath;
    }
  }

  // حفظ كل البيانات
  static Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    try {
      // تحويل قائمة المنتجات لنص JSON مع التأكد من أنواع الخرائط
      final productsList = AppData.globalProducts.map((p) => p.toMap()).toList();
      String productsJson = jsonEncode(productsList);
      await prefs.setString(_productsKey, productsJson);

      // تحويل سجل المبيعات لنص JSON
      final salesList = AppData.salesHistory.map((s) => s.toMap()).toList();
      String salesJson = jsonEncode(salesList);
      await prefs.setString(_salesKey, salesJson);
      
      print("تم حفظ البيانات بنجاح ✅");
    } catch (e) {
      print("خطأ أثناء حفظ البيانات: $e");
    }
  }

  // تحميل البيانات عند فتح التطبيق
  static Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    try {
      // تحميل المنتجات
      String? productsJson = prefs.getString(_productsKey);
      if (productsJson != null) {
        List<dynamic> decoded = jsonDecode(productsJson);
        AppData.globalProducts = decoded.map((p) {
          // نقوم بتحويل البيانات إلى Map<String, dynamic> بشكل صريح لتجنب خطأ Subtype
          return Product.fromMap(Map<String, dynamic>.from(p));
        }).toList();
      }

      // تحميل المبيعات
      String? salesJson = prefs.getString(_salesKey);
      if (salesJson != null) {
        List<dynamic> decoded = jsonDecode(salesJson);
        AppData.salesHistory = decoded.map((s) {
          return SaleRecord.fromMap(Map<String, dynamic>.from(s));
        }).toList();
      }
      print("تم تحميل البيانات بنجاح 📥");
    } catch (e) {
      print("خطأ أثناء تحميل البيانات: $e");
    }
  }
}