import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TableController extends GetxController {
  RxList<Map<String, dynamic>> allData = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filteredData = <Map<String, dynamic>>[].obs;
  RxList<bool> selections = <bool>[].obs;
  RxList<String> floors = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('https://alarahi.nanotechnology.com.pk/api/get-table/1/1'),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body)['data'];
        List<Map<String, dynamic>> data = jsonData.cast<Map<String, dynamic>>();
        allData.value = data;

        // Extract unique floors
        Set<String> uniqueFloors = data.map((table) => table['floor'].toString()).toSet();
        floors.value = uniqueFloors.toList();
        selections.value = List<bool>.filled(floors.length, false);

        filterData(selections);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
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
}
