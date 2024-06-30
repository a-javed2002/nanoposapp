import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:get/get.dart';
import 'package:nano/View/Order.dart';
class MyTable extends StatefulWidget {
  const MyTable({super.key});

  @override
  State<MyTable> createState() => _MyTableState();
}

class _MyTableState extends State<MyTable> {
  List<bool> _selections = List<bool>.filled(3, false); // State of checkboxes

  final List<Color> colors = [Color.fromRGBO(3, 4, 94, 1), Colors.white, Color.fromRGBO(144, 224, 239, 1)];
  final Random random = Random();

  Color getRandomColor() {
    return colors[random.nextInt(colors.length)];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
 
      appBar: AppBar(
        title: Text('Select a table', style: GoogleFonts.poppins(fontSize: 20)),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list_outlined),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 5,
                left: 10,
                right: 10,
              ),
              child: Text(
                'My tables',
                // style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 5.0,
                crossAxisSpacing: 5.0,
                childAspectRatio: 1.0, // To maintain aspect ratio
              ),
              itemCount: 20,
              shrinkWrap: true,
              physics:
                  NeverScrollableScrollPhysics(), // Prevent GridView from scrolling
              itemBuilder: (BuildContext context, int index) {
                Color containerColor = getRandomColor();
                Color textColor = (containerColor == Colors.white || containerColor == Color.fromRGBO(144, 224, 239, 1))
                    ? Color.fromRGBO(3, 4, 94, 1)
                    : Colors.white;
                return GestureDetector(
                        onTap: () {
                    if (containerColor == Color.fromRGBO(3, 4, 94, 1)) {
                      _showAlreadyBookedAlert(context);
                    } else {
                        Get.to(() => Order(tableName: 'C-${index + 1}'));
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.grey, style: BorderStyle.solid, width: 1),
                      color: containerColor,
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: Center(
            
                      child: Text(
                        '',
                      style: TextStyle(fontFamily: 'Poppins',color: textColor),
                      ),
                    ),
                  ),
                );
              },
            ),
        
        
        
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FilterDialog(
          selections: _selections,
          onApply: (List<bool> selections) {
            setState(() {
              _selections = selections;
            });
          },
        );
      },
    );
  }

  void _showBottomSheet(BuildContext? context) {
    if (context != null) {
      FocusScope.of(context).requestFocus(FocusNode());
      showModalBottomSheet(shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
       topRight: Radius.circular(16),
       topLeft: Radius.circular(16)
      )),
        context: context,
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: () {
              // Prevent closing bottom sheet when tapped
            },
            child: Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                textDirection: TextDirection.ltr,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30,top: 20),
                    child: Align(
                      alignment: Alignment(-1, 0),
                      child: Text(
                        textAlign: TextAlign.left,
                        'Order Name',
                        style:
                            GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: TextField(
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[350],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(),
                    onPressed: () {
                    
                  }, child: Container(alignment: Alignment(0, 0),
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Text(
                      'Done',
                    style: TextStyle(fontFamily: 'Poppins',color:  Colors.white),
                    ),
                  ))
                ],
              ),
            ),
          );
        },
      );
    }
  }
}

class FilterDialog extends StatefulWidget {
  final List<bool> selections;
  final ValueChanged<List<bool>> onApply;

  const FilterDialog({
    required this.selections,
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
      title: Text('Show sections:',style: GoogleFonts.poppins(),),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            CheckboxListTile(
              value: _localSelections[0],
              onChanged: (bool? value) {
                setState(() {
                  _localSelections[0] = value!;
                });
              },
              title: Text('Backyard',style: GoogleFonts.poppins(),),
            ),
            CheckboxListTile(
              title: Text('Counter',style: GoogleFonts.poppins(),),
              value: _localSelections[1],
              onChanged: (bool? value) {
                setState(() {
                  _localSelections[1] = value!;
                });
              },
            ),
            CheckboxListTile(
              title: Text('Hall',style: GoogleFonts.poppins(),),
              value: _localSelections[2],
              onChanged: (bool? value) {
                setState(() {
                  _localSelections[2] = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel',style: GoogleFonts.poppins(),),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('OK',style: GoogleFonts.poppins(),),
          onPressed: () {
            widget.onApply(_localSelections);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
