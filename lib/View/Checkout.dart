import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nano/Controller/SummaryController.dart';
import 'package:nano/Model/SummaryModal.dart';

import 'package:nano/View/Cash_Payment.dart';

class CheckoutPage extends StatelessWidget {
  final SummaryController summaryController = Get.find<SummaryController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Order Summary',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              GetBuilder<SummaryController>(
                init: summaryController, // Initialize your controller here
                builder: (_) {
                  return _buildOrderDetails(
                      summaryController, context); // Remove context parameter
                },
              ),
              SizedBox(height: 20),
              _buildSummary(),
              SizedBox(height: 20),
              _buildPaymentOptions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetails(SummaryController summaryController, context) {
    return SingleChildScrollView(
      child: Container(
          height: MediaQuery.of(context).size.height * 0.45,
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Details',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: summaryController.isLoading.isTrue
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: summaryController
                              .summaryModal.value.products.length,
                          itemBuilder: (context, index) {
                            final order = summaryController.summaryModal.value;
                            final product = order.products[index];
                            return Column(
                              children: [
                                _buildOrderItem(
                                    product, order.finalTotal.toString()),
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
            ),
          )),
    );
  }

  Widget _buildOrderItem(Product product, String finalTotal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 8,
            child: Text(
              '${product.name}',
              maxLines: 4,
            ),
          ),
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Text(
                  '${product.quantity} ',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  ' $finalTotal Rs',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
 Widget _buildSummary() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(),
          _buildSummaryRow('Subtotal', '${Get.find<SummaryController>().summaryModal.value.finalTotal}'), // Display finalTotal here
          _buildSummaryRow('Tax', '22 Rs'), // Example tax (replace with actual tax logic if needed)
          Divider(),
          _buildSummaryRow('Total', '33 Rs', fontWeight: FontWeight.bold), // Example total (replace with actual calculation if needed)
        ],
      ),
    );
  }
 
  Widget _buildSummaryRow(String title, String value,
      {FontWeight fontWeight = FontWeight.normal}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.poppins(fontWeight: fontWeight)),
          Text(value, style: GoogleFonts.poppins(fontWeight: fontWeight)),
        ],
      ),
    );
  }

  Widget _buildPaymentOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () {
            Get.to(() => CashPayment(
                  total: '1111',
                ));
          },
          child: Text('Pay with Cash'),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            print('Processing card payment');
          },
          child: Text('Pay with Card'),
        ),
      ],
    );
  }
}
