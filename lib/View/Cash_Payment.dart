import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:nano/Controller/OrderController.dart';
import 'package:nano/View/Status_Screen/payment_done.dart';
import 'package:flutter/services.dart'; // Add this import

class CashPaymentController extends GetxController {
  final String? total;

  CashPaymentController({this.total});

  final TextEditingController paidController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  final FocusNode paidFocusNode = FocusNode(); // Add a FocusNode

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

  void goToPaymentPaidScreen() {
    Get.to(() => PaymentPaidScreen());
  }
}

class CashPayment extends StatelessWidget {
  final String? total;

  CashPayment({this.total});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CashPaymentController(total: total));
    final OrderController ordercontroller = Get.put(OrderController());

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Cash Payment',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
      ),
      body: Column(
        children: [
          Lottie.asset(
            'assets/Lottie/rvuK8x5tkm.json',
            repeat: false,
          ),
          TextField(
            style: TextStyle(fontFamily: 'Poppins'),
            enabled: false,
            controller: controller.totalAmountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Total Amount',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            style: TextStyle(fontFamily: 'Poppins'),
            controller: controller.paidController,
            focusNode: controller.paidFocusNode,
            keyboardType: TextInputType.numberWithOptions(
                decimal: true), // Ensure numeric keyboard
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(
                  r'^\d+\.?\d{0,2}')), // Allow digits and at most one dot
            ],
            decoration: const InputDecoration(labelText: 'Paid Amount'),
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 25),
            width: double.infinity,
            child: Obx(() => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14.0, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: (controller.paidAmount.value >=
                          (double.tryParse(controller.total ?? '0') ?? 0))
                      ? () {
                          controller.calculateAmountToReturn();
                          ordercontroller.cart.value.clearCartPreferences();
                          ordercontroller.cart.refresh();
                          controller
                              .goToPaymentPaidScreen(); // Navigate to home page
                        }
                      : null,
                  child: Text(
                    'Paid',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                )),
          ),
          Obx(() => Text(
                'Amount to return: ${controller.amountToReturn.value.toStringAsFixed(2)}',
                style: TextStyle(fontFamily: 'Poppins'),
              )),
        ],
      ),
    );
  }
}
