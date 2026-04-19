// lib/data/db/database_provider.dart
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseProvider {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
    }

    final databaseFactory = databaseFactoryFfi;
    final appDir = await getApplicationDocumentsDirectory();
    final dbDir = Directory(p.join(appDir.path, 'databases'));

    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }

    final dbPath = p.join(dbDir.path, 'stock_dz.db');

    _db = await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await _runInitialMigration(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {},
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON;');
        },
      ),
    );

    return _db!;
  }

  static Future<T> runInTransaction<T>(
    Future<T> Function(Transaction txn) action,
  ) async {
    final db = await database;
    return db.transaction<T>(action);
  }

  static Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }

  static Future<void> _runInitialMigration(Database db) async {
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        notes TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        barcode TEXT,
        category TEXT,
        brand TEXT,
        default_purchase_price REAL DEFAULT 0,
        default_selling_price REAL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE product_variants (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        color TEXT,
        size TEXT,
        sku TEXT UNIQUE,
        barcode TEXT,
        purchase_price REAL DEFAULT 0,
        selling_price REAL DEFAULT 0,
        stock_qty INTEGER DEFAULT 0,
        reorder_level INTEGER DEFAULT 0,
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
      );
    ''');

    await db.execute(
      'CREATE INDEX idx_variants_product_id ON product_variants(product_id);',
    );

    await db.execute('''
      CREATE TABLE series_batches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        label TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE series_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        series_id INTEGER NOT NULL,
        variant_id INTEGER NOT NULL,
        qty INTEGER NOT NULL,
        FOREIGN KEY (series_id) REFERENCES series_batches(id) ON DELETE CASCADE,
        FOREIGN KEY (variant_id) REFERENCES product_variants(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        customer_id INTEGER,
        total REAL NOT NULL,
        profit REAL NOT NULL,
        payment_type TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (customer_id) REFERENCES customers(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        variant_id INTEGER NOT NULL,
        qty INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        purchase_price_at_sale REAL NOT NULL,
        line_total REAL NOT NULL,
        line_profit REAL NOT NULL,
        FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE,
        FOREIGN KEY (variant_id) REFERENCES product_variants(id)
      );
    ''');

    await db.execute(
      'CREATE INDEX idx_sale_items_sale_id ON sale_items(sale_id);',
    );
    await db.execute(
      'CREATE INDEX idx_sale_items_variant_id ON sale_items(variant_id);',
    );

    await db.execute('''
      CREATE TABLE credits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        sale_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        paid_amount REAL NOT NULL,
        balance REAL NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES customers(id),
        FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE
      );
    ''');

    await db.execute(
      'CREATE INDEX idx_credits_customer_id ON credits(customer_id);',
    );
    await db.execute(
      'CREATE INDEX idx_credits_sale_id ON credits(sale_id);',
    );

    await db.execute('''
      CREATE TABLE credit_payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        credit_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        method TEXT,
        note TEXT,
        FOREIGN KEY (credit_id) REFERENCES credits(id) ON DELETE CASCADE
      );
    ''');

    await db.execute(
      'CREATE INDEX idx_credit_payments_credit_id ON credit_payments(credit_id);',
    );
  }
}