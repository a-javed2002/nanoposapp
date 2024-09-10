import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async'; // Import Timer library

import 'package:nano/Controller/OrderTableController.dart';
import 'package:nano/Controller/PrintController.dart';
import 'package:nano/Controller/SummaryController.dart';
import 'package:nano/Model/OrderTable.dart';
import 'package:nano/View/HAR/AllOrder.dart';
import 'package:nano/View/Cashier/Checkout.dart';
import 'package:nano/View/Auth/Login.dart';
import 'package:nano/View/Order/Order.dart';
import 'package:nano/View/Home/Table.dart';
import 'package:flip_card/flip_card.dart';
import 'package:nano/View/Order/Order_Edit.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final SummaryController summaryController = Get.find<SummaryController>();
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  final Map<String, bool> _isAccept = {};
  final Map<String, bool> _isReject = {};
  final Map<String, bool> _isPrintKOT = {};
  final Map<String, bool> _isPrintPreBill = {};
  final Map<String, bool> _isEditOrder = {};
  final Map<String, bool> _isPay = {};

  @override
  void initState() {
    super.initState();
    printController.initPlatformState();
    _startPeriodicFetch();
  }

  void _startPeriodicFetch() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      orderController
          .fetchOrders(); // Assume fetchOrders is the method to fetch data
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: _buildAppBar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(160, 2, 126, 163),
        child: Icon(Icons.add, size: 40),
        onPressed: () {
          Get.to(() => MyTable());
        },
      ),
      body: _buildBody(),
    );
  }

  Widget _buildDrawer() {
  return Drawer(
    child: ListView(
      children: [
        Container(
          height: 250,
          child: DrawerHeader(
            curve: Curves.bounceIn,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    width: 100,
                    height: 100,
                    child: Image.asset('assets/images/profile.png'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Obx(() => Text(
                        orderController.username.value,
                        style: GoogleFonts.poppins(
                            fontSize: 25, fontWeight: FontWeight.w500),
                      )),
                ),
              ],
            ),
          ),
        ),
        _buildDrawerItems(),
      ],
    ),
  );
}


  Widget _buildDrawerItems() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(
                    'Last Bill',
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
        Divider(color: Colors.grey, thickness: 1),
        Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(
                'Logout',
                style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.red),
              ),
              onTap: () {
                Get.offAll(LoginPage());
              },
            ),
          ),
        )
      ],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'Orders',
        style: GoogleFonts.poppins(fontSize: 32),
      ),
      // actions: [
      //   IconButton(
      //     onPressed: () {
      //       showModalBottomSheet(
      //         context: context,
      //         builder: (BuildContext context) {
      //           return Container(
      //             height: 200,
      //             child: Column(
      //               children: [
      //                 ListTile(
      //                   title: Text(
      //                     'Sort',
      //                     style: TextStyle(fontFamily: 'Poppins', fontSize: 20),
      //                   ),
      //                   onTap: () {
      //                     // Handle sort action
      //                   },
      //                 ),
      //                 Container(
      //                   margin: EdgeInsets.only(left: 10),
      //                   child: Column(
      //                     children: [
      //                       ListTile(
      //                         title: Text(
      //                           'By Table',
      //                           style: TextStyle(
      //                               fontFamily: 'Poppins', fontSize: 10),
      //                         ),
      //                         onTap: () {
      //                           // Handle sort by table action
      //                         },
      //                       ),
      //                       ListTile(
      //                         title: Text(
      //                           'By Status',
      //                           style: TextStyle(
      //                               fontFamily: 'Poppins', fontSize: 10),
      //                         ),
      //                         onTap: () {
      //                           // Handle sort by status action
      //                         },
      //                       ),
      //                     ],
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           );
      //         },
      //       );
      //     },
      //     icon: Icon(Icons.swap_vert, size: 30),
      //   ),
      //   PopupMenuButton<String>(
      //     iconSize: 30,
      //     onSelected: (value) {
      //       if (value == 'allOrders') {
      //         Get.to(() => AllOrderTable());
      //       }
      //     },
      //     itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
      //       const PopupMenuItem<String>(
      //         value: 'allOrders',
      //         child: Text('All Orders'),
      //       ),
      //     ],
      //   )
      // ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildButtonScroll(),
            // SizedBox(height: 20),
            // Text(
            //   'Tabs',
            //   style: GoogleFonts.poppins(fontSize: 20),
            // ),
            SizedBox(height: 20),
            _buildOrderList(),
          ],
        ),
      ),
    );
  }

  // Widget _buildBody() {
  //   return ScrollbarTheme(
  //       data: ScrollbarThemeData(
  //         thumbColor: MaterialStateProperty.all(Colors.black),
  //         thickness: MaterialStateProperty.all(12.0),
  //         radius: Radius.circular(5.0),
  //       ),
  //       child: Scrollbar(
  //         controller: _scrollController,
  //         thumbVisibility: true, // Always show the scrollbar
  //         child: ScrollConfiguration(
  //           behavior: ScrollBehavior().copyWith(overscroll: false),
  //           child: SingleChildScrollView(
  //             controller: _scrollController,
  //             child: Container(
  //               padding: const EdgeInsets.all(8.0),
  //               margin: EdgeInsets.only(right: 5),
  //               child: Column(
  //                 children: [
  //                   _buildButtonScroll(),
  //                   SizedBox(height: 20),
  //                   _buildOrderList(),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //       ));
  // }

  Widget _buildButtonScroll() {
  return Scrollbar(
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Obx(() => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  backgroundColor: orderController.selectedFilter.value == 0
                      ? Colors.blue // Highlighted color
                      : Colors.grey, // Default color
                ),
                onPressed: () {
                  orderController.filterOrders(0); // Show all orders
                },
                child: Text(
                  'All',
                  style: GoogleFonts.poppins(
                    fontSize: orderController.selectedFilter.value == 0
                        ? 28 // Highlighted size
                        : 25, // Default size
                  ),
                ),
              )),
          SizedBox(width: 2),
          Obx(() => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  backgroundColor: orderController.selectedFilter.value == 1
                      ? Colors.blue // Highlighted color
                      : Colors.grey, // Default color
                ),
                onPressed: () {
                  orderController.filterOrders(1); // Show kitchen orders
                },
                child: Text(
                  'Kitchen',
                  style: GoogleFonts.poppins(
                    fontSize: orderController.selectedFilter.value == 1
                        ? 28 // Highlighted size
                        : 25, // Default size
                  ),
                ),
              )),
          SizedBox(width: 2),
          Obx(() => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  backgroundColor: orderController.selectedFilter.value == 2
                      ? Colors.blue // Highlighted color
                      : Colors.grey, // Default color
                ),
                onPressed: () {
                  orderController.filterOrders(2); // Show non-kitchen orders
                },
                child: Text(
                  'Others',
                  style: GoogleFonts.poppins(
                    fontSize: orderController.selectedFilter.value == 2
                        ? 28 // Highlighted size
                        : 25, // Default size
                  ),
                ),
              )),
        ],
      ),
    ),
  );
}


  Widget _buildOrderList() {
  return GetBuilder<OrderTableController>(
    init: orderController,
    builder: (controller) => StreamBuilder<List<OrderTableModal>>(
      stream: controller.ordersStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error fetching data'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child: Text('No orders available',
                  style: GoogleFonts.poppins(fontSize: 20)));
        } else {
          return GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 2,
              mainAxisSpacing: 6,
              childAspectRatio: 3 / 2,
              mainAxisExtent: MediaQuery.of(context).size.height * 0.40,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return _buildOrderCard(snapshot.data![index]);
            },
          );
        }
      },
    ),
  );
}


  Widget _buildOrderCard(OrderTableModal order) {
    return FlipCard(
      front: Card(
        color: order.status == "final" ? Color(0xFF03045E) : Color(0xFF90E0EF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 10,
        shadowColor: Colors.black26,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      'Status',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: order.status == "final"
                            ? Color(0xFF90E0EF)
                            : Color(0xFF03045E),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      order.tableName!,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: order.status == "final"
                            ? Color(0xFF90E0EF)
                            : Color(0xFF03045E),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.grey.shade300, thickness: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: order.products.length,
                  itemBuilder: (context, index) {
                    final product = order.products[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 3,
                            child: Text(
                              product.name,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: order.status == "final"
                                    ? Color(0xFF90E0EF)
                                    : Color(0xFF03045E),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            flex: 1,
                            child: Text(
                              product.quantity.toString(),
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: order.status == "final"
                                    ? Color(0xFF90E0EF)
                                    : Color(0xFF03045E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 8),
              Divider(color: Colors.grey.shade300, thickness: 1),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${double.parse(order.finalTotal!).toStringAsFixed(2)} Rs',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: order.status == "final"
                        ? Color(0xFF90E0EF)
                        : Color(0xFF03045E),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      back: _buildOrderOptions(order),
    );
  }

  Widget _buildOrderOptions(OrderTableModal order) {
    List<Map<String, dynamic>> options = [
      {"title": "", "icon": Icons.print, "onTap": () => handleOption(1, order)},
      {
        "title": "",
        "icon": Icons.receipt,
        "onTap": () => handleOption(2, order)
      },
      {"title": "", "icon": Icons.edit, "onTap": () => handleOption(3, order)},
      {
        "title": "",
        "icon": Icons.payment,
        "onTap": () => handleOption(4, order)
      },
    ];
    return Card(
      color: order.status == "final" ? Color(0xFF03045E) : Color(0xFF90E0EF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 10,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // mainAxisSize: MainAxisSize.min,
            children: [
              if (order.status != "final") ...[
                _buildOptionTile(
                  title: "Accept",
                  color: Colors.green,
                  icon: Icons.check,
                  onTap: () {
                    orderController.acceptOrder(context, order);
                  },
                ),
                _buildOptionTile(
                  title: "Reject",
                  color: Colors.red,
                  icon: Icons.close,
                  onTap: () async {
                    await orderController.reject(context, order.transactionId!);
                  },
                ),
              ] else ...[
                // _buildOptionTile(
                //   title: "Print KOT",
                //   color: Colors.white,
                //   icon: Icons.print,
                //   onTap: () {
                //     // summaryController.transactionid.value = order.transactionId;
                //     printController.printDialog(
                //         context: context, order: order, billStatus: "KOT");
                //   },
                // ),
                // _buildOptionTile(
                //   title: "Print Pre Bill",
                //   color: Colors.white,
                //   icon: Icons.receipt,
                //   onTap: () {
                //     // Navigator.pop(context);
                //     printController.printDialog(
                //         context: context,
                //         order: order,
                //         billStatus: "PRE-BILL",
                //         finall: true);
                //   },
                // ),
                // _buildOptionTile(
                //   title: "Edit Order",
                //   color: Colors.white,
                //   icon: Icons.edit,
                //   onTap: () {
                //     // Navigator.pop(context);
                //     Get.to(() => OrderEdit(
                //         order: order,
                //         tablename: order.tableName,
                //         tableId: order.res_table_id));
                //   },
                // ),
                // _buildOptionTile(
                //   title:
                //       'Pay',
                //   color: Colors.white,
                //   icon: Icons.payment,
                //   onTap: () {
                //     showPaymentDialog(
                //         context, double.parse(order.finalTotal!), order);
                //   },
                // ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                  ),
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: options[index]["onTap"],
                      child: Card(
                        elevation: 5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(options[index]["icon"], size: 50),
                            // SizedBox(height: 10),
                            // Text(options[index]["title"]),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void handleOption(int optionNumber, OrderTableModal order) async {
    // Define what happens when each option is tapped.
    print('Option $optionNumber selected');
    if (optionNumber == 1) {
      printController.printDialog(
          context: context, order: order, billStatus: "KOT");
    } else if (optionNumber == 2) {
      printController.printDialog(
          context: context, order: order, billStatus: "PRE-BILL", finall: true);
    } else if (optionNumber == 3) {
      Get.to(() => OrderEdit(
          order: order,
          tablename: order.tableName,
          tableId: order.res_table_id));
    } else if (optionNumber == 4) {
      showPaymentDialog(context, double.parse(order.finalTotal!), order);
    }
  }

  void showPaymentDialog(
      BuildContext context, double amount, OrderTableModal order) async {
    if (kDebugMode) {
      print(order.tax_id);
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? taxJson = prefs.getString('tax_rates');
    if (kDebugMode) {
      print(taxJson);
    }
    if (taxJson != null) {
      List<dynamic> taxList = json.decode(taxJson);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            title: Text(
              'Payment Options',
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Pay ${amount.toStringAsFixed(2)} Rs',
              style: GoogleFonts.poppins(fontSize: 18),
            ),
            actions: taxList.map<Widget>((tax) {
              bool isMatchedTax = order.tax_id == tax['id'];
              return TextButton.icon(
                icon: Icon(
                  tax['name'].toLowerCase().contains('cash')
                      ? Icons.money
                      : Icons.credit_card,
                  color: isMatchedTax ? Colors.green : Colors.blue,
                ),
                label: Text(
                  tax['name'],
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isMatchedTax ? Colors.green : Colors.blue),
                ),
                onPressed: () async {
                  print("${tax['name']} pay");
                  if (tax['name'].toLowerCase().contains('card')) {
                    print("${tax['name']} --- ${tax['id']}");
                    if (order.tax_id == tax['id']) {
                      Navigator.of(context).pop();
                      Get.to(
                          () =>
                              CheckoutPage(order: order, taxName: tax['name']),
                          );
                    } else {
                      print("hohoo1 ${tax['id']}");
                      order.tax_id = tax['id'];
                      var x = await orderController.acceptOrder(context, order,
                          temp: false);
                      print("updated-1");
                      if (x != null) {
                        Get.to(
                            () => CheckoutPage(order: x, taxName: tax['name'],),
                            );
                      } else {
                        print("error1 in making upadated order");
                        Navigator.of(context).pop();
                        Get.to(
                            () => CheckoutPage(
                                order: order, taxName: tax['name']),
                            );
                      }
                    }
                  } else if (tax['name'].toLowerCase().contains('cash')) {
                    print("${tax['name']} --- ${tax['id']}");
                    if (order.tax_id == tax['id']) {
                      Navigator.of(context).pop();
                      Get.to(
                          () =>
                              CheckoutPage(order: order, taxName: tax['name']),
                          );
                    } else {
                      print("hohoo ${tax['id']}");
                      order.tax_id = tax['id'];
                      var x = await orderController.acceptOrder(context, order,
                          temp: false);
                      print("updated-2");
                      if (x != null) {
                        Get.to(
                            () => CheckoutPage(order: x, taxName: tax['name']),
                            );
                      } else {
                        print("error2 in making upadated order");
                        Navigator.of(context).pop();
                        Get.to(
                            () => CheckoutPage(
                                order: order, taxName: tax['name']),
                            );
                      }
                    }
                  }
                },
              );
            }).toList(),
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            title: Text(
              'Payment Options',
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Pay ${amount.toStringAsFixed(2)} Rs',
              style: GoogleFonts.poppins(fontSize: 18),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Get.to(
                        () => CheckoutPage(order: order, taxName: ""),
                        );
                  },
                  child: Text("Pay"))
            ],
          );
        },
      );
    }
  }

  Widget _buildOptionTile({
    String title = "",
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
          onTap: onTap,
          contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          tileColor: color == Colors.white
              ? Colors.transparent
              : color.withOpacity(0.1),
          leading: Icon(icon, color: color),
        ),
        Divider(color: Colors.grey.shade300, thickness: 1),
      ],
    );
  }
}
