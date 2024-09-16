import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:nano/Model/OrderTable.dart';
import 'package:nano/View/Auth/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TableController extends GetxController {
  RxList<Map<String, dynamic>> allData = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filteredData = <Map<String, dynamic>>[].obs;
  RxList<bool> selections = <bool>[].obs;
  RxList<String> floors = <String>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }
  Future<String> _getBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedBaseUrl = prefs.getString('base_url') ?? "";

    return storedBaseUrl; // Return the value
  }

  Future<void> fetchData() async {
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
        final response = await http.get(
          Uri.parse('$baseUrl/api/get-table/$businessId/$locationId'),
        );

        if (response.statusCode == 200) {
          List<dynamic> jsonData = json.decode(response.body)['data'];
          List<Map<String, dynamic>> data =
              jsonData.cast<Map<String, dynamic>>();
          allData.value = data;

          // Extract unique floors
          Set<String> uniqueFloors =
              data.map((table) => table['floor'].toString()).toSet();
          floors.value = uniqueFloors.toList();
          selections.value = List<bool>.filled(floors.length, false);

          filterData(selections);
        } else {
          throw Exception('Failed to load data: ${response.statusCode}');
        }
      } else {
        Get.to(LoginPage());
      }
    } catch (e) {
      print('Error fetching data: $e');
      Get.snackbar('Error', 'Failed to load data');
    }
  }

  void filterData(RxList<bool> selections) {
    List<String> selectedFloors = [];
    for (int i = 0; i < selections.length; i++) {
      if (selections[i]) selectedFloors.add(floors[i]);
    }

    if (selectedFloors.isEmpty) {
      filteredData.value = allData;
    } else {
      filteredData.value = allData
          .where((table) => selectedFloors.contains(table['floor']))
          .toList();
    }
  }

  Future<OrderTableModal?> checkTableEmpty(int id, int businessId) async {
    String baseUrl = await _getBaseUrl();
    isLoading.value = true;
    print("id is $id and business id is $businessId");
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/table-check/$id/$businessId'),
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        print("---------------------------");
        print(responseData['unpaid_order']);

        if (responseData['unpaid_order'] != null) {
          var x = responseData['unpaid_order'];

// Manually mapping the JSON response to the OrderTableModal object
          var obj = OrderTableModal(
            id: x['id'] ?? 0,
            business_id: x['business_id'] ?? 0,
            location_id: x['location_id'] ?? 0,
            is_kitchen_order: x['is_kitchen_order'] ?? 0,
            res_table_id: x['res_table_id'],
            res_waiter_id: x['res_waiter_id'],
            type: x['type'] ?? '',
            status: x['status'] ?? '',
            is_quotation: x['is_quotation'] ?? 0,
            payment_status: x['payment_status'] ?? '',
            contact_id: x['contact_id'] ?? 0,
            invoice_no: x['invoice_no'] ?? '',
            transaction_date: x['transaction_date'] ?? '',
            total_before_tax: x['total_before_tax'] ?? '',
            tax_id: x['tax_id'] ?? 0,
            tax_amount: x['tax_amount'] ?? '',
            discount_type: x['discount_type'] ?? '',
            discount_amount: x['discount_amount'] ?? '',
            rp_redeemed: x['rp_redeemed'] ?? 0,
            rp_redeemed_amount: x['rp_redeemed_amount'] ?? '',
            shipping_charges: x['shipping_charges'] ?? '',
            finalTotal: x['final_total'] ?? '',
            is_suspend: x['is_suspend'] ?? 0,
            exchange_rate: x['exchange_rate'] ?? '',
            packing_charge: x['packing_charge'] ?? '',
            packing_charge_type: x['packing_charge_type'] ?? '',
            custom_field_1: x['custom_field_1'],
            custom_field_2: x['custom_field_2'],
            custom_field_3: x['custom_field_3'],
            custom_field_4: x['custom_field_4'],
            service_custom_field_1: x['service_custom_field_1'],
            service_custom_field_2: x['service_custom_field_2'],
            service_custom_field_3: x['service_custom_field_3'],
            is_created_from_api: x['is_created_from_api'] ?? 0,
            rp_earned: x['rp_earned'] ?? 0,
            recur_interval: x['recur_interval'] ?? '',
            recur_repetitions: x['recur_repetitions'] ?? 0,
            selling_price_group_id: x['selling_price_group_id'] ?? 0,
            created_at: x['created_at'] ?? '',
            updated_at: x['updated_at'] ?? '',
            recur_stopped_on: x['recur_stopped_on'] ?? '',
            recur_parent_id: x['recur_parent_id'] ?? '',
            invoice_token: x['invoice_token'] ?? '',
            pay_term_number: x['pay_term_number'] ?? '',
            pay_term_type: x['pay_term_type'] ?? '',
            typeOfService: x['types_of_service']?['name'] ?? 'Unknown Service',
            products: (x['sell_lines'] as List<dynamic>? ?? []).map((line) {
              var productData = line['product'] ?? {};
              return Product(
                id: productData['id'] ?? 0,
                transactionId: productData['transaction_id'] ?? 0,
                productId: productData['product_id'] ?? 0,
                variationId: productData['variation_id'] ?? 0,
                quantity: line['quantity']?.toString() ?? '0',
                secondaryUnitQuantity:
                    line['secondary_unit_quantity'] ?? '0.0000',
                quantityReturned: line['quantity_returned'] ?? '0.0000',
                unitPriceBeforeDiscount:
                    line['unit_price_before_discount'] ?? '0.0000',
                price: line['price'] ?? '0.0000',
                lineDiscountType: line['line_discount_type'] ?? 'fixed',
                lineDiscountAmount: line['line_discount_amount'] ?? '0.0000',
                unitPriceIncTax: line['unit_price_inc_tax'] ?? '0.0000',
                itemTax: line['item_tax'] ?? '0.0000',
                taxId: line['tax_id'],
                discountId: line['discount_id'],
                lotNoLineId: line['lot_no_line_id'],
                sellLineNote: line['sell_line_note'] ?? '',
                soLineId: line['so_line_id'],
                soQuantityInvoiced: line['so_quantity_invoiced'] ?? '0.0000',
                resServiceStaffId: line['res_service_staff_id'],
                resLineOrderStatus: line['res_line_order_status'],
                parentSellLineId: line['parent_sell_line_id'],
                childrenType: line['children_type'] ?? '',
                subUnitId: line['sub_unit_id'],
                createdAt: line['created_at'] ?? '',
                updatedAt: line['updated_at'] ?? '',
                businessId: productData['business_id'] ?? 0,
                name: productData['name'] ?? 'Unknown Product',
                type: productData['type'] ?? 'Unknown Type',
                unitId: productData['unit_id'] ?? 0,
                secondaryUnitId: productData['secondary_unit_id'],
                subUnitIds: productData['sub_unit_ids'],
                brandId: productData['brand_id'],
                categoryId: productData['category_id'],
                subCategoryId: productData['sub_category_id'],
                tax: productData['tax'],
                taxType: productData['tax_type'] ?? 'exclusive',
                enableStock: productData['enable_stock'] ?? 0,
                alertQuantity: productData['alert_quantity'] ?? '0.0000',
                sku: productData['sku'] ?? 'Unknown SKU',
              );
            }).toList(),
            tableName: x['table']?['name'] ?? 'Unknown Table',
            staffName: x['service_staff']?['first_name'] ?? 'Unknown Staff',
            jsonData: jsonEncode(x),
            transactionId: x['id'] ?? 0,
          );

          return obj;
        } else {
          return null;
        }
      } else {
        throw Exception('Failed to check table: ${response.statusCode}');
      }
    } catch (e) {
      print('Error checking table: $e');
      Get.snackbar('Error', 'Failed to check table');
      return null;
    }
  }
}
