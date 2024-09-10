import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nano/Controller/TableController.dart';
import 'package:nano/Model/OrderTable.dart';
import 'package:nano/View/Order/Order.dart';
import 'package:nano/View/Order/Order_Edit.dart';

class MyTable extends StatelessWidget {
  final TableController controller = Get.put(TableController());
  MyTable({super.key});

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Select a table', style: GoogleFonts.poppins(fontSize: 32)),
      actions: [
        IconButton(
          icon: Icon(
            Icons.filter_list_outlined,
            size: 30,
          ),
          onPressed: () => _showFilterDialog(context),
        ),
      ],
    ),
    body: Stack(
      children: [
        Obx(() {
          if (controller.filteredData.isEmpty) {
            return Center(child: CircularProgressIndicator());
          } else {
            return GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 5.0,
                crossAxisSpacing: 5.0,
                childAspectRatio: 1.0,
              ),
              itemCount: controller.filteredData.length,
              itemBuilder: (BuildContext context, int index) {
                Color containerColor;
                Color textColor;
                if (controller.filteredData[index]['transaction'] == null) {
                  containerColor = Color(0xFFFFFFFF);
                  textColor = Color(0xFF03045E);
                } else if (controller.filteredData[index]['transaction']['status'] == "draft") {
                  containerColor = Color(0xFF90E0EF);
                  textColor = Color.fromRGBO(3, 4, 94, 1);
                } else {
                  containerColor = Color.fromRGBO(3, 4, 94, 1);
                  textColor = Color.fromARGB(255, 255, 255, 255);
                }
                return GestureDetector(
                  onTap: () async {
                    controller.isLoading.value = true; // Start the loader
                    print(controller.filteredData[index]['id']);
                    print(controller.filteredData[index]['name']);
                    OrderTableModal? orderTable = await controller.checkTableEmpty(controller.filteredData[index]['id'], 1);
                    controller.isLoading.value = false; // Stop the loader
                    if (orderTable != null) {
                      controller.fetchData();
                      Get.to(() => OrderEdit(
                        tableId: controller.filteredData[index]['id'],
                        order: orderTable,
                        tablename: controller.filteredData[index]['name']
                      ));
                      print('Unpaid order: ${orderTable.jsonData}');
                    } else {
                      print('No unpaid order.');
                      Get.to(() => Order(
                        tableId: controller.filteredData[index]['id'],
                        order: orderTable,
                        tablename: controller.filteredData[index]['name']
                      ));
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: containerColor,
                      border: Border.all(
                        color: Color.fromRGBO(3, 4, 94, 1),
                        style: BorderStyle.solid,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Center(
                      child: Text(
                        controller.filteredData[index]['name'],
                        style: GoogleFonts.poppins(
                          color: textColor,
                          fontSize: 26,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        }),
        Obx(() {
          if (controller.isLoading.value) {
            return Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(child: CircularProgressIndicator()),
            );
          } else {
            return SizedBox.shrink();
          }
        }),
      ],
    ),
  );
}

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FilterDialog(
          selections: controller.selections,
          floors: controller.floors,
          onApply: (List<bool> selections) {
            controller.selections.value = selections;
            controller.filterData(controller.selections);
          },
        );
      },
    );
  }
}

class FilterDialog extends StatefulWidget {
  final RxList<bool> selections;
  final RxList<String> floors;
  final ValueChanged<List<bool>> onApply;

  const FilterDialog({
    required this.selections,
    required this.floors,
    required this.onApply,
  });

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late List<bool> _localSelections;

  @override
  void initState() {
    super.initState();
    _localSelections = List<bool>.from(widget.selections);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(4),
        ),
      ),
      title: Text('Show Floors:', style: GoogleFonts.poppins(fontSize: 26)),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.floors.asMap().entries.map((entry) {
            int index = entry.key;
            String floor = entry.value;
            return CheckboxListTile(
              title: Text(floor, style: GoogleFonts.poppins(fontSize: 20)),
              value: _localSelections[index],
              onChanged: (bool? value) {
                setState(() {
                  _localSelections[index] = value!;
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel', style: GoogleFonts.poppins(fontSize: 20)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('OK', style: GoogleFonts.poppins(fontSize: 20)),
          onPressed: () {
            widget.onApply(_localSelections);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
