import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nano/Controller/TableController.dart';
import 'package:nano/View/Order.dart';

class MyTable extends StatelessWidget {
  final TableController controller = Get.put(TableController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select a table', style: GoogleFonts.poppins(fontSize: 20)),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list_outlined),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.filteredData.isEmpty) {
          return Center(child: Text('No data available'));
        } else {
          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 5.0,
              crossAxisSpacing: 5.0,
              childAspectRatio: 1.0,
            ),
            itemCount: controller.filteredData.length,
            itemBuilder: (BuildContext context, int index) {
              Color containerColor;
              Color textColor;
              if (controller.filteredData[index]['transaction'] == null) {
                containerColor = Color.fromARGB(255, 255, 255, 255);
                textColor = Color.fromRGBO(3, 4, 94, 1);
              } else if (controller.filteredData[index]['transaction']['status'] == "draft") {
                containerColor = Color.fromRGBO(144, 224, 239, 1);
                textColor = Color.fromRGBO(3, 4, 94, 1);
              } else {
                containerColor = Color.fromRGBO(3, 4, 94, 1);
                textColor = Color.fromARGB(255, 255, 255, 255);
              }
              return GestureDetector(
                onTap: () {
                  if (containerColor == Color.fromRGBO(3, 4, 94, 1)) {
                    _showAlreadyBookedAlert(context);
                  } else {
                    Get.to(() => Order(tablename: controller.filteredData[index]['name']));
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: containerColor,
                    border: Border.all(
                      color: Colors.grey,
                      style: BorderStyle.solid,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Center(
                    child: Text(
                      controller.filteredData[index]['name'],
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }
      }),
    );
  }

  void _showAlreadyBookedAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Already Booked'),
          content: Text('This table is already booked.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
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
      title: Text('Show Floors:', style: GoogleFonts.poppins()),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.floors.asMap().entries.map((entry) {
            int index = entry.key;
            String floor = entry.value;
            return CheckboxListTile(
              title: Text(floor, style: GoogleFonts.poppins()),
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
          child: Text('Cancel', style: GoogleFonts.poppins()),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('OK', style: GoogleFonts.poppins()),
          onPressed: () {
            widget.onApply(_localSelections);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
