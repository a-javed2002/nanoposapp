import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:nano/Model/SummaryModal.dart';
import 'package:nano/View/Auth/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SummaryController extends GetxController {
  var isLoading = true.obs;
  var transactionid = 0.obs;

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
    print(transactionid);
    fetchOrderDetails(); // Initial call to fetchOrderDetails
    super.onInit();
  }
  Future<String> _getBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedBaseUrl = prefs.getString('base_url') ?? "";

    return storedBaseUrl; // Return the value
  }

  Future<void> fetchOrderDetails() async {
    String baseUrl = await _getBaseUrl();
    print("fetching data of $transactionid");
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
      final response = await http.get(Uri.parse(
          'https://$baseUrl/api/order-single/$transactionid/$businessId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        summaryModal.value = SummaryModal.fromJson(data);

        print(summaryModal.value);
      } else {
        print('Failed to load order details: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
      }
      else{
        Get.to(LoginPage());
      }

    } catch (e) {
      print('Error fetching order details: $e');
    } finally {
      isLoading.value = false; // Ensure loading indicator is turned off
    }
  }
}
