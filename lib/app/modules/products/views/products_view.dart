import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qr_code_new/app/data/models/productModels.dart';
import 'package:qr_code_new/app/routes/app_pages.dart';

import '../controllers/products_controller.dart';
import '../views/floating_search_bar.dart';

class ProductsView extends GetView<ProductsController> {
  const ProductsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProductsController productsController = Get.put(ProductsController());

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: productsController.streamProduct(),
          builder: (context, snapProduct) {
            if (snapProduct.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapProduct.hasError) {
              return Center(
                child: Text("Error: ${snapProduct.error}"),
              );
            }

            if (snapProduct.data == null || snapProduct.data!.docs.isEmpty) {
              return const Center(
                child: Text("No Product"),
              );
            }

            List<ProductModels> allproduct = [];
            for (var element in snapProduct.data!.docs) {
              allproduct.add(ProductModels.fromJson(element.data()));
            }

            // Stack: Search bar floating di atas list produk
            return Stack(
              children: [
                // Main Body - List Produk
                Column(
                  children: [
                    // Tombol Sort
                    Obx(
                      () => Padding(
                        padding: const EdgeInsets.only(
                            left: 20, top: 70, bottom: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              productsController.toggleSort();
                            },
                            icon: Icon(
                              productsController.isSorted.value
                                  ? Icons.sort_by_alpha
                                  : Icons.unfold_more,
                              size: 18,
                            ),
                            label: Text(
                              productsController.isSorted.value
                                  ? 'Sorted'
                                  : 'Sort A-Z',
                              style: const TextStyle(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: productsController.isSorted.value
                                  ? Colors.blue
                                  : Colors.grey[300],
                              foregroundColor: productsController.isSorted.value
                                  ? Colors.white
                                  : Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // List Products
                    Expanded(
                      child: Obx(
                        () {
                          List<ProductModels> processedProducts =
                              productsController
                                  .getProcessedProducts(allproduct);

                          // FIX: Tampilkan semua produk jika query kosong
                          if (processedProducts.isEmpty &&
                              productsController.query.value.isEmpty) {
                            processedProducts = allproduct;
                            if (productsController.isSorted.value) {
                              processedProducts
                                  .sort((a, b) => a.name.compareTo(b.name));
                            }
                          }

                          if (processedProducts.isEmpty) {
                            return Center(
                              child: Text(
                                productsController.query.value.isEmpty
                                    ? "No Product"
                                    : 'No products found for "${productsController.query.value}"',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: processedProducts.length,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            itemBuilder: (context, index) {
                              ProductModels product = processedProducts[index];
                              return Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                margin: const EdgeInsets.only(bottom: 20),
                                child: InkWell(
                                  onTap: () {
                                    Get.toNamed(Routes.DETAIL_PRODUCTS,
                                        arguments: product);
                                  },
                                  borderRadius: BorderRadius.circular(9),
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product.code,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(height: 5),
                                              Text("Nama : ${product.name}"),
                                              const SizedBox(height: 7),
                                              Text(
                                                  "RH Product : ${product.rh}"),
                                              Text(
                                                  "Tanggal Exp : ${DateFormat('dd MMMM yyyy').format(product.expDate)}"),
                                              Text(
                                                  "Tanggal Rilis : ${DateFormat.yMMMEd().format(product.tanggalRilis)}"),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 50,
                                          width: 50,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.red,
                                                    width: 2.0),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.5),
                                                    spreadRadius: 2,
                                                    blurRadius: 5,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Image.network(
                                                product.file_url,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return const Icon(
                                                      Icons.error);
                                                },
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                // Floating Search Bar Widget (Terpisah)
                FloatingSearchBarModel(
                  allProducts: allproduct,
                  controller: productsController,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
