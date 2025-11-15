import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

import '../controllers/product_controller.dart';

class AddProductView extends GetView<AddProductController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Product Code Field dengan auto-search
          TextField(
            autocorrect: false,
            controller: controller.codeC,
            keyboardType: TextInputType.number,
            maxLength: 13,
            decoration: InputDecoration(
              labelText: "Product Code",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
              ),
              suffixIcon: IconButton(
                onPressed: () async {
                  await controller.startScanning();
                },
                icon: const Icon(Icons.camera_alt),
              ),
            ),
            onChanged: (value) {
              // Auto-search ketika user mengetik 13 digit
              if (value.length == 13) {
                controller.searchProductByBarcode(value);
              } else if (value.isEmpty) {
                // Clear fields jika barcode dihapus
                controller.nameC.clear();
                controller.rhC.clear();
              }
            },
          ),

          const SizedBox(height: 20),

          // Product Name Field (auto-filled)
          TextField(
            autocorrect: false,
            controller: controller.nameC,
            keyboardType: TextInputType.name,
            readOnly: true,
            decoration: InputDecoration(
              labelText: "Product Name",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // RH Field (auto-filled)
          TextField(
            autocorrect: false,
            controller: controller.rhC,
            readOnly: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "RH",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Exp Date Field
          TextField(
            controller: controller.expC,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Tanggal Exp',
              hintText: 'dd MMM yyyy',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_month_outlined),
            ),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                String formattedDate = DateFormat('dd MMM yyyy').format(picked);
                controller.expC.text = formattedDate;
              }
            },
          ),

          const SizedBox(height: 20),

          // File Upload Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Column(
              children: [
                // Show selected file info
                GetBuilder<AddProductController>(
                  builder: (controller) {
                    return controller.selectedFile != null
                        ? Column(
                            children: [
                              const Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.green,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Selected: ${basename(controller.selectedFile!.path)}",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              TextButton.icon(
                                onPressed: () {
                                  controller.clearSelectedFile();
                                },
                                icon: const Icon(Icons.close, size: 16),
                                label: const Text("Remove"),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          )
                        : const SizedBox();
                  },
                ),

                // Upload Image Button
                GetBuilder<AddProductController>(
                  builder: (controller) {
                    return GestureDetector(
                      onTap: () => controller.showImageSourceDialog(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.file_upload_outlined,
                            size: 50,
                            color: controller.selectedFile != null
                                ? Colors.blue
                                : Colors.greenAccent,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            controller.selectedFile != null
                                ? "Change Picture"
                                : "Upload Picture",
                            style: TextStyle(
                              color: controller.selectedFile != null
                                  ? Colors.blue
                                  : Colors.green,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "(Optional)",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Add Product Button
          ElevatedButton(
            onPressed: () => controller.handleAddProduct(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            child: Obx(
              () => controller.isLoading.isFalse
                  ? const Text(
                      "ADD PRODUCT",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          "Adding Product...",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
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
}
