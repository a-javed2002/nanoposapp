import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nano/Controller/AllOrderController.dart';
import 'package:nano/Model/OrderTable.dart';
import 'package:nano/View/Order/Order.dart';
import 'package:nano/View/Home/Table.dart';

class AllOrderTable extends StatelessWidget {
  final AllOrderController orderController = Get.put(AllOrderController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Orders',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    height: 200,
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            'Sort',
                            style:
                                TextStyle(fontFamily: 'Poppins', fontSize: 20),
                          ),
                          onTap: () {
                            // Handle sort action
                          },
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(
                                  'By Table',
                                  style: TextStyle(
                                      fontFamily: 'Poppins', fontSize: 10),
                                ),
                                onTap: () {
                                  // Handle sort by table action
                                },
                              ),
                              ListTile(
                                title: Text(
                                  'By Status',
                                  style: TextStyle(
                                      fontFamily: 'Poppins', fontSize: 10),
                                ),
                                onTap: () {
                                  // Handle sort by status action
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            icon: Icon(Icons.swap_vert),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle menu item selection here
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'option1',
                child: Text('All Order'),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView(
            children: [
              Row(children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8)))),
                    onPressed: () {},
                    child: Text(
                      'All',
                      style: TextStyle(fontFamily: 'Poppins'),
                    )),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8)))),
                    onPressed: () {},
                    child: Text(
                      'Kitchen',
                      style: TextStyle(fontFamily: 'Poppins'),
                    )),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8)))),
                    onPressed: () {},
                    child: Text(
                      'Delivered',
                      style: TextStyle(fontFamily: 'Poppins'),
                    )),
              ]),
              SizedBox(height: 20),
              Text(
                'Tabs',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
              SizedBox(height: 10),
              GetBuilder<AllOrderController>(
                init: orderController,
                builder: (controller) => StreamBuilder<List<OrderTableModal>>(
                  stream: controller.ordersStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error fetching data'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No orders available'));
                    } else {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 3 / 2,
                          mainAxisExtent:
                              MediaQuery.of(context).size.height * 0.40,
                        ),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final order = snapshot.data![index];
                          return GestureDetector(
                            onTap: () {
                              // Get.to(() => Order(
                              //       tableName: order.tableName,
                              //     ));
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: Alignment(-1, 0),
                                      child: Text(
                                        order.staffName!,
                                        style: TextStyle(fontFamily: 'Poppins'),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            "${order.typeOfService!}",
                                            style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 14),
                                            maxLines: 2,
                                            softWrap: true,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          order.tableName!,
                                          style:
                                              TextStyle(fontFamily: 'Poppins'),
                                        ),
                                      ],
                                    ),

                                    Divider(color: Colors.grey, thickness: 1),
                                    // Use Flexible to allow SingleChildScrollView to expand
                                    SingleChildScrollView(
                                      physics: AlwaysScrollableScrollPhysics(),
                                      child: Container(
                                        height: 100,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: order.products
                                                  .map(
                                                    (product) => Row(
                                                      children: [
                                                        Expanded(
                                                          child: Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    top: 10),
                                                            child: Text(
                                                              product.name,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Poppins',
                                                                fontSize: 12,
                                                              ),
                                                              maxLines: 2,
                                                              softWrap: true,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 10,
                                                                  left: 10),
                                                          child: Text(
                                                            product.quantity,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Poppins',
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    SizedBox(
                                        height: 8), // Adjust spacing as needed

                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      margin: EdgeInsets.only(top: 20),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Divider(
                                              color: Colors.grey, thickness: 1),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Align(
                                                  child: Text(
                                                    '${order.finalTotal} Rs',
                                                    style: TextStyle(
                                                        fontFamily: 'Poppins'),
                                                  ),
                                                  alignment:
                                                      Alignment.centerRight,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
