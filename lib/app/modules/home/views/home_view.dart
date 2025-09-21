import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_code_new/app/controllers/auth_controller.dart';
import 'package:qr_code_new/app/routes/app_pages.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({Key? key}) : super(key: key);

  final AuthController authC = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        centerTitle: true,
      ),
      body: GridView.builder(
        itemCount: 4,
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
        ),
        itemBuilder: (context, index) {
          late String title;
          late IconData icon;
          late VoidCallback onTap;
          switch (index) {
            case 0:
              title = "Add Product";
              icon = Icons.post_add_outlined;
              onTap = () => Get.toNamed(Routes.ADD_PRODUCT);
              break;
            case 1:
              title = "List Product";
              icon = Icons.list_alt_outlined;
              onTap = () => Get.toNamed(Routes.PRODUCTS);
              break;
            case 2:
              title = "Barcode";
              icon = Icons.barcode_reader;
              onTap = () async {
                // Ganti dari BarcodeScannerScreen.scanBarcode ke Get.to
                String? barcode = await Get.to(() => _HomeBarcodeScanner());

                if (barcode != null && barcode != "-1" && barcode.isNotEmpty) {
                  //Get data dari firebase searching di product id
                  Map<String, dynamic> hasil =
                      await controller.getProductId(barcode);
                  if (hasil['error'] == false) {
                    Get.toNamed(Routes.DETAIL_PRODUCTS,
                        arguments: hasil["data"]);
                  } else {
                    Get.snackbar(
                      "Error",
                      hasil["message"],
                      duration: const Duration(seconds: 3),
                    );
                  }
                }
              };
              break;
            case 3:
              title = "Catalog-Pdf";
              icon = Icons.document_scanner_outlined;
              onTap = () {
                controller.dowloadCatalog();
              };
              break;
            default:
          }
          return Material(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey.shade300,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    child: Icon(
                      icon,
                      size: 50,
                    ),
                    height: 50,
                    width: 50,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(title),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Map<String, dynamic> hasil = await authC.logout();
          if (hasil["error"] == false) {
            Get.offAllNamed(Routes.LOGIN);
          } else {
            Get.snackbar("Error", hasil["error"]);
          }
        },
        child: const Icon(Icons.logout),
      ),
    );
  }
}

// Scanner page untuk Home
class _HomeBarcodeScanner extends StatefulWidget {
  @override
  _HomeBarcodeScannerState createState() => _HomeBarcodeScannerState();
}

class _HomeBarcodeScannerState extends State<_HomeBarcodeScanner> {
  MobileScannerController controller = MobileScannerController();
  bool isDetected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(result: "-1"), // Return "-1" seperti cancel
        ),
      ),
      body: MobileScanner(
        controller: controller,
        onDetect: (barcodeCapture) {
          if (!isDetected) {
            isDetected = true;
            final List<Barcode> barcodes = barcodeCapture.barcodes;
            if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
              Get.back(result: barcodes.first.rawValue);
            } else {
              Get.back(result: "-1");
            }
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
