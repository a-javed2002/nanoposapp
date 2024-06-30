// SummaryModal class
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
      finalTotal: double.parse(json['sell']['final_total'].toString()), // Parse the string to double
      tableName: json['sell']['table']['name'] ?? '',
      staffName: json['sell']['service_staff']['first_name'] ?? '',
      products: json['sell']['sell_lines'] != null
          ? (json['sell']['sell_lines']as List<dynamic>)
              .map((e) => Product.fromJson(e))
              .toList()
          : [], // Provide an empty list or handle null as per your logic
      typeofservice: json['sell']['types_of_service']['name'] ?? '',
    );
  }

  @override
  String toString() {
    return 'SummaryModal{finalTotal: $finalTotal, tableName: $tableName, staffName: $staffName, products: $products, typeofservice: $typeofservice}';
  }
}

// Product class
class Product {
  final String name;
  final int quantity;

  Product({required this.name, required this.quantity});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['product']['name'],
      quantity: json['quantity'].toInt(),
    );
  }
}
