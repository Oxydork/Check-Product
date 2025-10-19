import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddProductController extends GetxController {
  RxBool isLoading = false.obs;
  RxString scannedBarcode = ''.obs;
  RxBool isScanning = false.obs;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Regular variable untuk selectedFile - digunakan dengan GetBuilder
  XFile? selectedFile;

  final SupabaseClient supabaseClient = SupabaseClient(
    'https://qrisvyccbwybkrmjkdcj.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFyaXN2eWNjYnd5YmtybWprZGNqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQzMTIwMTAsImV4cCI6MjA2OTg4ODAxMH0.dEaCtgWwQmXb3qDTggy5_LQXLgol2sbAxLtfPl4n39Q',
  );

  // Text controllers untuk form
  final TextEditingController codeC = TextEditingController();
  final TextEditingController nameC = TextEditingController();
  final TextEditingController rhC = TextEditingController();
  final TextEditingController expC = TextEditingController();

  // Method untuk update selectedFile dan trigger UI rebuild
  void updateSelectedFile(XFile? file) {
    selectedFile = file;
    update();
  }

  // Method untuk clear selected file
  void clearSelectedFile() {
    selectedFile = null;
    update();
  }

  // Method untuk clear form
  void clearForm() {
    codeC.clear();
    nameC.clear();
    rhC.clear();
    expC.clear();
    clearSelectedFile();
  }

  // Validasi form
  String? validateForm() {
    if (codeC.text.isEmpty || nameC.text.isEmpty || rhC.text.isEmpty) {
      return "Anda harus Mengisi Semuanya";
    }

    final rh = int.tryParse(rhC.text);
    if (rh == null) {
      return "RH must be a valid number";
    }

    return null; // Valid
  }

  // Show image source dialog
  void showImageSourceDialog() {
    Get.defaultDialog(
      title: "Select Image Source",
      middleText: "Choose image from camera or gallery",
      titleStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      middleTextStyle: const TextStyle(fontSize: 14),
      actions: [
        OutlinedButton.icon(
          onPressed: () => pickImageWithValidation(fromCamera: true),
          icon: const Icon(Icons.camera_alt),
          label: const Text("Camera"),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => pickImageWithValidation(fromCamera: false),
          icon: const Icon(Icons.photo_library),
          label: const Text("Gallery"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  // Pick image with validation and error handling
  void pickImageWithValidation({required bool fromCamera}) async {
    try {
      final file = await pickFile(fromCamera: fromCamera);

      Get.back(); // Close dialog

      if (file != null) {
        // Validate file first
        final isValid = await validateFile(file);
        if (!isValid) {
          Get.snackbar(
            "Invalid File",
            "Please select a valid image file (JPG, PNG, WEBP) under 5MB",
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade800,
            icon: const Icon(Icons.error, color: Colors.red),
            duration: const Duration(seconds: 4),
          );
          return;
        }

        updateSelectedFile(file);
        Get.snackbar(
          "Success",
          "Image selected: ${basename(file.path)}",
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
          icon: const Icon(Icons.check_circle, color: Colors.green),
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          "Info",
          "No image selected",
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade800,
          icon: const Icon(Icons.info, color: Colors.orange),
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.back(); // Close dialog

      String errorMessage = e.toString();
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
      }

      Get.defaultDialog(
        title: "Permission Required",
        middleText: errorMessage,
        titleStyle: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
        middleTextStyle: const TextStyle(fontSize: 14),
        backgroundColor: Colors.white,
        radius: 10,
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("OK"),
          ),
        ],
      );
    }
  }

  // Handle add product dengan validasi
  void handleAddProduct() async {
    if (isLoading.isTrue) return;

    // Validasi form
    final validationError = validateForm();
    if (validationError != null) {
      Get.snackbar(
        "Validation Error",
        validationError,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        icon: const Icon(Icons.error, color: Colors.red),
      );
      return;
    }

    isLoading(true);

    try {
      // Prepare product data
      Map<String, dynamic> productData = {
        "code": codeC.text.trim(),
        "name": nameC.text.trim(),
        "returhari": int.parse(rhC.text),
        "tanggal_rilis": DateTime.now(),
        "exp_date": DateFormat('dd MMM yyyy').parse(expC.text),
      };

      // Debug product data before submitting
      debugProductData(productData);

      // Call add product method
      Map<String, dynamic> result = await addProduct(productData, selectedFile);

      print("Add product result: $result");

      if (result["error"] == false) {
        // Success
        Get.back(); // Go back to previous screen
        Get.snackbar(
          "Success",
          result["Sukses"] ?? "Product added successfully",
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
          icon: const Icon(Icons.check_circle, color: Colors.green),
        );

        // Clear form
        clearForm();
      } else {
        // Error
        Get.snackbar(
          "Error",
          result["message"] ?? "Failed to add product",
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
          icon: const Icon(Icons.error, color: Colors.red),
        );
      }
    } catch (e) {
      print("Exception in handleAddProduct: $e");
      Get.snackbar(
        "Error",
        "Unexpected error: $e",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        icon: const Icon(Icons.error, color: Colors.red),
      );
    } finally {
      isLoading(false);
    }
  }

  Future<Map<String, dynamic>> addProduct(
      Map<String, dynamic> data, XFile? file) async {
    try {
      // Debug: Print data awal
      print("=== DEBUG ADD PRODUCT ===");
      print("Initial data: $data");
      print("File provided: ${file != null ? file.path : 'No file'}");

      var hasilFirestore = await firestore.collection("product").add(data);
      print("Document created with ID: ${hasilFirestore.id}");

      // Update productId dulu
      await firestore
          .collection("product")
          .doc(hasilFirestore.id)
          .update({"productId": hasilFirestore.id});
      print("ProductId updated: ${hasilFirestore.id}");

      if (file != null) {
        // Generate unique filename to avoid conflicts
        final String timestamp =
            DateTime.now().millisecondsSinceEpoch.toString();
        final String originalName = basename(file.path);
        final String extension = originalName.split('.').last;
        final String filename = '${hasilFirestore.id}_${timestamp}.$extension';

        print("File Path: ${filename}");

        try {
          // Upload file - di versi baru tidak ada response.error, langsung throw exception jika error
          await supabaseClient.storage.from('product').upload(
                filename,
                File(file.path),
              );

          print("Supabase upload successful");

          // Get public URL - di versi baru langsung return string, tidak ada .data
          final fileUrl =
              supabaseClient.storage.from('product').getPublicUrl(filename);

          print("Generated file URL: $fileUrl");

          try {
            await firestore
                .collection("product")
                .doc(hasilFirestore.id)
                .update({"file_url": fileUrl});
            print("File URL updated to Firestore successfully");
          } catch (e) {
            print("Error updating Firestore with file_url: $e");
          }
        } catch (uploadError) {
          print("Exception during file upload: $uploadError");
          await firestore
              .collection("product")
              .doc(hasilFirestore.id)
              .update({"file_url": ""});
        }
      } else {
        // Jika tidak ada file, tetap set file_url sebagai empty string
        await firestore
            .collection("product")
            .doc(hasilFirestore.id)
            .update({"file_url": ""});
        print("No file provided, file_url set to empty string");
      }

      print("=== END DEBUG ===");

      return {
        "error": false,
        "Sukses": "Berhasil Menambahkan Product",
        "productId": hasilFirestore.id,
      };
    } catch (e) {
      print("Exception in addProduct: $e");
      return {
        "error": true,
        "message": "Tidak dapat menambah product: $e",
      };
    }
  }

  Future<void> startScanning() async {
    try {
      isScanning.value = true;

      final result = await Get.to(() => _BarcodeScannerPage());

      if (result != null && result.toString().isNotEmpty && result != "-1") {
        scannedBarcode.value = result.toString();
        codeC.text = scannedBarcode.value;
      } else {
        scannedBarcode.value = '';
      }
    } catch (e) {
      print('Error scanning barcode: $e');
      scannedBarcode.value = '';
    } finally {
      isScanning.value = false;
    }
  }

  Future<XFile?> pickFile({bool fromCamera = false}) async {
    try {
      final ImagePicker _picker = ImagePicker();
      ImageSource source =
          fromCamera ? ImageSource.camera : ImageSource.gallery;

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        print("File picked: ${pickedFile.path}");
        print("File size: ${await pickedFile.length()} bytes");
      }

      return pickedFile;
    } on PlatformException catch (e) {
      print('PlatformException picking file: $e');

      if (e.code == 'camera_access_denied') {
        throw Exception(
            'Camera access denied. Please enable camera permission in your device settings.');
      } else if (e.code == 'photo_access_denied') {
        throw Exception(
            'Photo library access denied. Please enable photo library permission in your device settings.');
      } else {
        throw Exception('Permission denied: ${e.message}');
      }
    } catch (e) {
      print('Error picking file: $e');
      throw Exception('Failed to pick image: $e');
    }
  }

  // Method untuk validasi file
  Future<bool> validateFile(XFile file) async {
    try {
      final int fileSize = await file.length();
      const int maxSize = 5 * 1024 * 1024; // 5MB

      if (fileSize > maxSize) {
        print("File too large: ${fileSize} bytes");
        return false;
      }

      // Check file extension
      final String extension =
          basename(file.path).split('.').last.toLowerCase();
      const List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

      if (!allowedExtensions.contains(extension)) {
        print("Invalid file extension: $extension");
        return false;
      }

      return true;
    } catch (e) {
      print("Error validating file: $e");
      return false;
    }
  }

  // Method untuk debugging
  void debugProductData(Map<String, dynamic> data) {
    print("=== PRODUCT DATA DEBUG ===");
    data.forEach((key, value) {
      print("$key: $value");
    });
    print("Selected file: ${selectedFile?.path ?? 'No file selected'}");
    print("========================");
  }

  @override
  void onClose() {
    codeC.dispose();
    nameC.dispose();
    rhC.dispose();
    super.onClose();
  }
}

// Simple Scanner Page untuk GetX
class _BarcodeScannerPage extends StatefulWidget {
  @override
  _BarcodeScannerPageState createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<_BarcodeScannerPage> {
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
          onPressed: () =>
              Get.back(result: "-1"), // Mirip cancel di FlutterBarcodeScanner
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
