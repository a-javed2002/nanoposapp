import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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

class Product {
  String name;
  double price;
  int quantity;
  String status; 
  Product(this.name, this.price, this.quantity, {this.status = "pending"});
 void setStatus(String newStatus) {
    status = newStatus;
  }

 Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'quantity': quantity,
        'status': status,
      };

  // Factory method to create a Product object from a JSON object
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      json['name'],
      json['price'],
      json['quantity'],
      status: json['status'] ?? "pending", // Default value for status if not present in JSON
    );
  }
}

class CartItem {
  Product product;
  int quantity;

  CartItem(this.product, this.quantity);

  // Method to convert a CartItem object to a JSON object
  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
      };

  // Factory method to create a CartItem object from a JSON object
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      Product.fromJson(json['product']),
      json['quantity'],
    );
  }
}

class Category {
  String name;
  List<Product> products;

  Category(this.name, this.products);
}

class Cart {
  List<CartItem> items = [];

  void addToCart(Product product, int quantity) {
    int index = items.indexWhere((item) => item.product.name == product.name);

    if (index != -1) {
      items[index].quantity += quantity;
    } else {
      items.add(CartItem(product, quantity));
    }
    _saveCartToPreferences();
  }

  void increaseQuantity(int index) {
    items[index].quantity++;
    _saveCartToPreferences();
  }

  void decreaseQuantity(int index) {
    if (items[index].quantity > 1) {
      items[index].quantity--;
    } else {
      items.removeAt(index);
    }
    _saveCartToPreferences();
  }
  double calculateSubtotal() {
    double subtotal = 0;
    for (var item in items) {
      subtotal += item.product.price * item.quantity;
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
  }

  Future<void> _loadCartFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
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
    categories.assignAll([
      Category("Print Option", [
        Product("Print Order", 5.20, 1),
        Product("Print Cash Order", 1000, 0),
        Product("Print Credit Order", 1.40, 0),
      ]),
      Category("Test", [
        Product("Test Product", 10.50, 2),
        Product("Another Test", 3.80, 1),
      ]),
      Category("All", [
        Product("Classic Burger", 10.50, 2),
        Product("Veggie Burger", 3.80, 1),
        Product("Whopper", 3.80, 1),
        Product("Vegetarian Panini", 3.80, 1),
        Product("BLT Sandwich", 4.20, 1),
        Product("Cola", 1.50, 1),
        Product("Lemonade", 2.00, 1),
        Product("Root Beer", 1.80, 1),
      ]),
      Category("Burger", [
        Product("Classic Burger", 10.50, 2),
        Product("Veggie Burger", 3.80, 1),
        Product("Whopper", 3.80, 1),
      ]),
      Category("Sandwich", [
        Product("Vegetarian Panini", 3.80, 1),
        Product("BLT Sandwich", 4.20, 1),
      ]),
      Category("Softdrink", [
        Product("Cola", 1.50, 1),
        Product("Lemonade", 2.00, 1),
        Product("Root Beer", 1.80, 1),
      ]),
      Category("Pedicure", [
        Product("Mike Tshirt", 10.50, 2),
        Product("Mike Paint", 3.80, 1),
        Product("Custom Item", 3.80, 1),
      ]),
    ]);
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
        selectedCategoryIndex.value = 8;
      } else {
        print(
            "Number of products in selected category: ${categories[index].products.length}");
      }
      selectedCategoryIndex.value = index;
    } else {
      print("Invalid category index: $index");
    }
  }

  void selectQuantity(int quantity) {
    selectedQuantity.value = quantity;
  }
}
