import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:qr_code_new/app/data/models/productModels.dart';
import 'package:qr_code_new/app/routes/app_pages.dart';

import '../controllers/products_controller.dart';

class FloatingSearchBarModel extends StatefulWidget {
  final List<ProductModels> allProducts;
  final ProductsController controller;

  const FloatingSearchBarModel({
    Key? key,
    required this.allProducts,
    required this.controller,
  }) : super(key: key);

  @override
  _FloatingSearchBarState createState() => _FloatingSearchBarState();
}

class _FloatingSearchBarState extends State<FloatingSearchBarModel> {
  @override
  Widget build(BuildContext context) {
    return FloatingSearchBar(
      hint: 'Search products...',
      openAxisAlignment: 0.0,
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      elevation: 4.0,
      backgroundColor: Colors.white,
      onQueryChanged: (searchQuery) {
        widget.controller.updateQuery(searchQuery);
      },
      transitionCurve: Curves.easeInOut,
      transitionDuration: const Duration(milliseconds: 500),
      transition: CircularFloatingSearchBarTransition(),
      physics: const BouncingScrollPhysics(),
      actions: [
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: Obx(
              () {
                List<ProductModels> filteredProducts = widget.controller
                    .getFilteredProducts(
                        widget.allProducts, widget.controller.query.value);

                if (widget.controller.query.value.isEmpty) {
                  return Container(
                    height: 60,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, color: Colors.grey[400]),
                        const SizedBox(width: 8),
                        Text(
                          'Start typing to search products...',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                if (filteredProducts.isEmpty) {
                  return Container(
                    height: 60,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, color: Colors.grey[400]),
                        const SizedBox(width: 8),
                        Text(
                          'No products found for "${widget.controller.query.value}"',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      ProductModels product = filteredProducts[index];
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey[300]!,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.grey[100],
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                product.file_url,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey[400],
                                    size: 20,
                                  );
                                },
                              ),
                            ),
                          ),
                          title: Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            product.code,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey[400],
                          ),
                          onTap: () {
                            print("Selected from search: ${product.name}");
                            Get.toNamed(Routes.DETAIL_PRODUCTS,
                                arguments: product);
                            FloatingSearchBar.of(context)?.close();
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
