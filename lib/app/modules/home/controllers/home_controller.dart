import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_code_new/app/data/models/productModels.dart';

class HomeController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  RxList<ProductModels> allproduct = List<ProductModels>.empty().obs;

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
