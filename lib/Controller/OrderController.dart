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
  String name;
  double price;

  int categoryId;

  Product(
      {required this.id,
      required this.name,
      required this.price,
      required this.categoryId});

  factory Product.fromJson(Map<String, dynamic> json) {
    try {
      return Product(
        id: json['id'] ?? 0,
        name: json['name'] ?? 'Default Name',
        price: double.tryParse(json['default_sell_price'] ?? '0.0') ?? 0.0,
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
}
