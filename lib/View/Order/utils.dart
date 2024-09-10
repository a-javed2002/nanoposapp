import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nano/Controller/TableController.dart';

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
  final TableController controller = Get.put(TableController());

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
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return TableSelectionDialog(
                    tables: controller.filteredData,
                    onTableSelected: (tableName, tableId) {
                      // Handle the table selection
                      print('Selected Table: $tableName, ID: $tableId');
                      
                    },
                  );
                },
              );
          },
        ),
      ],
    );
  }
}

class TableSelectionDialog extends StatefulWidget {
  final List<dynamic> tables;
  final void Function(String tableName, int tableId) onTableSelected;
  final int? selectedTableId;
  final String? selectedTableName;

  const TableSelectionDialog({
    required this.tables,
    required this.onTableSelected,
    this.selectedTableId,
    this.selectedTableName,
  });

  @override
  _TableSelectionDialogState createState() => _TableSelectionDialogState();
}

class _TableSelectionDialogState extends State<TableSelectionDialog> {
  late List<dynamic> _filteredTables;
  late String _selectedTableName;
  late int _selectedTableId;

// final TableNameController2 controller2 = Get.put(TableNameController2());
  final TableController controller = Get.put(TableController());
  @override
  void initState() {
    super.initState();
    // Filter tables to only include those with transaction == null
    _filteredTables =
        widget.tables.where((table) => table['transaction'] == null).toList();

    if (_filteredTables.isNotEmpty) {
      _selectedTableId = widget.selectedTableId?? _filteredTables[0]['id'];
      _selectedTableName = widget.selectedTableName?? _filteredTables[0]['name'];
    } else {
      _selectedTableId = -1;
      _selectedTableName = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12), // Enhanced corner radius
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Change Table',
              style: GoogleFonts.poppins(
                  fontSize: 22, fontWeight: FontWeight.bold)),
          IconButton(
            icon: Icon(Icons.filter_list_outlined, size: 30),
            onPressed: () {
              Navigator.of(context).pop();
              _showFilterDialog(context);
            },
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 300, // Set a fixed height for the dialog content
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // 4 columns in a row
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            childAspectRatio: 1.0, // Square grid cells
          ),
          itemCount: _filteredTables.length,
          itemBuilder: (BuildContext context, int index) {
            final table = _filteredTables[index];
            final isSelected = _selectedTableId == table['id'];

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTableName = table['name'];
                  _selectedTableId = table['id'];
                });
                widget.onTableSelected(_selectedTableName, _selectedTableId);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? Color(0xFF90E0EF)
                      : Color(0xFFFFFFFF), // Highlight selected table
                  border: Border.all(
                    color: isSelected ? Color(0xFF0077B6) : Color(0xFF03045E),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    table['name'],
                    style: GoogleFonts.poppins(
                      color: isSelected ? Colors.white : Color(0xFF03045E),
                      fontSize: 18,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('OK', style: GoogleFonts.poppins(fontSize: 20)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        // TextButton(
        //   child: Text('OK', style: GoogleFonts.poppins(fontSize: 20)),
        //   onPressed: () {
        //     if (_selectedTableId != -1) {
        //       widget.onTableSelected(_selectedTableName, _selectedTableId);
        //       Navigator.of(context).pop();
        //     } else {
        //       // Optionally show an alert if no table is selected
        //       ScaffoldMessenger.of(context).showSnackBar(
        //         SnackBar(content: Text('Please select a table.')),
        //       );
        //     }
        //   },
        // ),
      ],
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

class NumberOfPersonsField extends StatelessWidget {
  final TextEditingController controller;

  const NumberOfPersonsField({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Number of Persons',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter number of persons',
          ),
        ),
      ],
    );
  }
}

class OrderNoteField extends StatelessWidget {
  final TextEditingController controller;

  const OrderNoteField({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Note',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 6,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter order note',
          ),
        ),
      ],
    );
  }
}

class NumberOfPersonsDialog extends StatefulWidget {
  final void Function(int numberOfPersons) onNumberOfPersonsEntered;

  const NumberOfPersonsDialog(
      {Key? key, required this.onNumberOfPersonsEntered})
      : super(key: key);

  @override
  _NumberOfPersonsDialogState createState() => _NumberOfPersonsDialogState();
}

class _NumberOfPersonsDialogState extends State<NumberOfPersonsDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter Number of Persons'),
      content: TextFormField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'Enter number of persons',
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('OK'),
          onPressed: () {
            int numberOfPersons = int.tryParse(_controller.text) ?? 0;
            widget.onNumberOfPersonsEntered(numberOfPersons);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class OrderNoteDialog extends StatefulWidget {
  final void Function(String orderNote) onOrderNoteEntered;

  const OrderNoteDialog({Key? key, required this.onOrderNoteEntered})
      : super(key: key);

  @override
  _OrderNoteDialogState createState() => _OrderNoteDialogState();
}

class _OrderNoteDialogState extends State<OrderNoteDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter Order Note'),
      content: TextFormField(
        controller: _controller,
        maxLines: 5, // Adjust the number of lines as needed
        decoration: InputDecoration(
          hintText: 'Enter order note',
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('OK'),
          onPressed: () {
            String orderNote = _controller.text;
            widget.onOrderNoteEntered(orderNote);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class TableNameController2 extends GetxController {
  RxString tablename = ''.obs;
  var selectedTableName = ''.obs;
  var selectedTableId = 0.obs;

  void updateTableName(String tablename2) {
    tablename.value = tablename2;

    print(tablename);
  }
}
