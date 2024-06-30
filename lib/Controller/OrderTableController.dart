// order_controller.dart
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:nano/Model/OrderTable.dart';
class OrderTableController extends GetxController {
  var orders = <OrderTableModal>[].obs;
  var isLoading = true.obs;

  late StreamController<List<OrderTableModal>> _ordersStreamController;

  @override
  void onInit() {
    _ordersStreamController = StreamController<List<OrderTableModal>>.broadcast();
    fetchOrders();
    super.onInit();
  }

  Stream<List<OrderTableModal>> get ordersStream => _ordersStreamController.stream;

  void fetchOrders() async {
    try {
      isLoading(true);
      var response = await http.get(Uri.parse('https://alarahi.nanotechnology.com.pk/api/orders'));
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        var fetchedOrders = (jsonData as List).map((order) => OrderTableModal.fromJson(order)).toList();
        orders.assignAll(fetchedOrders);
        _ordersStreamController.add(orders.toList());
      } else {
        // Handle error
      }
    } finally {
      isLoading(false);
    }
  }

  @override
  void dispose() {
    _ordersStreamController.close();
    super.dispose();
  }
}
