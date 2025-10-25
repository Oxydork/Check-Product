import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  State<FloatingSearchBarModel> createState() => _FloatingSearchBarState();
}

class _FloatingSearchBarState extends State<FloatingSearchBarModel> {
  late TextEditingController _searchController;
  late FocusNode _focusNode;
  List<ProductModels> _filteredProducts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filterProducts(String query) {
    setState(() {
      _isLoading = true;
    });

    if (query.isEmpty) {
      setState(() {
        _filteredProducts = [];
        _isLoading = false;
      });
      return;
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      final results = widget.controller.getFilteredProducts(
        widget.allProducts,
        query,
      );
      setState(() {
        _filteredProducts = results;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      left: 16,
      right: 16,
      child: Column(
        children: [
          // Search Bar dengan Back Button
          Row(
            children: [
              // Back Button
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.grey[700],
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Search TextField
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  onChanged: (value) {
                    widget.controller.updateQuery(value);
                    _filterProducts(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                        width: 0.5,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              widget.controller.updateQuery('');
                              setState(() {
                                _filteredProducts = [];
                              });
                            },
                            child: Icon(Icons.clear, color: Colors.grey[400]),
                          )
                        : null,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                        width: 0.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Suggestions Dropdown
          if (_searchController.text.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _isLoading
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: SizedBox(
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue.shade300,
                          ),
                        ),
                      ),
                    )
                  : _filteredProducts.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No products found for "${_searchController.text}"',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
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
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      product.file_url,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
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
                                  _searchController.text = product.name;
                                  print(
                                      "Selected from search: ${product.name}");
                                  Get.toNamed(Routes.DETAIL_PRODUCTS,
                                      arguments: product);
                                  _focusNode.unfocus();
                                  setState(() {
                                    _filteredProducts = [];
                                  });
                                },
                              ),
                            );
                          },
                        ),
            ),
        ],
      ),
    );
  }
}
