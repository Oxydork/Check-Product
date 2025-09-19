import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ProductsController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> streamProduct() async* {
    yield* firestore.collection("product").snapshots();
  }
}
