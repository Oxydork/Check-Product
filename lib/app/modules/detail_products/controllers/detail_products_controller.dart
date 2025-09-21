import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailProductsController extends GetxController {
  RxBool isLoadingProduct = false.obs;
  RxBool isLoadingDelete = false.obs;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> editProduct(Map<String, dynamic> data) async {
    try {
      await firestore.collection("product").doc(data["id"]).update({
        "name": data["name"],
        "qty": data["qty"],
      });
      return {
        "error": false,
        "message": "Berhasil Update Product",
      };
    } catch (e) {
      return {
        "error": true,
        "message": "Tidak dapat mengupdate product",
      };
    }
  }

  Future<Map<String, dynamic>> deleteProduct(String productId) async {
    try {
      // Mengambil dokumen produk dari Firestore untuk mendapatkan URL gambar
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("product")
          .doc(productId)
          .get();

      if (!doc.exists) {
        return {
          "error": true,
          "message": "Produk tidak ditemukan",
        };
      }

      // Mendapatkan URL gambar dari dokumen
      String? imageUrl = doc['file_url'];
      String? filename =
          imageUrl?.split('/').last; // Mengambil nama file dari URL

      // Menghapus dokumen dari Firestore
      await FirebaseFirestore.instance
          .collection("product")
          .doc(productId)
          .delete();

      // Menghapus file dari Supabase Storage jika ada versi supabase lama
      // if (filename != null) {
      //   final response = await Supabase.instance.client.storage
      //       .from('product')
      //       .remove([filename]);

      //   if (response.error != null) {
      //     throw Exception('Gagal menghapus gambar: ${response.error!.message}');
      //   }
      // }

      // Menghapus file dari Supabase Storage jika ada versi supabase baru
      if (filename != null) {
        try {
          await Supabase.instance.client.storage
              .from('product')
              .remove([filename]);

          print('File berhasil dihapus dari storage: $filename');
        } catch (error) {
          throw Exception('Gagal menghapus gambar: $error');
        }
      }

      return {
        "error": false,
        "message": "Berhasil Menghapus Produk dan Gambar",
      };
    } catch (e) {
      print(e);
      return {
        "error": true,
        "message": "Tidak dapat menghapus produk: ${e.toString()}",
      };
    }
  }

  // Future<Map<String, dynamic>> deleteProduct(String id) async {
  //   try {
  //     await firestore.collection("product").doc(id).delete();

  //     return {
  //       "error": false,
  //       "Sukses": "Berhasil Menghapus Product",
  //     };
  //   } catch (e) {
  //     return {
  //       "error": true,
  //       "message": "Tidak dapat menghapus product",
  //     };
  //   }
  // }
}
