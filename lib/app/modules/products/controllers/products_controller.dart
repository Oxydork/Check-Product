import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:qr_code_new/app/data/models/productModels.dart';

class ProductsController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Observable variables
  RxString query = ''.obs;
  RxBool isSorted = false.obs;

  Stream<QuerySnapshot<Map<String, dynamic>>> streamProduct() async* {
    yield* firestore.collection("product").snapshots();
  }

  // Fungsi untuk mendapatkan produk yang difilter
  List<ProductModels> getFilteredProducts(
      List<ProductModels> allProducts, String searchQuery) {
    if (searchQuery.isEmpty) {
      return allProducts;
    }
    return allProducts.where((product) {
      return product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          product.code.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  // Fungsi untuk sort produk ascending berdasarkan huruf pertama
  List<ProductModels> sortProductsAscending(List<ProductModels> products) {
    List<ProductModels> sortedProducts = List.from(products);
    sortedProducts.sort((a, b) => a.name.compareTo(b.name));
    return sortedProducts;
  }

  // Fungsi untuk mendapatkan produk yang sudah difilter dan disort
  List<ProductModels> getProcessedProducts(List<ProductModels> allProducts) {
    List<ProductModels> filteredProducts =
        getFilteredProducts(allProducts, query.value);

    if (isSorted.value) {
      filteredProducts = sortProductsAscending(filteredProducts);
    }

    return filteredProducts;
  }

  // Fungsi untuk update query pencarian
  void updateQuery(String searchQuery) {
    query.value = searchQuery;
    print("Query Updated : $searchQuery");
  }

  // Fungsi untuk toggle sorting
  void toggleSort() {
    isSorted.value = !isSorted.value;
    print("Sort toggled: ${isSorted.value}");
  }
}
