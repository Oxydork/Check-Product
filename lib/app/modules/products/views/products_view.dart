import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:qr_code_new/app/data/models/productModels.dart';
import 'package:qr_code_new/app/routes/app_pages.dart';

import '../controllers/products_controller.dart';

class ProductsView extends GetView<ProductsController> {
  const ProductsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProductsController controller = Get.put(ProductsController());

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: FloatingSearchBarExample(controller: controller),
      ),
    );
  }
}

class FloatingSearchBarExample extends StatefulWidget {
  final ProductsController controller;

  FloatingSearchBarExample({required this.controller});

  @override
  _FloatingSearchBarExampleState createState() =>
      _FloatingSearchBarExampleState();
}

class _FloatingSearchBarExampleState extends State<FloatingSearchBarExample> {
  String query = "";

  @override
  Widget build(BuildContext context) {
    return FloatingSearchBar(
      hint: 'Search...',
      openAxisAlignment: 0.0,
      scrollPadding: EdgeInsets.only(top: 16, bottom: 56),
      elevation: 4.0,
      onQueryChanged: (searchQuery) {
        setState(() {
          query = searchQuery;
          print("Query Updated : $query");
        });
      },
      transitionCurve: Curves.easeInOut,
      transitionDuration: Duration(milliseconds: 500),
      transition: CircularFloatingSearchBarTransition(),
      physics: BouncingScrollPhysics(),
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: Colors.accents.map((color) {
                return Container(
                  height: 112,
                  color: color,
                );
              }).toList(),
            ),
          ),
        );
      },
      body: Padding(
        padding: const EdgeInsets.only(top: 70),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: widget.controller.streamProduct(),
          builder: (context, snapProduct) {
            if (snapProduct.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapProduct.data!.docs.isEmpty) {
              return const Center(
                child: Text("No Product"),
              );
            }

            List<ProductModels> allproduct = [];
            for (var element in snapProduct.data!.docs) {
              allproduct.add(ProductModels.fromJson(element.data()));
            }

            // Filter products based on search query
            List<ProductModels> filteredProducts = allproduct.where((product) {
              return product.name.toLowerCase().contains(query.toLowerCase()) ||
                  product.code.toLowerCase().contains(query.toLowerCase());
            }).toList();
            print("Filter produtc : ${filteredProducts.length}");

            return ListView.builder(
              itemCount: filteredProducts.length,
              padding: const EdgeInsets.all(20),
              itemBuilder: (context, index) {
                ProductModels product = filteredProducts[index];
                print("Display Product : ${product.name}");
                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                  margin: const EdgeInsets.only(bottom: 20),
                  child: InkWell(
                    onTap: () {
                      Get.toNamed(Routes.DETAIL_PRODUCTS, arguments: product);
                    },
                    borderRadius: BorderRadius.circular(9),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.code,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text("Nama : ${product.name}"),
                                const SizedBox(
                                  height: 7,
                                ),
                                Text("RH Product : ${product.rh}"),
                                Text(
                                    "Tanggal Rilis : ${DateFormat.yMMMEd().format(product.tanggalRilis)}"),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 50,
                            width: 50,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.red, width: 2.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Image.network(
                                  product.file_url,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.error);
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
    );
  }
}
