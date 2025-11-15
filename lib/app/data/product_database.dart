import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../data/models/productMaster.dart';

class ProductDatabase {
  static final ProductDatabase instance = ProductDatabase._init();
  static Database? _database;

  ProductDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('products.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE products (
        id $idType,
        barcode $textType UNIQUE,
        name $textType,
        rh $integerType
      )
    ''');

    // Create index untuk pencarian cepat berdasarkan barcode
    await db.execute('''
      CREATE INDEX idx_barcode ON products(barcode)
    ''');

    print('Database and table created with index');
  }

  // ============================================
  // INSERT OPERATIONS
  // ============================================

  // Insert single product
  Future<ProductMaster> insertProduct(ProductMaster product) async {
    final db = await database;
    final id = await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return product.copyWith(id: id);
  }

  // Bulk insert (untuk 11k products)
  Future<void> insertProducts(List<ProductMaster> products) async {
    final db = await database;
    final batch = db.batch();

    for (var product in products) {
      batch.insert(
        'products',
        product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    print('Bulk insert completed: ${products.length} products');
  }

  // ============================================
  // READ OPERATIONS
  // ============================================

  // Find by barcode (SUPER CEPAT dengan index!)
  Future<ProductMaster?> findByBarcode(String barcode) async {
    final db = await database;

    final maps = await db.query(
      'products',
      where: 'barcode = ?',
      whereArgs: [barcode],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return ProductMaster.fromMap(maps.first);
    }
    return null;
  }

  // Get all products
  Future<List<ProductMaster>> getAllProducts() async {
    final db = await database;
    final result = await db.query('products', orderBy: 'name ASC');
    return result.map((map) => ProductMaster.fromMap(map)).toList();
  }

  // Get total count
  Future<int> getProductCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM products');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Search by name (optional, untuk autocomplete)
  Future<List<ProductMaster>> searchByName(String keyword) async {
    final db = await database;

    final maps = await db.query(
      'products',
      where: 'name LIKE ?',
      whereArgs: ['%$keyword%'],
      limit: 20,
    );

    return maps.map((map) => ProductMaster.fromMap(map)).toList();
  }

  // ============================================
  // UPDATE OPERATIONS
  // ============================================

  Future<int> updateProduct(ProductMaster product) async {
    final db = await database;
    return db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // ============================================
  // DELETE OPERATIONS
  // ============================================

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Clear all products (untuk refresh data)
  Future<void> clearAllProducts() async {
    final db = await database;
    await db.delete('products');
    print('All products cleared');
  }

  // ============================================
  // DATABASE MANAGEMENT
  // ============================================

  // Close database
  Future<void> close() async {
    final db = await database;
    db.close();
  }

  // Delete database (reset semua)
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'products.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
    print('Database deleted');
  }
}

// Extension untuk copyWith
extension ProductMasterExtension on ProductMaster {
  ProductMaster copyWith({
    int? id,
    String? barcode,
    String? name,
    int? rh,
  }) {
    return ProductMaster(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      rh: rh ?? this.rh,
    );
  }
}
