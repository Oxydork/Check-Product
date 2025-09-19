import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModels {
  final String code;
  final String name;
  final String productId;
  final int rh;
  final String file_url;
  final DateTime tanggalRilis;

  ProductModels({
    required this.code,
    required this.name,
    required this.productId,
    required this.rh,
    required this.file_url,
    required this.tanggalRilis,
  });

  factory ProductModels.fromJson(Map<String, dynamic> json) => ProductModels(
        code: json["code"] ?? "",
        name: json["name"] ?? "",
        productId: json["productId"] ?? "",
        rh: json["returhari"] ?? 0,
        file_url: json["file_url"] ?? "",
        tanggalRilis: json["tanggal_rilis"].toDate(),
      );

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "code": code,
      "name": name,
      "productId": productId,
      "returhari": rh,
      "tanggal_rilis": Timestamp.fromDate(tanggalRilis),
    };

    // Pastikan file_url disertakan meskipun kosong
    data["file_url"] = file_url;

    return data;
  }

  // Method alternatif untuk Firebase yang memastikan semua field ada
  Map<String, dynamic> toFirebaseJson() {
    return {
      "code": code.isEmpty ? "" : code,
      "name": name.isEmpty ? "" : name,
      "productId": productId.isEmpty ? "" : productId,
      "returhari": rh,
      "file_url": file_url.isEmpty ? "" : file_url,
      "tanggal_rilis": tanggalRilis,

      // Pastikan tidak null
    };
  }
}

// class ProductModels {
//   final String code;
//   final String name;
//   final String productId;
//   final int rh;
//   final String file_url;

//   ProductModels({
//     required this.code,
//     required this.name,
//     required this.productId,
//     required this.rh,
//     required this.file_url,
//   });

//   factory ProductModels.fromJson(Map<String, dynamic> json) => ProductModels(
//         code: json["code"] ?? "",
//         name: json["name"] ?? "",
//         productId: json["productId"] ?? "",
//         rh: json["returhari"] ?? 0,
//         file_url: json["file_url"] ?? "",
//       );

//   Map<String, dynamic> toJson() => {
//         "code": code,
//         "name": name,
//         "productId": productId,
//         "returhari": rh,
//         "file_url": file_url,
//       };
// }
