import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart'; 
import 'package:path/path.dart' as path;           
import '../models.dart';
import '../database_service.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});
  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final barcodeController = TextEditingController();
  final nameController = TextEditingController();
  final buyPriceController = TextEditingController();
  final sellPriceController = TextEditingController();
  final searchController = TextEditingController();
  
  List<Map<String, Object>> sizeInputs = [];
  File? _productImage;
  String _searchQuery = "";

  final List<Color> _colorOptions = [
    Colors.black, Colors.red, Colors.blue, Colors.green, 
    Colors.yellow, Colors.brown, Colors.grey, Colors.white
  ];

  void _scanBarcode(Function setDialogState) {
    showDialog(
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('سكان الباركود')),
        body: MobileScanner(
          onDetect: (capture) {
            final barcode = capture.barcodes.first.rawValue;
            if (barcode != null) {
              barcodeController.text = barcode;
              Navigator.pop(context);
              setDialogState(() {}); 
            }
          },
        ),
      ),
    );
  }

  void _quickCheckStock() {
    showDialog(
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('فحص سريع للمخزون')),
        body: MobileScanner(
          onDetect: (capture) {
            final barcode = capture.barcodes.first.rawValue;
            if (barcode != null) {
              Navigator.pop(context);
              _showQuickResult(barcode.trim());
            }
          },
        ),
      ),
    );
  }

  void _showQuickResult(String barcode) {
    final productIndex = AppData.globalProducts.indexWhere((p) => p.barcode.trim() == barcode);
    if (productIndex == -1) {
      _showSimpleAlert("المنتج غير موجود", "هذا الباركود غير مسجل في النظام.");
      return;
    }
    _showProductDetails(AppData.globalProducts[productIndex]);
  }

  void _saveProduct({Product? existingProduct}) {
    if (nameController.text.isEmpty || barcodeController.text.isEmpty) {
      _showSimpleAlert("تنبيه", "يرجى إدخال اسم المنتج والباركود.");
      return;
    }

    Map<String, int> inv = {};
    for (var input in sizeInputs) {
      String s = (input['size'] as TextEditingController).text.trim();
      int q = int.tryParse((input['qty'] as TextEditingController).text.trim()) ?? 0;
      String key = "${s}_${(input['color'] as Color).value}";
      if (s.isNotEmpty) inv[key] = q;
    }

    setState(() {
      if (existingProduct != null) {
        existingProduct.name = nameController.text.trim();
        existingProduct.barcode = barcodeController.text.trim();
        existingProduct.buyPrice = double.tryParse(buyPriceController.text) ?? 0.0;
        existingProduct.sellPrice = double.tryParse(sellPriceController.text) ?? 0.0;
        existingProduct.inventory = inv;
        // الاحتفاظ بالصورة القديمة إذا لم يتم اختيار واحدة جديدة
        if (_productImage != null) {
          existingProduct.imagePath = _productImage!.path;
        }
      } else {
        AppData.globalProducts.add(Product(
          barcode: barcodeController.text.trim(),
          name: nameController.text.trim(),
          buyPrice: double.tryParse(buyPriceController.text) ?? 0.0,
          sellPrice: double.tryParse(sellPriceController.text) ?? 0.0,
          inventory: inv,
          imagePath: _productImage?.path,
        ));
      }
    });

    DatabaseService.saveData();
    _clearControllers();
    Navigator.pop(context);
  }

  void _clearControllers() {
    barcodeController.clear();
    nameController.clear();
    buyPriceController.clear();
    sellPriceController.clear();
    _productImage = null;
    sizeInputs.clear();
  }

  @override
  Widget build(BuildContext context) {
    List<Product> filteredList = AppData.globalProducts.where((p) {
      return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) || p.barcode.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('إدارة المخزن', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.manage_search, size: 30), onPressed: _quickCheckStock)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: "ابحث بالاسم أو الباركود...", 
                prefixIcon: const Icon(Icons.search, color: Colors.blue), 
                filled: true, 
                fillColor: Colors.white, 
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final p = filteredList[index];
                int totalQty = p.inventory.values.fold(0, (sum, q) => sum + q);
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    onTap: () => _showProductDetails(p),
                    leading: Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: (p.imagePath != null && File(p.imagePath!).existsSync())
                            ? Image.file(File(p.imagePath!), fit: BoxFit.cover)
                            : const Icon(Icons.inventory_2, color: Colors.grey, size: 30),
                      ),
                    ),
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4), // ✅ تم إصلاح الخطأ هنا
                      child: Text("المخزون: $totalQty قطعة", style: TextStyle(color: totalQty > 0 ? Colors.green : Colors.red)),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(), 
        label: const Text("إضافة موديل"), 
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showProductDetails(Product p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            if (p.imagePath != null && File(p.imagePath!).existsSync()) 
              ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.file(File(p.imagePath!), height: 200, width: double.infinity, fit: BoxFit.cover)),
            const SizedBox(height: 20),
            Text(p.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("السعر: ${p.sellPrice} دج", style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)),
            const Divider(height: 30),
            ...p.inventory.entries.map((e) {
              var parts = e.key.split('_');
              Color c = parts.length > 1 ? Color(int.parse(parts[1])) : Colors.grey;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(Icons.circle, color: c),
                  title: Text("المقاس: ${parts[0]}"),
                  trailing: Text("الكمية: ${e.value}", style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: () { Navigator.pop(context); _showAddDialog(existingProduct: p); }, 
              icon: const Icon(Icons.edit),
              label: const Text("تعديل البيانات")
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showAddDialog({Product? existingProduct}) {
    if (existingProduct != null) {
      nameController.text = existingProduct.name;
      barcodeController.text = existingProduct.barcode;
      buyPriceController.text = existingProduct.buyPrice.toString();
      sellPriceController.text = existingProduct.sellPrice.toString();
      _productImage = existingProduct.imagePath != null ? File(existingProduct.imagePath!) : null;
      
      sizeInputs = existingProduct.inventory.entries.map((e) {
        var parts = e.key.split('_');
        return {
          'size': TextEditingController(text: parts[0]),
          'qty': TextEditingController(text: e.value.toString()),
          'color': parts.length > 1 ? Color(int.parse(parts[1])) : Colors.blue,
        };
      }).toList();
    } else {
      _clearControllers();
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(existingProduct == null ? 'إضافة موديل' : 'تعديل موديل'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildImagePicker(setDialogState),
                  TextField(controller: barcodeController, decoration: InputDecoration(labelText: 'الباركود', suffixIcon: IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: () => _scanBarcode(setDialogState)))),
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم الموديل')),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: buyPriceController, decoration: const InputDecoration(labelText: 'شراء'), keyboardType: TextInputType.number)),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: sellPriceController, decoration: const InputDecoration(labelText: 'بيع'), keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...sizeInputs.asMap().entries.map((e) {
                    int idx = e.key;
                    return Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showColorPicker(setDialogState, idx),
                          child: CircleAvatar(backgroundColor: sizeInputs[idx]['color'] as Color, radius: 15),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: e.value['size'] as TextEditingController, decoration: const InputDecoration(hintText: 'مقاس'))),
                        const SizedBox(width: 5),
                        Expanded(child: TextField(controller: e.value['qty'] as TextEditingController, decoration: const InputDecoration(hintText: 'كمية'), keyboardType: TextInputType.number)),
                        IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), onPressed: () => setDialogState(() => sizeInputs.removeAt(idx))),
                      ],
                    );
                  }).toList(),
                  TextButton.icon(onPressed: () => setDialogState(() => sizeInputs.add({'size': TextEditingController(), 'qty': TextEditingController(), 'color': Colors.blue})), icon: const Icon(Icons.add), label: const Text("إضافة مقاس")),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
            ElevatedButton(onPressed: () => _saveProduct(existingProduct: existingProduct), child: const Text("حفظ")),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(Function setDialogState, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("اختر اللون"),
        content: Wrap(
          spacing: 10,
          children: _colorOptions.map((c) => GestureDetector(
            onTap: () { setDialogState(() { sizeInputs[index]['color'] = c; }); Navigator.pop(context); },
            child: CircleAvatar(backgroundColor: c, radius: 20),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildImagePicker(Function setStateInDialog) {
    return GestureDetector(
      onTap: () async {
        final img = await ImagePicker().pickImage(source: ImageSource.camera);
        if (img != null) { 
          final directory = await getApplicationDocumentsDirectory();
          final fileName = path.basename(img.path);
          final File localImage = await File(img.path).copy('${directory.path}/$fileName');
          setState(() { _productImage = localImage; }); 
          setStateInDialog(() {}); 
        }
      },
      child: Container(
        height: 120, width: double.infinity, 
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)), 
        child: (_productImage == null || !_productImage!.existsSync()) 
            ? const Icon(Icons.camera_alt, size: 40) 
            : ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(_productImage!, fit: BoxFit.cover))
      ),
    );
  }

  void _showSimpleAlert(String t, String m) {
    showDialog(context: context, builder: (c) => AlertDialog(title: Text(t), content: Text(m), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("موافق"))]));
  }
}