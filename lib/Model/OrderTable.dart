class Product {
  final String name;
  final String quantity;
  final String price;
  final int? brandId;
  final String? brandName;
  final int? transactionid;
  Product({required this.name, 
  required this.quantity, 
  required this.price,
  this.transactionid,
  this.brandId,
  this.brandName});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['product']['name'],
      quantity: json['quantity'].toString(),
      transactionid: json['transaction_id'],
      price:json['unit_price_inc_tax'].toString(),
      brandId: json['brand_id'],
      brandName: json['brand_id']!=null?json['brand']['name'].toString():"Others",
    );
  }
}

class OrderTableModal {
  final String finalTotal;
  final String tableName;
  final String staffName;
  final List<Product> products;
  final String typeofservice;


  OrderTableModal({
    required this.finalTotal,
    required this.tableName,
    required this.staffName,
    required this.products,
    required this.typeofservice,

  });

  factory OrderTableModal.fromJson(Map<String, dynamic> json) {
    var sellLines = json['sell_lines'] as List;
    List<Product> products =
        sellLines.map((item) => Product.fromJson(item)).toList();

    print('Parsed Products: $products');
    return OrderTableModal(
      finalTotal: json['final_total'],
      tableName: json['table']['name'],
      staffName: json['service_staff']['first_name'],
      typeofservice: json['types_of_service']['name'],
      products: products,
       
    );
  }
}
