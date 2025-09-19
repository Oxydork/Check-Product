import 'package:get/get.dart';

import '../controllers/product_controller.dart';

class AddProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddProductController>(
      () => AddProductController(),
    );
  }
}
