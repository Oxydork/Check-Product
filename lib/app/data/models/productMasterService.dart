import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/productMaster.dart';
import '../product_database.dart';

class ProductMasterService {
  final ProductDatabase _db = ProductDatabase.instance;

  // ============================================
  // INITIALIZATION
  // ============================================

  // Check apakah database sudah terisi
  Future<bool> isDatabaseInitialized() async {
    final count = await _db.getProductCount();
    return count > 0;
  }

  // Initialize database dari JSON file (hanya sekali)
  Future<void> initializeFromJSON() async {
    try {
      print('Loading products from JSON...');

      // Load JSON file
      final String jsonString =
          await rootBundle.loadString('lib/app/assets/product.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      // Convert to ProductMaster list
      final List<ProductMaster> products =
          jsonList.map((json) => ProductMaster.fromJson(json)).toList();

      print('Parsed ${products.length} products from JSON');

      // Clear existing data (optional)
      await _db.clearAllProducts();

      // Insert ke database
      await _db.insertProducts(products);

      final count = await _db.getProductCount();
      print('Database initialized with $count products');
    } catch (e) {
      print('Error initializing from JSON: $e');
      rethrow;
    }
  }

  // Setup awal (panggil di app startup)
  Future<void> setup() async {
    final isInitialized = await isDatabaseInitialized();

    if (!isInitialized) {
      print('Database empty, initializing from JSON...');
      await initializeFromJSON();
    } else {
      final count = await _db.getProductCount();
      print('Database already initialized with $count products');
    }
  }

  // ============================================
  // SEARCH OPERATIONS
  // ============================================

  // Cari product berdasarkan barcode (SUPER CEPAT!)
  Future<ProductMaster?> findByBarcode(String barcode) async {
    try {
      return await _db.findByBarcode(barcode);
    } catch (e) {
      print('Error finding product by barcode: $e');
      return null;
    }
  }

  // Search by name (untuk autocomplete)
  Future<List<ProductMaster>> searchByName(String keyword) async {
    try {
      return await _db.searchByName(keyword);
    } catch (e) {
      print('Error searching by name: $e');
      return [];
    }
  }

  // ============================================
  // GET OPERATIONS
  // ============================================

  // Get all products
  Future<List<ProductMaster>> getAllProducts() async {
    try {
      return await _db.getAllProducts();
    } catch (e) {
      print('Error getting all products: $e');
      return [];
    }
  }

  // Get product count
  Future<int> getProductCount() async {
    try {
      return await _db.getProductCount();
    } catch (e) {
      print('Error getting product count: $e');
      return 0;
    }
  }

  // ============================================
  // REFRESH OPERATIONS
  // ============================================

  // Refresh data dari JSON (jika ada update)
  Future<void> refreshFromJSON() async {
    await initializeFromJSON();
  }

  // ============================================
  // UTILITY
  // ============================================

  // Reset database
  Future<void> resetDatabase() async {
    await _db.deleteDatabase();
    await setup();
  }
}
