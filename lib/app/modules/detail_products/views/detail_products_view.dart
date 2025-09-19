import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_new/app/data/models/productModels.dart';

import '../controllers/detail_products_controller.dart';

class DetailProductsView extends GetView<DetailProductsController> {
  final ProductModels product = Get.arguments;

  final TextEditingController codeC = TextEditingController();
  final TextEditingController nameC = TextEditingController();
  final TextEditingController rhC = TextEditingController();
  @override
  Widget build(BuildContext context) {
    codeC.text = product.code;
    nameC.text = product.name;
    rhC.text = product.rh.toString();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Product'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: Image.network(
                  product.file_url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[500],
                      child: const Icon(Icons.error),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          TextField(
            autocorrect: false,
            controller: codeC,
            keyboardType: TextInputType.number,
            readOnly: true,
            maxLength: 13,
            decoration: InputDecoration(
              labelText: "Product Code",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            autocorrect: false,
            controller: nameC,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              labelText: "Product Name",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            autocorrect: false,
            controller: rhC,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "RH Product",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.isLoadingProduct.isFalse) {
                if (nameC.text.isNotEmpty && rhC.text.isNotEmpty) {
                  controller.isLoadingProduct(true);
                  Map<String, dynamic> hasil = await controller.editProduct({
                    "id": product.productId,
                    "name": nameC.text,
                    "returhari": int.tryParse(rhC.text) ?? 0,
                  });
                  controller.isLoadingProduct(false);
                  //kembali kehalaman list product
                  Get.back();

                  //menampilkan pop-up
                  Get.snackbar(
                    hasil["error"] == true ? "Error" : "Finish",
                    hasil["message"],
                    duration: Duration(seconds: 2),
                  );
                } else {
                  Get.snackbar("Error", "Semua data wajib diisi",
                      duration: const Duration(seconds: 2));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
            ),
            child: Obx(
              () => Text(
                controller.isLoadingProduct.isFalse
                    ? "Update Product"
                    : " Loading ....",
                style: TextStyle(
                  color: controller.isLoadingProduct.isFalse
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
          ),
          ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all<Color?>(Colors.white)),
              onPressed: () {
                Get.defaultDialog(
                    title: "Delete Product",
                    middleText: "Apakah Anda Ingin Menghapus Product Ini ?",
                    actions: [
                      OutlinedButton(
                        onPressed: () => Get.back(),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          controller.isLoadingDelete(true);
                          //deleteproduct..
                          Map<String, dynamic> hasil =
                              await controller.deleteProduct(product.productId);
                          controller.isLoadingDelete(false);
                          //kembali ke halaman list product
                          Get.back();
                          Get.back();
                          Get.snackbar(
                            hasil["error"] == true ? "Error" : "Berhasil",
                            hasil["message"],
                            duration: const Duration(seconds: 2),
                          );
                        },
                        child: Obx(() => controller.isLoadingDelete.isFalse
                            ? Text("Delete Product")
                            : SizedBox(
                                height: 15,
                                width: 15,
                                child: CircularProgressIndicator(
                                  color: Colors.red,
                                  strokeWidth: 1,
                                ),
                              )),
                      ),
                    ]);
              },
              child: Text(
                "Delete Product",
                style: TextStyle(color: Colors.red),
              ))
        ],
      ),
    );
  }
}
