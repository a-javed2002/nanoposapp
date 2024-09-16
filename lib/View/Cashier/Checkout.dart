import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nano/Model/OrderTable.dart';
import 'package:http/http.dart' as http;
import 'package:nano/View/Auth/Login.dart';
import 'package:nano/View/Cashier/Cash_Payment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nano/View/Status_Screen/payment_done.dart';

class CheckoutPage extends StatelessWidget {
  final OrderTableModal order;
  final String taxName;
  CheckoutPage({required this.order, required this.taxName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order Details',
          style: GoogleFonts.poppins(fontSize: 32),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Text(
              //   'Order Summary',
              //   style: GoogleFonts.poppins(
              //       fontSize: 32, fontWeight: FontWeight.bold),
              // ),
              // SizedBox(height: 20),
              _buildOrderDetails(order, context),
              SizedBox(height: 20),
              _buildSummary(order),
              SizedBox(height: 20),
              _buildPaymentOptions(order,context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetails(OrderTableModal order, BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          height: MediaQuery.of(context).size.height * 0.45,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(
              //   'Order Details',
              //   style: GoogleFonts.poppins(
              //     fontSize: 24,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: order.products.length,
                  itemBuilder: (context, index) {
                    final product = order.products[index];
                    return Column(
                      children: [
                        _buildOrderItem(product, order.finalTotal!),
                        Divider(
                          thickness: 1,
                          color: Colors.grey,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildOrderItem(Product product, String finalTotal) {
    // Calculate subtotal
    double subtotal = int.parse(product.quantity) * double.parse(product.price);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${product.name}',
            maxLines: 2, // Adjust maxLines as needed for responsiveness
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(fontSize: 18),
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${product.quantity} x ${product.price} Rs',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
              Text(
                'Subtotal: $subtotal Rs',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(OrderTableModal order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        _buildSummaryRow(taxName, '${order.tax_amount}'),
        _buildSummaryRow('Total', '${order.finalTotal}'),
        // _buildSummaryRow('Tax', '22 Rs'), // Example tax (replace with actual tax logic if needed)
        // Divider(),
        // _buildSummaryRow('Total', '33 Rs', fontWeight: FontWeight.bold), // Example total (replace with actual calculation if needed)
      ],
    );
  }

  Widget _buildSummaryRow(String title, String value,
      {FontWeight fontWeight = FontWeight.normal}) {
    double val = 0;
    if (value != '' && value != null) {
      val = double.tryParse(value) ?? 0;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: GoogleFonts.poppins(fontWeight: fontWeight, fontSize: 20)),
          Text("${val.toStringAsFixed(2)}",
              style: GoogleFonts.poppins(fontWeight: fontWeight, fontSize: 20)),
        ],
      ),
    );
  }

  Widget _buildPaymentOptions(OrderTableModal order,BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        taxName.toLowerCase().contains('card')
            ? ElevatedButton(
                onPressed: () async {
                  await payWithCard(order);
                  print('Processing card payment');
                },
                child: Text(
                  'Pay with Card',
                  style: GoogleFonts.poppins(fontSize: 24),
                ),
              )
            : 
            ElevatedButton(
                onPressed: () {
                  // Get.to(() => CashPayment(
                  //       total: order.finalTotal,
                  //       order: order,
                  //     ));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Go To Cash Counter!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                child: Text(
                  'Go To Cash Counter',
                  style: GoogleFonts.poppins(fontSize: 24),
                ),
              )
      ],
    );
  }

  Future<String> _getBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedBaseUrl = prefs.getString('base_url') ?? "";

    return storedBaseUrl; // Return the value
  }

  Future<void> payWithCard(OrderTableModal order) async {
    String baseUrl = await _getBaseUrl();
    
    final String url =
        '$baseUrl/api/update/${order.transactionId}'; // Replace with your API endpoint
    print(order.transactionId);

    // Decode jsonData to extract nested fields
    Map<String, dynamic> orderData = jsonDecode(order.jsonData!);

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

    // Define your payload as a Map
    Map<String, dynamic> payload = {
      // "_token": "Sm38MbDShTp30ScFmZW30XzIHHYUaT4lmhY7DCeH",
      // "_method": "POST",
      "location_id": orderData['location_id'],
      "sub_type": orderData['sub_type'] ?? "",
      "zone": "on",
      "business_id": business_id,
      "user_id": user_id,
      "contact_id": orderData['contact_id'],
      "search_product": "",
      "pay_term_number": orderData['pay_term_number'] ?? "",
      "pay_term_type": orderData['pay_term_type'] ?? "",
      "custom_field_4": orderData['custom_field_4'] ?? 0,
      "transaction_date": "25-06-2024 06:13 PM",
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
      "shipping_address": "NAZIMABAD ABCD",
      "shipping_status": orderData['shipping_status'] ?? "",
      "delivered_to": orderData['delivered_to'] ?? "",
      "delivery_person": orderData['delivery_person'] ?? "",
      "shipping_charges": "400.00",
      "advance_balance": "0.0000",
      "payment": {
        "0": {
          "amount": order.finalTotal,
          "method": "card",
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
      "additional_notes": orderData['additional_notes'] ?? "",
      "is_suspend": 0,
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
      "shipping_address_modal": "NAZIMABAD ABCD",
      "shipping_charges_modal": "400.00",
      "shipping_status_modal": orderData['shipping_status'] ?? "",
      "delivered_to_modal": orderData['delivered_to'] ?? "",
      "delivery_person_modal": orderData['delivery_person'] ?? "",
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
                    Get.to(() => PaymentPaidScreen());
      } else {
        print('Failed to send POST request');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Exception during POST request: $e');
    }
  }
}
