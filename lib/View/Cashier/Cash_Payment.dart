import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nano/Controller/OrderController.dart';
import 'package:nano/Model/OrderTable.dart';
import 'package:nano/View/Auth/Login.dart';
import 'package:nano/View/Status_Screen/payment_done.dart';
import 'package:flutter/services.dart'; // Add this import
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CashPaymentController extends GetxController {
  final String? total;

  CashPaymentController({this.total});

  final TextEditingController paidController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  final FocusNode paidFocusNode = FocusNode(); // Add a FocusNode
  RxBool loading = false.obs;

  var paidAmount = 0.0.obs;
  var amountToReturn = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    totalAmountController.text = total ?? '0';

    // Update amountToReturn whenever paidAmount changes
    ever(paidAmount, (_) {
      calculateAmountToReturn();
    });

    // Request focus when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(Get.context!).requestFocus(paidFocusNode);
    });
  }

  void calculateAmountToReturn() {
    double totalAmount = double.tryParse(total ?? '0') ?? 0;
    amountToReturn.value = paidAmount.value - totalAmount;
  }

  @override
  void onClose() {
    paidController.dispose();
    totalAmountController.dispose();
    paidFocusNode.dispose(); // Dispose the FocusNode
    super.onClose();
  }

  void updatePaidAmount(String value) {
    paidAmount.value = double.tryParse(value) ?? 0;
  }

  void appendPaidAmount(String value) {
    paidController.text += value;
    updatePaidAmount(paidController.text);
  }

  void clearPaidAmount() {
    paidController.text = '';
    updatePaidAmount(paidController.text);
  }

  // void goToPaymentPaidScreen() async {
  //   await pay();
  //   Get.to(() => PaymentPaidScreen());
  // }
  Future<String> _getBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedBaseUrl = prefs.getString('base_url') ?? "";

    return storedBaseUrl; // Return the value
  }

  Future<bool> pay(OrderTableModal order) async {
    String baseUrl = await _getBaseUrl();
    
    loading.value = true;
    final String url =
        'https://siroc.nanotechnology.com.pk/api/update/${order.transactionId}'; // Replace with your API endpoint
    print(order.transactionId);

    // Decode jsonData to extract nested fields
    Map<String, dynamic> orderData = jsonDecode(order.jsonData!);

    // Extracting product information from orderData['sell_lines']
    List<Map<String, dynamic>> products = [];
    for (var sellLine in orderData['sell_lines']) {
      products.add({
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
      });
    }

    print(orderData['transaction_date']);

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
      "contact_id": orderData['contact_id'],
      "search_product": "",
      "pay_term_number": orderData['pay_term_number'] ?? "",
      "pay_term_type": orderData['pay_term_type'] ?? "",
      "custom_field_4": orderData['custom_field_4'] ?? 0,
      "transaction_date": "24-06-2024 02:10 PM", // Update as needed
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
      "tax_rate_id": orderData['tax_rate_id'],
      "tax_calculation_amount": orderData['tax_calculation_amount'],
      "shipping_details": orderData['shipping_details'] ?? "",
      "shipping_address": orderData['shipping_address'] ?? "",
      "shipping_status": orderData['shipping_status'] ?? "",
      "delivered_to": orderData['delivered_to'] ?? "",
      "delivery_person": orderData['delivery_person'] ?? "",
      "shipping_charges": orderData['shipping_charges'],
      "advance_balance": "0.0000",
      "payment": [
        {
          "amount": order.finalTotal,
          "method": "cash", // Added missing method key
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
        }
      ],
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
      },
      "sale_note": orderData['sale_note'] ?? "",
      "staff_note": orderData['staff_note'] ?? "",
      "change_return": "0.00",
      "additional_notes": orderData['additional_notes'] ?? "",
      "is_suspend": 0,
      "recur_interval": orderData['recur_interval'],
      "recur_interval_type": orderData['recur_interval_type'],
      "recur_repetitions": orderData['recur_repetitions'] ?? "",
      "subscription_repeat_on": orderData['subscription_repeat_on'] ?? "",
      "is_enabled_stock": orderData['is_enabled_stock'] ?? "",
      "is_credit_sale": 0,
      "final_total": order.finalTotal,
      "discount_type_modal": orderData['discount_type'],
      "discount_amount_modal": orderData['discount_amount'],
      "order_tax_modal": orderData['order_tax_modal'] ?? 1,
      "shipping_details_modal": orderData['shipping_details_modal'] ?? "",
      "shipping_address_modal": orderData['shipping_address_modal'] ?? "",
      "shipping_charges_modal": orderData['shipping_charges_modal'] ?? "0.00",
      "shipping_status_modal": orderData['shipping_status_modal'] ?? "",
      "delivered_to_modal": orderData['delivered_to_modal'] ?? "",
      "delivery_person_modal": orderData['delivery_person_modal'] ?? "",
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
        return true;
      } else {
        print('Failed to send POST request');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception during POST request: $e');
        return false;
    }
    finally {
      loading.value = false;
    }
  }
}

class CashPayment extends StatelessWidget {
  final String? total;
  final OrderTableModal order;

  CashPayment({this.total, required this.order});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CashPaymentController(total: total));
    final OrderController ordercontroller = Get.put(OrderController());

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Cash Payment',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (constraints.maxWidth > 600) _buildLottieAnimation(),
                  _buildTotalAmountField(controller),
                  const SizedBox(height: 10),
                  _buildPaidAmountField(controller),
                  const SizedBox(height: 20),
                  _buildPaidButton(controller, ordercontroller),
                  const SizedBox(height: 20),
                  _buildAmountToReturnText(controller),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLottieAnimation() {
    return Lottie.asset(
      'assets/Lottie/rvuK8x5tkm.json',
      repeat: false,
      width: 300,
      height: 300,
    );
  }

  Widget _buildTotalAmountField(CashPaymentController controller) {
    return TextField(
      style: GoogleFonts.poppins(fontSize: 20),
      enabled: false,
      controller: controller.totalAmountController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Total Amount',
        labelStyle: GoogleFonts.poppins(fontSize: 16),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildPaidAmountField(CashPaymentController controller) {
    return TextField(
      style: GoogleFonts.poppins(fontSize: 20),
      controller: controller.paidController,
      focusNode: controller.paidFocusNode,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: 'Paid Amount',
        labelStyle: GoogleFonts.poppins(fontSize: 16),
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        controller.updatePaidAmount(value);
      },
    );
  }

  Widget _buildPaidButton(CashPaymentController controller, OrderController ordercontroller) {
    return Container(
      width: double.infinity,
      child: Obx(
        () => ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          onPressed: (controller.paidAmount.value >=
                  (double.tryParse(controller.total ?? '0') ?? 0) && !controller.loading.value)
              ? () async {
                  controller.calculateAmountToReturn();
                  ordercontroller.cart.value.clearCartPreferences();
                  ordercontroller.cart.refresh();
                  var chk = await controller.pay(order);
                  if (chk) {
                    controller.updatePaidAmount('0');
                    controller.paidAmount.value = 0;
                    Get.to(() => PaymentPaidScreen());
                  } else {
                    // Show an alert
                    Get.snackbar('Error', 'Payment failed.');
                  }
                }
              : null,
          child: controller.loading.value
              ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : Text(
                  'Pay',
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  Widget _buildAmountToReturnText(CashPaymentController controller) {
    return Obx(
      () => Text(
        'Amount to return: ${(controller.amountToReturn.value) >= 0 ? controller.amountToReturn.value.toStringAsFixed(2) : 0}',
        style: GoogleFonts.poppins(fontSize: 20, color: Colors.red),
      ),
    );
  }
}
