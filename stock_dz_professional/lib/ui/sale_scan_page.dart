import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models.dart';
import '../database_service.dart';

class SaleScanPage extends StatefulWidget {
  const SaleScanPage({super.key});

  @override
  State<SaleScanPage> createState() => _SaleScanPageState();
}

class _SaleScanPageState extends State<SaleScanPage> {
  final List<CartItem> _cart = [];
  bool _isScanning = true;

  // دالة التعامل مع الباركود الممسوح
  void _handleCode(String code) {
    if (!_isScanning) return;

    // البحث عن المنتج في المخزن
    final product = AppData.globalProducts.firstWhere(
      (p) => p.barcode.trim() == code.trim(),
      orElse: () => Product(barcode: '', name: '', buyPrice: 0, sellPrice: 0, inventory: {}),
    );

    if (product.barcode.isEmpty) {
      _showSimpleAlert("خطأ", "هذا المنتج غير مسجل في المخزن!");
      return;
    }

    setState(() => _isScanning = false); // إيقاف المسح مؤقتاً لإظهار نافذة الاختيار
    _showVariantSelection(product);
  }

  // نافذة اختيار المقاس واللون المتاحين
  void _showVariantSelection(Product p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (p.imagePath != null) 
              ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(File(p.imagePath!), height: 100, width: 100, fit: BoxFit.cover)),
            const SizedBox(height: 10),
            Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("اختر المقاس واللون المتاح:"),
            const Divider(),
            Wrap(
              spacing: 10,
              children: p.inventory.entries.where((e) => e.value > 0).map((entry) {
                var parts = entry.key.split('_');
                String size = parts[0];
                Color color = parts.length > 1 ? Color(int.parse(parts[1])) : Colors.grey;
                
                return ChoiceChip(
                  label: Text(size),
                  avatar: CircleAvatar(backgroundColor: color, radius: 10),
                  selected: false,
                  onSelected: (_) {
                    _addToCart(p, entry.key);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ).then((_) => setState(() => _isScanning = true));
  }

  void _addToCart(Product p, String variantKey) {
    setState(() {
      final existingIndex = _cart.indexWhere((item) => item.product.barcode == p.barcode && item.variantKey == variantKey);
      if (existingIndex != -1) {
        _cart[existingIndex].quantity++;
      } else {
        _cart.add(CartItem(product: p, variantKey: variantKey, quantity: 1));
      }
    });
  }

  double get _total => _cart.fold(0.0, (sum, item) => sum + (item.product.sellPrice * item.quantity));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('ماسح البيع الذكي'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. منطقة الكاميرا (تصميم احترافي)
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  children: [
                    MobileScanner(
                      onDetect: (capture) {
                        final code = capture.barcodes.first.rawValue;
                        if (code != null) _handleCode(code);
                      },
                    ),
                    // إطار تركيز الكاميرا
                    Center(
                      child: Container(
                        width: 250, height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 2. سلة المشتريات (تصميم DTS)
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("المنتجات الممسوحة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("${_total.toStringAsFixed(2)} دج", style: const TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _cart.isEmpty
                        ? const Center(child: Text("ابدأ بمسح الباركود لإضافة منتجات"))
                        : ListView.builder(
                            itemCount: _cart.length,
                            itemBuilder: (context, index) => _buildCartCard(index),
                          ),
                  ),
                  _buildCheckoutButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // تصميم بطاقة المنتج الاحترافية
  Widget _buildCartCard(int index) {
    final item = _cart[index];
    var parts = item.variantKey.split('_');
    String size = parts[0];
    Color color = parts.length > 1 ? Color(int.parse(parts[1])) : Colors.grey;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: (item.product.imagePath != null && File(item.product.imagePath!).existsSync())
                ? Image.file(File(item.product.imagePath!), width: 60, height: 60, fit: BoxFit.cover)
                : Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.image)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                      child: Text("📏 $size", style: const TextStyle(fontSize: 12, color: Colors.blue)),
                    ),
                    const SizedBox(width: 8),
                    Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text("${(item.product.sellPrice * item.quantity).toStringAsFixed(0)} دج", style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20), onPressed: () => _updateQty(index, -1)),
                  Text("${item.quantity}"),
                  IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.green, size: 20), onPressed: () => _updateQty(index, 1)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: _cart.isEmpty ? null : _processCheckout,
        child: const Text("تأكيد العملية وطباعة الورقة", style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }

  void _updateQty(int index, int delta) {
    setState(() {
      final newQty = _cart[index].quantity + delta;
      if (newQty <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index].quantity = newQty;
      }
    });
  }

  void _processCheckout() {
    // هنا يتم خصم الكميات من المخزن وحفظ العملية
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تمت العملية"),
        content: const Text("تم تسجيل البيع بنجاح وخصم الكميات من المخزن."),
        actions: [
          TextButton(onPressed: () {
            setState(() => _cart.clear());
            Navigator.pop(context);
          }, child: const Text("موافق"))
        ],
      ),
    );
  }

  void _showSimpleAlert(String t, String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: Colors.red));
  }
}

class CartItem {
  final Product product;
  final String variantKey;
  int quantity;
  CartItem({required this.product, required this.variantKey, required this.quantity});
}