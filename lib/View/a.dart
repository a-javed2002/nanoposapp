import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Orders',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    height: 250,
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.filter_list),
                          title: Text('Filter'),
                          onTap: () {
                            // Handle filter action
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.sort),
                          title: Text('Sort'),
                          onTap: () {
                            // Handle sort action
                          },
                        ),
                        // Add more options here
                      ],
                    ),
                  );
                },
              );
            },
            icon: Icon(Icons.swap_vert),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Get.to(() => MyTable());
        },
      ),
      body: Center(
        child: Text('Your main content here'),
      ),
    );
  }
}

class MyTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Table'),
      ),
      body: Center(
        child: Text('Table content here'),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MyHomePage(),
  ));
}
