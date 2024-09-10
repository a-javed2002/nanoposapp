// order_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:nano/Model/OrderTable.dart';
import 'package:nano/View/Auth/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderTableController extends GetxController {
  var selectedFilter = 0.obs; // Track the selected filter
  var orders = <OrderTableModal>[].obs;
  var isLoading = true.obs;
  RxString username = "".obs;

  var filteredOrders = <OrderTableModal>[].obs;

  late StreamController<List<OrderTableModal>> _ordersStreamController;

  @override
  void onInit() {
    _ordersStreamController =
        StreamController<List<OrderTableModal>>.broadcast();
    loadOrders();
    setUserName();
    super.onInit();
  }

  void loadOrders() async {
    // Assume fetchOrders() is a method that fetches orders
    orders.value = await fetchOrders();
    filteredOrders.value = orders;
    _ordersStreamController.add(filteredOrders);
  }

  // Filter orders based on is_kitchen_order
  void filterOrders(int filter) {
    selectedFilter.value = filter;
    if (filter == 0) {
      filteredOrders.value = orders;
    } else if (filter == 1) {
      filteredOrders.value =
          orders.where((order) => order.is_kitchen_order == 1).toList();
    } else if (filter == 2) {
      filteredOrders.value =
          orders.where((order) => order.is_kitchen_order == 0).toList();
    }
    _ordersStreamController.add(filteredOrders);
  }

  Stream<List<OrderTableModal>> get ordersStream =>
      _ordersStreamController.stream;

  void setUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Fetch the stored string
    String? userJson = prefs.getString('user');

    if (userJson != null) {
      // Decode the JSON string to a map
      Map<String, dynamic> userMap = jsonDecode(userJson);

      // Print the decoded user data
      // print(userMap);
      // final businessId = userMap['business_id'];
      // final locationId = userMap['location_id'];
      // print(businessId);
      // print(locationId);
      username.value = userMap['username'];
      print("username is ${username.value}");
    } else {
      Get.to(LoginPage());
    }
  }
  Future<String> _getBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedBaseUrl = prefs.getString('base_url') ?? "";

    return storedBaseUrl; // Return the value
  }

  Future<List<OrderTableModal>> fetchOrders() async {
    String baseUrl = await _getBaseUrl();
    try {
      isLoading(true);
      var response = await http
          .get(Uri.parse('https://$baseUrl/api/orders'));
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        var fetchedOrders = (jsonData as List)
            .map((order) => OrderTableModal.fromJson(order))
            .toList();
        orders.assignAll(fetchedOrders);
        // _ordersStreamController.add(orders.toList());
        return orders.toList();
      } else {
        // Handle error
        return [];
      }
    } finally {
      isLoading(false);
    }
  }

  Future<OrderTableModal?> acceptOrder(
      BuildContext context, OrderTableModal order,
      {bool temp = true}) async {
    String baseUrl = await _getBaseUrl();
    final String url =
        'https://$baseUrl/api/update/${order.transactionId}'; // Replace with your API endpoint
    print(order.transactionId);

    // Decode jsonData to extract nested fields
    Map<String, dynamic> orderData = jsonDecode(order.jsonData!);
    if (order.tax_id != null) {
      orderData['tax_id'] = order.tax_id;
    }

    // Extracting product information from orderData['sell_lines']
    Map<String, dynamic> products = {};
    for (int i = 0; i < orderData['sell_lines'].length; i++) {
      var sellLine = orderData['sell_lines'][i];
      products[i.toString()] = {
        "product_type": sellLine['product']['type'],
        "unit_price": sellLine['unit_price'],
        "line_discount_type": sellLine['line_discount_type'],
        "line_discount_amount": sellLine['line_discount_amount'],
        "item_tax": sellLine['item_tax'],
        "tax_id": sellLine['tax_id'] ?? "",
        "sell_line_note": sellLine['sell_line_note'],
        "transaction_sell_lines_id": sellLine['id'],
        "product_id": sellLine['product_id'],
        "variation_id": sellLine['variation_id'],
        "enable_stock": sellLine['product']['enable_stock'],
        "quantity": sellLine['quantity'].toString(),
        "product_unit_id": sellLine['product']['unit_id'],
        "base_unit_multiplier": 1,
        "unit_price_inc_tax": sellLine['unit_price_inc_tax']
      };
    }
    print(orderData['transaction_date']);
    print("${orderData['tax_id']}");

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
      }
      else{
        Get.to(LoginPage());
      }

    // Define your payload as a Map
    Map<String, dynamic> payload = {
      "location_id": orderData['location_id'],
      "sub_type": orderData['sub_type'] ?? "",
      "zone": "on",
      "business_id": business_id,
      "user_id": user_id,
      "is_kitchen_order": 1,
      "contact_id": orderData['contact_id'],
      "search_product": "",
      "pay_term_number": orderData['pay_term_number'] ?? "",
      "pay_term_type": orderData['pay_term_type'] ?? "",
      "custom_field_4": orderData['custom_field_4'] ?? 10,
      "transaction_date": "24-06-2024 02:10 PM",
      "types_of_service_text": order.typeOfService,
      "types_of_service_id": orderData['types_of_service_id'],
      "packing_charge": orderData['packing_charge'],
      "packing_charge_type": orderData['packing_charge_type'] ?? "",
      "res_table_id": orderData['res_table_id'],
      "res_waiter_id": orderData['res_waiter_id'],
      "sell_price_tax": "includes",
      "products": products,
      "discount_type": orderData['discount_type'],
      "discount_amount": orderData['discount_amount'],
      "rp_redeemed": orderData['rp_redeemed'],
      "rp_redeemed_amount": orderData['rp_redeemed_amount'],
      "tax_rate_id": orderData['tax_id'],
      "tax_calculation_amount": orderData['tax_amount'],
      "shipping_details": orderData['shipping_details'] ?? "",
      "shipping_address": orderData['shipping_address'] ?? "",
      "shipping_status": orderData['shipping_status'] ?? "",
      "delivered_to": orderData['delivered_to'] ?? "",
      "delivery_person": orderData['delivery_person'] ?? "",
      "shipping_charges": orderData['shipping_charges'],
      "advance_balance": "0.0000",
      "payment": {
        "0": {
          "amount": order.finalTotal,
          "cheque_number": "",
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
      "sale_note": orderData['additional_notes'],
      "staff_note": orderData['staff_note'] ?? "",
      "change_return": "0.00",
      "additional_notes": orderData['additional_notes'] ?? "hmm",
      "is_suspend": 1,
      // "is_suspend": orderData['is_suspend'],
      "recur_interval": orderData['recur_interval'],
      "recur_interval_type": orderData['recur_interval_type'],
      "recur_repetitions": orderData['recur_repetitions'] ?? "",
      "subscription_repeat_on": orderData['subscription_repeat_on'] ?? "",
      "is_enabled_stock": orderData['is_enable_stock'] ?? "",
      "is_credit_sale": 0,
      "final_total": order.finalTotal,
      "discount_type_modal": orderData['discount_type'],
      "discount_amount_modal": orderData['discount_amount'],
      "order_tax_modal": orderData['tax_id'],
      "shipping_details_modal": orderData['shipping_details'] ?? "",
      "shipping_address_modal": orderData['shipping_address'] ?? "",
      "shipping_charges_modal": orderData['shipping_charges'],
      "shipping_status_modal": orderData['shipping_status'] ?? "",
      "delivered_to_modal": orderData['delivered_to'] ?? "",
      "delivery_person_modal": orderData['delivery_person'] ?? "",
      "payment_status": "due",
      "status": "final"
      // "payment_status": orderData['payment_status'] ?? "due",
      // "status": orderData['status'] ?? "final"
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
        Map<String, dynamic> responseBody = json.decode(response.body);
        OrderTableModal order = OrderTableModal.fromJson(responseBody);
        if (temp) {
          _showSnackbar(context, "Order Accepted", Colors.green);
        }
        return order;
      } else {
        print('Failed to send POST request');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Exception during POST request: $e');
    }
  }

  Future<void> reject(BuildContext context, int saleId) async {
    String baseUrl = await _getBaseUrl();
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Fetch the stored string
      String? userJson = prefs.getString('user');

      if (userJson != null) {
        // Decode the JSON string to a map
        Map<String, dynamic> userMap = jsonDecode(userJson);

        // Print the decoded user data
        print(userMap);
        final businessId = userMap['business_id'];
        final locationId = userMap['location_id'];
        print(businessId);
        print(locationId);
        print(saleId);
        final String apiUrl =
            'https://$baseUrl/api/delete/$saleId/$businessId';

        final response = await http.delete(Uri.parse(apiUrl));
        print(jsonDecode(response.body));

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseBody = jsonDecode(response.body);
          if (responseBody['success']) {
            _showSnackbar(context, "Order Rejected", Colors.green);
          } else {
            _showSnackbar(context, responseBody['msg'], Colors.red);
          }
        } else {
          _showSnackbar(context, 'Failed to delete sale', Colors.red);
        }
      } else {
        Get.to(LoginPage());
      }
    } catch (e) {
      _showSnackbar(context, 'Error: $e', Colors.red);
    }
  }

  void _showSnackbar(BuildContext context, String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(top: 8, left: 8, right: 8),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    _ordersStreamController.close();
    super.dispose();
  }
}
