import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nano/Controller/OrderTableController.dart';
import 'package:nano/Controller/PrintController.dart';
import 'package:nano/Controller/SummaryController.dart';
import 'package:nano/Model/OrderTable.dart';
import 'package:nano/View/AllOrder.dart';
import 'package:nano/View/Checkout.dart';
import 'package:nano/View/Order.dart';
import 'package:nano/View/Table.dart';

class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SummaryController>(() => SummaryController());
  }
}

class OrderTable extends StatefulWidget {
  @override
  State<OrderTable> createState() => _OrderTableState();
}

class _OrderTableState extends State<OrderTable> {
  final OrderTableController orderController = Get.put(OrderTableController());
  final PrintController printController = Get.put(PrintController());

  @override
  void initState() {
    super.initState();
    printController.initPlatformState();
  }

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
              if (value == 'allOrders') {
                Get.to(() => AllOrderTable());
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'allOrders',
                child: Text('All Orders'),
              ),
            ],
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Get.to(() => MyTable());
        },
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
              GetBuilder<OrderTableController>(
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
                          print(order);
                          return GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Options"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          title: Text("Print Kot"),
                                          onTap: () {
                                            // Handle print kot action
                                            Navigator.pop(
                                                context); // Close the dialog
                                            printController.printDialog(
                                                context: context);
                                          },
                                        ),
                                        ListTile(
                                          title: Text("Print ore bill"),
                                          onTap: () {
                                            // Handle print ore bill action
                                            Navigator.pop(
                                                context); // Close the dialog
                                          },
                                        ),
                                        ListTile(
                                          title: Text("Edit order"),
                                          onTap: () {
                                            // Handle edit order action
                                            Navigator.pop(
                                                context); // Close the dialog
                                          },
                                        ),
                                        ListTile(
                                          title: Text(
                                              'Pay ${order.products.isNotEmpty ? order.products.first.transactionid : ''}'),
                                          onTap: () {
                                            // Handle onTap action
                                            Get.to(() => CheckoutPage(),
                                                binding: CheckoutBinding());
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Item Is Ready',
                                            style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 14),
                                            maxLines: 2,
                                            softWrap: true,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          order.tableName,
                                          style:
                                              TextStyle(fontFamily: 'Poppins'),
                                        ),
                                      ],
                                    ),
                                    Divider(color: Colors.grey, thickness: 1),
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
                                                            product.quantity
                                                                .toString(), // Assuming quantity is an integer or double
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
                                    SizedBox(height: 8),
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
