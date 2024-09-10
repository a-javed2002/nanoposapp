
  import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:nano/Controller/SummaryController.dart';
import 'package:nano/Model/SummaryModal.dart';

Widget _buildOrderDetails(SummaryController summaryController) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Details',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              summaryController.isLoading.isTrue
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: summaryController.summaryModal.value.products.length,
                      itemBuilder: (context, index) {
                        final order = summaryController.summaryModal.value;
                        return _buildOrderItem(order);
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItem(SummaryModal order) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: order.products.map((product) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product Name: ${product.name}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Quantity: ${product.quantity}',
                ),
                SizedBox(height: 8),
              ],
            )).toList(),
          ),
          SizedBox(height: 4),
          Text(
            'Total Amount: Rs ${order.finalTotal}',
          ),
          Divider(),
        ],
      ),
    );
  }
