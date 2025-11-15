class ProductMaster {
  final int? id;
  final String barcode;
  final String name;
  final int rh;

  ProductMaster({
    this.id,
    required this.barcode,
    required this.name,
    required this.rh,
  });

  // From JSON (untuk load dari file)
  factory ProductMaster.fromJson(Map<String, dynamic> json) {
    return ProductMaster(
      id: json['id'],
      barcode: _normalizeBarcode(json['barcode']),
      name: json['name'] ?? '',
      rh: json['rh'] ?? 0,
    );
  }

  //helper untuk menormalize barcode string to int

  static String _normalizeBarcode(dynamic barcode) {
    if (barcode == null) return '';
    if (barcode is String) return barcode;
    if (barcode is int) return barcode.toString();
    if (barcode is double) return barcode.toInt().toString();
    return barcode.toString();
  }

  // To Map (untuk insert ke SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barcode': barcode,
      'name': name,
      'rh': rh,
    };
  }

  // From Map (untuk read dari SQLite)
  factory ProductMaster.fromMap(Map<String, dynamic> map) {
    return ProductMaster(
      id: map['id'],
      barcode: map['barcode'] ?? '',
      name: map['name'] ?? '',
      rh: map['rh'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'ProductMaster{id: $id, barcode: $barcode, name: $name, rh: $rh}';
  }
}
