import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nano/Model/OrderTable.dart';
import 'package:nano/View/Auth/Login.dart';
import 'dart:math';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Color.fromRGBO(3, 4, 94, 1)
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class Category {
  int id;
  String name;
  String description;
  List<Product> products;

  Category(
      {required this.id,
      required this.name,
      required this.description,
      required this.products});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0, // Provide default value if id is missing or null
      name: json['name'] ??
          'name', // Provide default value if name is missing or null
      description: json['description'] ??
          'faltou', // Provide default value if description is missing or null
      products: [], // Initialize products list, it will be populated later
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'products': products.map((product) => product.toJson()).toList(),
    };
  }
}

class Product {
  int id;
  int v_id;
  String name;
  double price;

  int categoryId;

  Product(
      {required this.id,
      required this.v_id,
      required this.name,
      required this.price,
      required this.categoryId});

  factory Product.fromJson(Map<String, dynamic> json) {
    try {
      return Product(
        id: json['product_id'] ?? 0,
        v_id: json['id'] ?? 0,
        name: json['name'] ?? 'Default Name',
        price: double.tryParse(json['selling_price'] ?? '0.0') ?? 0.0,
        categoryId: json['category_id'] ?? -1,
      );
    } catch (e) {
      print('Error parsing product JSON: $json');
      print('Exception details: $e');
      throw Exception('Failed to parse product JSON');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'v_id': v_id,
      'name': name,
      'price': price.toString(),
      'category_id': categoryId,
    };
  }
}

class CartItem {
  Product product;
  int quantity2;

  CartItem(this.product, this.quantity2);

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity2': quantity2,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      Product.fromJson(json['product']),
      json['quantity2'],
    );
  }
}

class Cart {
  List<CartItem> items = [];
  void addToCart(Product product, int quantity2) {
    int index = items.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      items[index].quantity2 += quantity2;
    } else {
      items.add(CartItem(product, quantity2));
    }
    _saveCartToPreferences();
  }

  void increaseQuantity(int index) {
    items[index].quantity2++;
    _saveCartToPreferences();
  }

  void decreaseQuantity(int index) {
    if (items[index].quantity2 > 1) {
      items[index].quantity2--;
    } else {
      items.removeAt(index);
    }
    _saveCartToPreferences();
  }

  double calculateSubtotal() {
    double subtotal = 0;
    for (var item in items) {
      subtotal += item.product.price * item.quantity2;
    }
    return subtotal.roundToDouble();
  }

  double calculateTax() {
    return (calculateSubtotal() * 0.45).roundToDouble();
  }

  double calculateTotal() {
    return calculateSubtotal() + calculateTax();
  }

  void removeItem(int index) {
    items.removeAt(index);
    _saveCartToPreferences();
  }

  void _saveCartToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cartJson = jsonEncode(items.map((item) => item.toJson()).toList());
    prefs.setString('cart', cartJson);

    print('bkl $cartJson');
  }

  Future<void> _loadCartFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Remove the value for the key 'Cart'
    await prefs.remove('cart');
    String? cartJson = prefs.getString('cart');
    if (cartJson != null) {
      List<dynamic> cartList = jsonDecode(cartJson);
      items = cartList
          .map((item) => CartItem.fromJson(item))
          .toList()
          .cast<CartItem>();
    }
  }

  void clearCartPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('cart');
    items.clear();
  }
}

final List<Color> colors = [
  Color.fromRGBO(3, 4, 94, 1),
  Color.fromRGBO(144, 224, 239, 1),
  Color.fromRGBO(202, 240, 248, 1),
  Colors.blue,
];

final Random random = Random();

class OrderController extends GetxController {
  var isLoading = false.obs;

  void removeFromCart(int index) {
    cart.value.removeItem(index);
    cart.refresh();
  }

  var maxChildSize = 0.9.obs;

  void updateMaxChildSize(double offset) {
    double newMaxChildSize = 0.9 - (offset / 1000);
    if (newMaxChildSize < 0.5) {
      newMaxChildSize = 0.5;
    }
    maxChildSize.value = newMaxChildSize;
  }

  var categories = <Category>[].obs;

  RxInt selectedCategoryIndex = (-1).obs;
  var selectedQuantity = 1.obs;
  var cart = Cart().obs;

