class SummaryModal {
  final double finalTotal;
  final String tableName;
  final String staffName;
  final List<Product> products;
  final String typeofservice;

  SummaryModal({
    required this.finalTotal,
    required this.tableName,
    required this.staffName,
    required this.products,
    required this.typeofservice,
  });

  factory SummaryModal.fromJson(Map<String, dynamic> json) {
    return SummaryModal(
      finalTotal: json['sell']['final_total'] != null
          ? double.parse(json['sell']['final_total'].toString())
          : 0.0, // Default to 0.0 or handle differently if null
      tableName: json['sell']['table'] != null && json['sell']['table']['name'] != null
          ? json['sell']['table']['name'].toString()
          : '',
      staffName: json['sell']['service_staff'] != null && json['sell']['service_staff']['first_name'] != null
          ? json['sell']['service_staff']['first_name'].toString()
          : '',
      products: json['sell']['sell_lines'] != null
          ? (json['sell']['sell_lines'] as List<dynamic>)
              .map((e) => Product.fromJson(e))
              .toList()
          : [], // Handle null or empty list as per your logic
      typeofservice: json['sell']['types_of_service'] != null && json['sell']['types_of_service']['name'] != null
          ? json['sell']['types_of_service']['name'].toString()
          : '',
    );
  }

  @override
  String toString() {
    return 'SummaryModal{finalTotal: $finalTotal, tableName: $tableName, staffName: $staffName, products: $products, typeofservice: $typeofservice}';
  }
}

class Product {
  final String name;
  final int quantity;

  Product({required this.name, required this.quantity});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['product'] != null && json['product']['name'] != null
          ? json['product']['name'].toString()
          : '',
      quantity: json['quantity'] != null ? json['quantity'].toInt() : 0,
    );
  }
}
