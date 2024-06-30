import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:nano/Model/SummaryModal.dart';

class SummaryController extends GetxController {
  var isLoading = true.obs;

  // This observable is for the single summary modal
  var summaryModal = SummaryModal(
    finalTotal: 0.0,
    tableName: '',
    staffName: '',
    products: [],
    typeofservice: '',
  ).obs;

  @override
  void onInit() {
    fetchOrderDetails(); // Initial call to fetchOrderDetails
    super.onInit();
  }

  void fetchOrderDetails() async {
    try {
      final response = await http.get(Uri.parse(
          'https://alarahi.nanotechnology.com.pk/api/order-single/1130/1'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        summaryModal.value = SummaryModal.fromJson(data);

        print(summaryModal.value);
      } else {
        print('Failed to load order details: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching order details: $e');
    } finally {
      isLoading.value = false; // Ensure loading indicator is turned off
    }
  }
}
