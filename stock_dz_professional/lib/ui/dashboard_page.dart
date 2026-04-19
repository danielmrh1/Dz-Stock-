import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:fl_chart/fl_chart.dart'; 
import 'package:intl/intl.dart';        
import 'product_list_page.dart';
import 'dart:io';
import '../models.dart'; 
import '../database_service.dart'; 

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Stock DZ Pro', 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black), 
            onPressed: _refresh,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildHeaderStats(),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildMenuCard(context, 'نقطة البيع (POS)', Icons.shopping_basket, const Color(0xFF4CAF50), () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AdvancedSalesPage())).then((_) => _refresh());
                  }),
                  _buildMenuCard(context, 'إدارة المخزن', Icons.inventory, const Color(0xFFFF9800), () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductListPage())).then((_) => _refresh());
                  }),
                  _buildMenuCard(context, 'التحليل المالي', Icons.analytics, const Color(0xFF9C27B0), () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportsPage())).then((_) => _refresh());
                  }),
                  _buildMenuCard(context, 'حول النظام', Icons.info_outline, const Color(0xFF607D8B), () {
                    _showAboutDialog(context);
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStats() {
    double todaySales = AppData.salesHistory
        .where((s) => s.date.day == DateTime.now().day && s.date.month == DateTime.now().month)
        .fold(0, (sum, item) => sum + item.price);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("إجمالي مبيعات اليوم", style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 5),
            Text("${todaySales.toStringAsFixed(0)} دج", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ]),
          const Icon(Icons.trending_up, color: Colors.greenAccent, size: 45),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, size: 35, color: color)),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(context: context, applicationName: "Stock DZ Pro", applicationVersion: "1.0.8");
  }
}

// --- صفحة البيع المتقدمة الجديدة ---
class AdvancedSalesPage extends StatefulWidget {
  const AdvancedSalesPage({super.key});
  @override
  State<AdvancedSalesPage> createState() => _AdvancedSalesPageState();
}

class _AdvancedSalesPageState extends State<AdvancedSalesPage> {
  List<Map<String, dynamic>> cart = [];
  String searchQuery = "";
  final TextEditingController searchController = TextEditingController();

  void _addToCart(Product product, String variantKey, double finalPrice) {
    setState(() {
      cart.add({
        'product': product,
        'variant': variantKey,
        'price': finalPrice,
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("تمت إضافة ${product.name} للسلة"),
      duration: const Duration(seconds: 1),
    ));
  }

  void _confirmFinalSale() {
    if (cart.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد العملية"),
        content: Text("هل أنت متأكد من بيع ${cart.length} قطع؟"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                for (var item in cart) {
                  Product p = item['product'];
                  String variant = item['variant'];
                  p.inventory[variant] = p.inventory[variant]! - 1;

                  AppData.salesHistory.insert(0, SaleRecord(
                    productName: p.name,
                    variant: variant,
                    price: item['price'],
                    profit: item['price'] - p.buyPrice,
                    date: DateTime.now(),
                  ));
                }
                cart.clear();
              });
              DatabaseService.saveData();
              Navigator.pop(context); // إغلاق الديالوج
              Navigator.pop(context); // العودة للرئيسية
            },
            child: const Text("تأكيد البيع"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalCart = cart.fold(0, (sum, item) => sum + item['price']);

    // تصفية المنتجات بناءً على البحث
    List<Product> searchResults = AppData.globalProducts.where((p) {
      final query = searchQuery.toLowerCase();
      return p.name.toLowerCase().contains(query) || p.barcode.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("نقطة البيع")),
      body: Column(
        children: [
          // 1. منطقة البحث اليدوي والباركود
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: "ابحث بالاسم أو الباركود...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.blue, size: 30),
                  onPressed: _openScanner,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
          ),

          // 2. نتائج البحث (تظهر فقط عند الكتابة)
          if (searchQuery.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final p = searchResults[index];
                  return ListTile(
                    leading: const Icon(Icons.add_circle_outline, color: Colors.green),
                    title: Text(p.name),
                    subtitle: Text("${p.sellPrice} دج"),
                    onTap: () {
                      searchController.clear();
                      setState(() => searchQuery = "");
                      _showVariantPicker(p);
                    },
                  );
                },
              ),
            ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [Icon(Icons.shopping_cart_outlined, size: 18), SizedBox(width: 8), Text("سلة المبيعات الحالية", style: TextStyle(fontWeight: FontWeight.bold))]),
          ),
          
          // 3. عرض السلة
          Expanded(
            child: cart.isEmpty
                ? Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_basket_outlined, size: 60, color: Colors.grey[300]),
                      const Text("ابدأ بإضافة المنتجات للبيع", style: TextStyle(color: Colors.grey)),
                    ],
                  ))
                : ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
                        child: ListTile(
                          title: Text(item['product'].name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("المقاس: ${item['variant'].split('_')[0]}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("${item['price']} دج", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: () => setState(() => cart.removeAt(index))),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // 4. شريط الإجمالي والتأكيد
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    const Text("الإجمالي المستحق", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text("${totalCart.toStringAsFixed(0)} دج", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                  ]),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: cart.isEmpty ? null : _confirmFinalSale,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text("تأكيد وخصم من المخزن", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openScanner() {
    showDialog(
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('اسحب الباركود')),
        body: MobileScanner(
          onDetect: (capture) {
            final code = capture.barcodes.first.rawValue;
            if (code != null) {
              Navigator.pop(context);
              final pIndex = AppData.globalProducts.indexWhere((p) => p.barcode == code);
              if (pIndex != -1) {
                _showVariantPicker(AppData.globalProducts[pIndex]);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("هذا المنتج غير مسجل!")));
              }
            }
          },
        ),
      ),
    );
  }

  void _showVariantPicker(Product p) {
    final priceController = TextEditingController(text: p.sellPrice.toString());
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (p.imagePath != null && File(p.imagePath!).existsSync())
                ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(File(p.imagePath!), height: 100, width: 100, fit: BoxFit.cover)),
              const SizedBox(height: 10),
              Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Divider(),
              const Text("تعديل سعر البيع لهذا الزبون (المساعدة):", style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 5),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                decoration: InputDecoration(
                  suffixText: "دج",
                  filled: true,
                  fillColor: Colors.green.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              const Text("اختر المقاس المتوفر:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: p.inventory.entries.where((e) => e.value > 0).map((e) {
                  var parts = e.key.split('_');
                  Color c = parts.length > 1 ? Color(int.parse(parts[1])) : Colors.blue;
                  return ActionChip(
                    avatar: CircleAvatar(backgroundColor: c, radius: 8),
                    label: Text("${parts[0]} (${e.value})"),
                    onPressed: () {
                      double finalPrice = double.tryParse(priceController.text) ?? p.sellPrice;
                      _addToCart(p, e.key, finalPrice);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// --- صفحة التقارير ---
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});
  @override State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("التحليل المالي")),
      body: const Center(child: Text("هنا تظهر تقارير الأرباح والمبيعات")),
    );
  }
}