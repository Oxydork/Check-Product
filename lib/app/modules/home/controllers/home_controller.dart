import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_code_new/app/data/models/productModels.dart';

class HomeController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  RxList<ProductModels> allproduct = List<ProductModels>.empty().obs;

  // Untuk notifikasi expired product
  RxList<ProductNotification> expiredProducts =
      List<ProductNotification>.empty().obs;
  RxBool isLoadingExpired = false.obs;

  // Fungsi untuk mengecek produk yang expired atau mendekati expired
  Future<void> notifExp() async {
    try {
      isLoadingExpired(true);
      var getData = await firestore.collection("product").get();

      List<ProductNotification> notifications = [];
      DateTime now = DateTime.now();

      for (var element in getData.docs) {
        ProductModels product = ProductModels.fromJson(element.data());

        // Hitung tanggal retur (expDate - rh hari)
        DateTime returDate =
            product.expDate.subtract(Duration(days: product.rh));

        // Hitung sisa hari sampai tanggal retur
        int daysUntilReturn = returDate.difference(now).inDays;

        // Hitung sisa hari sampai expDate
        int daysUntilExp = product.expDate.difference(now).inDays;

        // Status 1: Sudah melewati tanggal retur (Orange - Urgent Return)
        if (daysUntilReturn <= 0 && daysUntilExp > 0) {
          notifications.add(
            ProductNotification(
              product: product,
              status: 'Urgent Return',
              statusColor: Colors.orange,
              daysLeft: daysUntilReturn.abs(),
              message:
                  'Produk harus diretur ${daysUntilReturn.abs()} hari yang lalu',
              returDate: returDate,
            ),
          );
        }
        // Status 2: Mendekati tanggal retur (Orange - Warning)
        else if (daysUntilReturn > 0 && daysUntilReturn <= 7) {
          notifications.add(
            ProductNotification(
              product: product,
              status: 'Return Soon',
              statusColor: Colors.orange,
              daysLeft: daysUntilReturn,
              message: 'Tanggal retur tinggal $daysUntilReturn hari',
              returDate: returDate,
            ),
          );
        }
        // Status 3: Sudah expired (Red)
        else if (daysUntilExp < 0) {
          notifications.add(
            ProductNotification(
              product: product,
              status: 'Expired',
              statusColor: Colors.red,
              daysLeft: daysUntilExp.abs(),
              message:
                  'Produk sudah expired ${daysUntilExp.abs()} hari yang lalu',
              expDate: product.expDate,
            ),
          );
        }
        // Status 4: Mendekati tanggal expired (Red - Less than 7 days)
        else if (daysUntilExp >= 0 && daysUntilExp < 7) {
          notifications.add(
            ProductNotification(
              product: product,
              status: 'Expiring Soon',
              statusColor: Colors.red,
              daysLeft: daysUntilExp,
              message: 'Produk akan expired dalam $daysUntilExp hari',
              expDate: product.expDate,
            ),
          );
        }
        // Status 5: Masih aman (Green)
        else {
          // Hanya tambahkan jika user ingin melihat semua produk
          // Bisa dikomentar jika hanya ingin menampilkan yang alert saja
        }
      }

      // Sort berdasarkan urgency (paling urgent di atas)
      notifications.sort((a, b) {
        if (a.status == 'Urgent Return') return -1;
        if (b.status == 'Urgent Return') return 1;
        if (a.status == 'Expired') return -1;
        if (b.status == 'Expired') return 1;
        if (a.status == 'Expiring Soon') return -1;
        if (b.status == 'Expiring Soon') return 1;
        if (a.status == 'Return Soon') return -1;
        if (b.status == 'Return Soon') return 1;
        return 0;
      });

      expiredProducts(notifications);
      isLoadingExpired(false);

      // Tampilkan alert dialog jika ada produk yang perlu perhatian
      if (notifications.isNotEmpty) {
        Future.delayed(Duration(milliseconds: 300), () {
          _showExpiredProductsDialog();
        });
      }
    } catch (e) {
      print("Error checking expired products: $e");
      isLoadingExpired(false);
    }
  }

  // Fungsi untuk menampilkan alert dialog
  void _showExpiredProductsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Expanded(
              child: Text('Notifikasi Produk'),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: expiredProducts.length,
            itemBuilder: (context, index) {
              ProductNotification notification = expiredProducts[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: notification.statusColor,
                      width: 4,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: notification.statusColor.withOpacity(0.1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: notification.statusColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            notification.status,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Kode: ${notification.product.code}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: notification.statusColor,
                      ),
                    ),
                    if (notification.returDate != null)
                      Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          'Retur: ${_formatDate(notification.returDate!)}',
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ),
                    if (notification.expDate != null)
                      Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          'Exp: ${_formatDate(notification.expDate!)}',
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Tutup'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // Helper function untuk format date
  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  void dowloadCatalog() async {
    final pdf = pw.Document();

    var getData = await firestore.collection("product").get();
    //reset all product menghindari double data
    allproduct([]);
    //isi data allprodcuts dari database na
    for (var element in getData.docs) {
      allproduct.add(ProductModels.fromJson(element.data()));
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Center(
            child: pw.Text(
              "Catalog Product",
              style: const pw.TextStyle(fontSize: 24),
            ),
          ),
          pw.SizedBox(height: 15),
          pw.Table(
            border: pw.TableBorder.all(
              color: PdfColor.fromHex("#000000"),
              width: 2,
            ),
            children: [
              pw.TableRow(
                children: [
                  //No
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(15),
                    child: pw.Text(
                      "No",
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  //KodeBarang
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(15),
                    child: pw.Text(
                      "Kode Barang",
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  //NamaBarang
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(15),
                    child: pw.Text(
                      "Nama Product",
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  //retur Hari
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(15),
                    child: pw.Text(
                      "Retur Hari",
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  //barcode
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(15),
                    child: pw.Text(
                      "Barcode",
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              //isi
              ...List.generate(
                allproduct.length,
                (index) {
                  ProductModels products = allproduct[index];
                  return pw.TableRow(
                    children: [
                      //No
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(15),
                        child: pw.Text(
                          "${index + 1}",
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                              fontSize: 12, fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      //KodeBarang
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(15),
                        child: pw.Text(
                          products.code,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                              fontSize: 12, fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      //NamaBarang
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(15),
                        child: pw.Text(
                          products.name,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                              fontSize: 12, fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      //Qty
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(15),
                        child: pw.Text(
                          "${products.rh}",
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                              fontSize: 12, fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      //Barcode
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(15),
                        child: pw.BarcodeWidget(
                            color: PdfColor.fromHex('#000000'),
                            barcode: pw.Barcode.codabar(),
                            data: products.code,
                            height: 50,
                            width: 50),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );

    //simpan file

    Uint8List bytes = await pdf.save();

    //buat simpan file kosong di directori kanda
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/mydocument.pdf');

    //memassukan data bytes ke file kosong
    await file.writeAsBytes(bytes);

    //open pdf

    await OpenFile.open(file.path);
  }

  Future<Map<String, dynamic>> getProductId(String codeBarang) async {
    try {
      //get firebase
      var hasil = await firestore
          .collection("product")
          .where("code", isEqualTo: codeBarang)
          .get();
      //check data
      if (hasil.docs.isEmpty) {
        return {
          "error": true,
          "message": "Tidak ada data product di database",
        };
      }

      Map<String, dynamic> data = hasil.docs.first.data();

      return {
        "error": false,
        "message": "Berhasil Mendapatkan detail product",
        "data": ProductModels.fromJson(data),
      };
    } catch (e) {
      return {
        "error": true,
        "message": "Belum mendapatkan detail product",
      };
    }
  }
}

// Model untuk notification
class ProductNotification {
  final ProductModels product;
  final String status;
  final Color statusColor;
  final int daysLeft;
  final String message;
  final DateTime? returDate;
  final DateTime? expDate;

  ProductNotification({
    required this.product,
    required this.status,
    required this.statusColor,
    required this.daysLeft,
    required this.message,
    this.returDate,
    this.expDate,
  });
}