  @override
  void onInit() {
    super.onInit();
    _initializeCart();
    _initializeCart2();
  }

  void _initializeCart2() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? categoriesString = prefs.getString('categories');

    if (categoriesString != null) {
      final List<dynamic> categoryJsonList = jsonDecode(categoriesString);
      categories.assignAll(
        categoryJsonList
            .map((categoryJson) => Category.fromJson(categoryJson))
            .toList(),
      );
      print('Categories loaded: ${categories.length}');
    } else {
      print('No categories found'); // Ensure this message is accurate
    }

    final String? productsString = prefs.getString('products');
    if (productsString != null) {
      final List<dynamic> productJsonList = jsonDecode(productsString);
      for (var productJson in productJsonList) {
        try {
          var product = Product.fromJson(productJson);
          var category = categories.firstWhere(
            (category) => category.id == product.categoryId,
            orElse: () => Category(
                id: -1, name: 'Uncategorized', description: '', products: []),
          );
          category.products.add(product);
        } catch (e) {
          print('Error parsing product JSON: $productJson');
          print('Exception details: $e');
        }
      }
    } else {
      print('No products found');
    }
  }

  void _initializeCart() async {
    await cart.value._loadCartFromPreferences();
    cart.refresh();
  }

  void addToCart(Product product) {
    cart.value.addToCart(product, selectedQuantity.value);

    cart.refresh();
  }

  void selectCategory(int index) {
    if (index >= -1 && index < categories.length) {
      print("Selected category index: $index");
      if (index == -1) {
        selectedCategoryIndex.value = 100000;
      } else {
        print(
            "Number of products in selected category: ${categories[index].products.length}");
      }
      selectedCategoryIndex.value = index;
    } else {
      print("Invalid category index: $index");
    }
  }

  void selectQuantity(int quantity2) {
    selectedQuantity.value = quantity2;
  }
  Future<String> _getBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedBaseUrl = prefs.getString('base_url') ?? "";

    return storedBaseUrl; // Return the value
  }

  // void updateOrder(OrderTableModal order) async {
  //   final String url =
  //       'https://$baseUrl/api/update/${order.transactionId}'; // Replace with your API endpoint
  //   print(order.transactionId);

  //   // Decode jsonData to extract nested fields
  //   Map<String, dynamic> orderData = jsonDecode(order.jsonData!);

  //   // Extracting product information from orderData['sell_lines']
  //   Map<String, dynamic> products = {};
  //   for (int i = 0; i < orderData['sell_lines'].length; i++) {
  //     var sellLine = orderData['sell_lines'][i];
  //     products[i.toString()] = {
  //       "product_type": sellLine['product']['type'],
  //       "unit_price": sellLine['unit_price'],
  //       "line_discount_type": sellLine['line_discount_type'],
  //       "line_discount_amount": sellLine['line_discount_amount'],
  //       "item_tax": sellLine['item_tax'],
  //       "tax_id": sellLine['tax_id'] ?? "",
  //       "sell_line_note": sellLine['sell_line_note'],
  //       "transaction_sell_lines_id": sellLine['id'],
  //       "product_id": sellLine['product_id'],
  //       "variation_id": sellLine['variation_id'],
  //       "enable_stock": sellLine['product']['enable_stock'],
  //       "quantity": sellLine['quantity'].toString(),
  //       "product_unit_id": sellLine['product']['unit_id'],
  //       "base_unit_multiplier": 1,
  //       "unit_price_inc_tax": sellLine['unit_price_inc_tax']
  //     };
  //   }
  //   print(orderData['transaction_date']);

  //   // Define your payload as a Map
  //   Map<String, dynamic> payload = {
  //     "location_id": orderData['location_id'],
  //     "sub_type": orderData['sub_type'] ?? "",
  //     "zone": "on",
  //     "contact_id": orderData['contact_id'],
  //     "search_product": "",
  //     "pay_term_number": orderData['pay_term_number'] ?? "",
  //     "pay_term_type": orderData['pay_term_type'] ?? "",
  //     "custom_field_4": 100,
  //     "transaction_date":
  //         orderData['transaction_date'] ?? "24-06-2024 02:10 PM",
  //     "types_of_service_text": order.typeOfService,
  //     "types_of_service_id": orderData['types_of_service_id'],
  //     "packing_charge": orderData['packing_charge'],
  //     "packing_charge_type": orderData['packing_charge_type'] ?? "",
  //     "res_table_id": orderData['res_table_id'],
  //     "res_waiter_id": orderData['res_waiter_id'],
  //     "sell_price_tax": "includes",
  //     "products": products,
  //     "discount_type": orderData['discount_type'],
  //     "discount_amount": orderData['discount_amount'],
  //     "rp_redeemed": orderData['rp_redeemed'],
  //     "rp_redeemed_amount": orderData['rp_redeemed_amount'],
  //     "tax_rate_id": orderData['tax_rate_id'], // Updated field
  //     "tax_calculation_amount":
  //         orderData['tax_calculation_amount'], // Updated field
  //     "shipping_details": orderData['shipping_details'] ?? "",
  //     "shipping_address": orderData['shipping_address'] ?? "",
  //     "shipping_status": orderData['shipping_status'] ?? "",
  //     "delivered_to": orderData['delivered_to'] ?? "",
  //     "delivery_person": orderData['delivery_person'] ?? "",
  //     "shipping_charges": orderData['shipping_charges'],
  //     "advance_balance": "0.0000",
  //     "payment": {
  //       "0": {
  //         "amount": order.finalTotal,
  //         "cheque_number": "",
  //         "bank_account_number": "",
  //         "transaction_no_1": "",
  //         "transaction_no_2": "",
  //         "transaction_no_3": "",
  //         "transaction_no_4": "",
  //         "transaction_no_5": "",
  //         "transaction_no_6": "",
  //         "transaction_no_7": "",
  //         "note": ""
  //       },
  //       "change_return": {
  //         "method": "cash",
  //         "cheque_number": "",
  //         "bank_account_number": "",
  //         "transaction_no_1": "",
  //         "transaction_no_2": "",
  //         "transaction_no_3": "",
  //         "transaction_no_4": "",
  //         "transaction_no_5": "",
  //         "transaction_no_6": "",
  //         "transaction_no_7": ""
  //       }
  //     },
  //     "sale_note": orderData['additional_notes'],
  //     "staff_note": orderData['staff_note'] ?? "",
  //     "change_return": "0.00",
  //     "additional_notes": orderData['additional_notes'] ?? "hmm",
  //     "is_suspend":
  //         1, // Ensure correct value or use `orderData['is_suspend']` if needed
  //     "recur_interval": orderData['recur_interval'],
  //     "recur_interval_type": orderData['recur_interval_type'],
  //     "recur_repetitions": orderData['recur_repetitions'] ?? "",
  //     "subscription_repeat_on": orderData['subscription_repeat_on'] ?? "",
  //     "is_enabled_stock": orderData['is_enabled_stock'] ?? "", // Updated field
  //     "is_credit_sale": 0,
  //     "final_total": order.finalTotal,
  //     "discount_type_modal": orderData['discount_type'],
  //     "discount_amount_modal": orderData['discount_amount'],
  //     "order_tax_modal": orderData['tax_rate_id'], // Updated field
  //     "shipping_details_modal": orderData['shipping_details'] ?? "",
  //     "shipping_address_modal": orderData['shipping_address'] ?? "",
  //     "shipping_charges_modal": orderData['shipping_charges'],
  //     "shipping_status_modal": orderData['shipping_status'] ?? "",
  //     "delivered_to_modal": orderData['delivered_to'] ?? "",
  //     "delivery_person_modal": orderData['delivery_person'] ?? "",
  //     "payment_status": "due",
  //     "status": "final"
  //   };

  //   // Encode the payload as JSON
  //   String jsonPayload = jsonEncode(payload);

  //   try {
  //     var response = await http.post(
  //       Uri.parse(url),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonPayload,
  //     );

  //     if (response.statusCode == 200) {
  //       print('POST request successful');
  //       print('Response: ${response.body}');
  //     } else {
  //       print('Failed to send POST request');
  //       print('Response: ${response.body}');
  //     }
  //   } catch (e) {
  //     print('Exception during POST request: $e');
  //   }
  // }

  Future<void> placeOrder(OrderTableModal order) async {
    String baseUrl = await _getBaseUrl();
    isLoading.value = true;
    final String url = 'https://$baseUrl/api/store';

    Map<String, dynamic> products = {};
    for (int i = 0; i < order.products.length; i++) {
      var sellLine = order.products[i];
      products[i.toString()] = {
        'product_type': 'single',
        'unit_price': sellLine.price,
        'line_discount_type': 'fixed',
        'line_discount_amount': '0.00',
        'item_tax': '0.00',
        'tax_id': '',
        'sell_line_note': '',
        'product_id': sellLine.id,
        'variation_id': sellLine.variationId,
        'enable_stock': 0,
        'quantity': sellLine.quantity,
        'product_unit_id': 4,
        'sub_unit_id': 4,
        'base_unit_multiplier': 1,
        'unit_price_inc_tax': sellLine.price
      };
    }

    DateTime now = DateTime.now();
    String formattedDateTime = DateFormat('dd-MM-yyyy hh:mm a').format(now);

    print(order.transaction_date);
    print(order.res_table_id);

    int business_id = 0;
    int user_id = 0;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Fetch the stored string
    String? userJson = prefs.getString('user');

    if (userJson != null) {
      // Decode the JSON string to a map
      Map<String, dynamic> userMap = jsonDecode(userJson);

      // Print the decoded user data
      print(userMap);
      business_id = userMap['business_id'];
      user_id = userMap['id'];
    } else {
      Get.to(LoginPage());
    }

    Map<String, dynamic> payload = {
      "location_id": order.location_id,
      "sub_type": "",
      "zone": "on",
      "business_id": business_id,
      "user_id": user_id,
      "is_kitchen_order": 1,
      "contact_id": order.contact_id,
      "search_product": "",
      "pay_term_number": order.pay_term_number ?? "",
      "pay_term_type": order.pay_term_type ?? "",
      "custom_field_4": order.custom_field_4,
      "transaction_date": formattedDateTime,
      "types_of_service_text": order.typeOfService,
      "types_of_service_id": 1,
      "packing_charge": order.packing_charge,
      "packing_charge_type": order.packing_charge_type ?? "",
      "res_table_id": order.res_table_id,
      "res_waiter_id": order.res_waiter_id,
      "sell_price_tax": "includes",
      "products": products,
      "discount_type": 'percentage',
      "discount_amount": '0.00',
      "rp_redeemed": 0,
      "rp_redeemed_amount": 0,
      "tax_rate_id": 1,
      "tax_calculation_amount": 0,
      "shipping_details": "",
      "shipping_address": "",
      "shipping_status": "",
      "delivered_to": "",
      "delivery_person": "",
      "shipping_charges": "0.00",
      "advance_balance": "0.0000",
      "payment": {
        "0": {
          "amount": order.finalTotal,
          "cheque_number": "",
          "method": 'cash',
          "bank_account_number": "",
          "transaction_no_1": "",
          "transaction_no_2": "",
          "transaction_no_3": "",
          "transaction_no_4": "",
          "transaction_no_5": "",
          "transaction_no_6": "",
          "transaction_no_7": "",
          "note": ""
        },
        "change_return": {
          "method": "cash",
          "cheque_number": "",
          "bank_account_number": "",
          "transaction_no_1": "",
          "transaction_no_2": "",
          "transaction_no_3": "",
          "transaction_no_4": "",
          "transaction_no_5": "",
          "transaction_no_6": "",
          "transaction_no_7": ""
        }
      },
      "sale_note": "",
      "staff_note": "",
      "change_return": "0.00",
      "additional_notes": order.additionalNotes,
      "is_suspend": 1,
      "recur_interval": '',
      "recur_interval_type": 'days',
      "recur_repetitions": '',
      "subscription_repeat_on": "",
      "is_enabled_stock": "",
      "is_credit_sale": 0,
      "final_total": order.finalTotal,
      "discount_type_modal": 'percentage',
      "discount_amount_modal": '0.00',
      "order_tax_modal": 1,
      "shipping_details_modal": "",
      "shipping_address_modal": "",
      "shipping_charges_modal": 0,
      "shipping_status_modal": "",
      "delivered_to_modal": "",
      "delivery_person_modal": "",
      "payment_status": "due",
      "status": "final"
    };

    // Encode the payload as JSON
    String jsonPayload = jsonEncode(payload);

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonPayload,
      );

      if (response.statusCode == 200) {
        print('POST request successful');
        print('Response: ${response.body}');
      } else {
        print('Failed to send POST request');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Exception during POST request: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
