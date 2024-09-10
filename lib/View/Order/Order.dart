import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nano/Controller/OrderController.dart' as a;
import 'package:nano/Controller/TableController.dart';
import 'package:nano/Model/OrderTable.dart';
import 'package:nano/View/Home/OrderTable.dart';
import 'package:nano/View/Order/utils.dart';
import 'package:nano/View/Status_Screen/order_placed.dart';
import 'package:shared_preferences/shared_preferences.dart';

// class CheckoutBinding extends Bindings {
//   @override
//   void dependencies() {
//     Get.lazyPut<SummaryController>(() => SummaryController());
//   }
// }

class Order extends StatefulWidget {
  String? tablename;
  int? tableId;
  final OrderTableModal? order;

  Order(
      {super.key,
      required this.tablename,
      required this.tableId,
      required this.order});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  String? orderNote;

  int? numberOfPersons;

  late int? waiterId;

  late int? orderType;

  final TableController controller = Get.put(TableController());

  @override
  Widget build(BuildContext context) {
    final a.OrderController controller = Get.put(a.OrderController());
    print("table is ${widget.tableId}");
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nano POS',
          style: GoogleFonts.poppins(fontSize: 32),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Flexible(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Container(
                      color: Color.fromARGB(255, 133, 199, 253),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(() => Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Text(
                                  '${widget.tablename}  ${controller.cart.value.calculateSubtotal()} Rs',
                                  style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                              )),
                          Row(
                            children: [
                              IconButton(
                                  icon: const Icon(Icons.person, size: 30),
                                  onPressed: () => showDialog(
                                        context: context,
                                        builder: (context) =>
                                            NumberOfPersonsDialog(
                                          onNumberOfPersonsEntered:
                                              (numberOfPersons) {
                                            print(
                                                'Number of persons entered: $numberOfPersons');
                                            // Handle the number of persons input here
                                            this.numberOfPersons =
                                                numberOfPersons;
                                          },
                                        ),
                                      )),
                              IconButton(
                                  icon: Icon(Icons.note, size: 30),
                                  onPressed: () => showDialog(
                                        context: context,
                                        builder: (context) => OrderNoteDialog(
                                          onOrderNoteEntered: (orderNote) {
                                            print(
                                                'Order note entered: $orderNote');
                                            this.orderNote = orderNote;
                                            // Handle the order note input here
                                          },
                                        ),
                                      )),
                              IconButton(
                                icon: Icon(Icons.table_chart, size: 30),
                                onPressed: () =>
                                    _showTableSelectionDialog(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Obx(() => ListView.builder(
                            itemCount: controller.cart.value.items.length,
                            itemBuilder: (context, index) {
                              a.CartItem cartItem =
                                  controller.cart.value.items[index];
                              return Dismissible(
                                key: UniqueKey(),
                                direction: DismissDirection.startToEnd,
                                onDismissed: (direction) {
                                  controller.cart.value.items.removeAt(index);
                                  controller.cart.refresh();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "${cartItem.product.name} removed from cart"),
                                    ),
                                  );
                                },
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(left: 16.0),
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                child: ListTile(
                                  title: Row(
                                    children: [
                                      Expanded(
                                        flex: 7,
                                        child: Container(
                                          constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.7),
                                          child: Text(
                                            '${cartItem.product.name}',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 3,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Container(
                                          constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.4),
                                          child: Text(
                                            "${(cartItem.product.price * cartItem.quantity2).toInt()} Rs",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w300),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 2),
                                        height: 20,
                                        child: VerticalDivider(
                                          thickness: 1,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.remove),
                                        onPressed: () {
                                          controller.cart.value
                                              .decreaseQuantity(index);
                                          controller.cart.refresh();
                                        },
                                      ),
                                      Text('x${cartItem.quantity2}'),
                                      IconButton(
                                        icon: Icon(Icons.add),
                                        onPressed: () {
                                          controller.cart.value
                                              .increaseQuantity(index);
                                          controller.cart.refresh();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          controller.isLoading.value
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: () async {
                                    // Get.to(() => OrderPlaced());

                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    String? cartJson = prefs.getString('cart');
                                    print(
                                        'SharedPreferences data when click on place order: $cartJson');
                                    if (cartJson != null) {
                                      // Get the current date and time
                                      DateTime now = DateTime.now();

                                      // Create a DateFormat instance for 12-hour format
                                      DateFormat formatter =
                                          DateFormat('yyyy-MM-dd hh:mm a');

                                      // Format the date and time
                                      String formattedDate =
                                          formatter.format(now);
                                      List<dynamic> jsonData =
                                          jsonDecode(cartJson);
                                      print(jsonData);
                                      List<Product> products =
                                          jsonData.map((item) {
                                        var product = item['product'];
                                        return Product(
                                            id: product['id'],
                                            variationId: product['v_id'],
                                            name: product['name'],
                                            price: product['price'].toString(),
                                            categoryId: product['category_id'],
                                            quantity:
                                                item['quantity2'].toString());
                                      }).toList();
                                      var newOrder = OrderTableModal(
                                        id: 1, // Example value
                                        business_id: 1, // Example value
                                        location_id: 1, // Example value
                                        is_kitchen_order: 1, // Example value
                                        res_table_id: widget.tableId, // Example value
                                        res_waiter_id: 2, // Example value
                                        
                                        type: 'Dine-In', // Example value
                                        status: 'Pending', // Example value
                                        is_quotation: 0, // Example value
                                        payment_status: 'due', // Example value
                                        contact_id: 1, // Example value
                                        transaction_date:
                                            '2024-07-14 12:00:00 PM', // Example value
                                        total_before_tax:
                                            '3750.0', // Example value (sum of all product prices)
                                        tax_id: 1, // Example value
                                        tax_amount: '0.0', // Example value
                                        discount_type: 'None', // Example value
                                        discount_amount: '0.0', // Example value
                                        rp_redeemed: 0, // Example value
                                        rp_redeemed_amount:
                                            '0.0', // Example value
                                        shipping_charges:
                                            '0.0', // Example value
                                        finalTotal: '3750.0', // Example value
                                        is_suspend: 1, // Example value
                                        exchange_rate: '1.0', // Example value
                                        packing_charge: '0.0', // Example value
                                        packing_charge_type:
                                            null, // Example value
                                        custom_field_1: null, // Example value
                                        custom_field_2: null, // Example value
                                        custom_field_3: null, // Example value
                                        custom_field_4: numberOfPersons.toString(), // Example value
                                        additionalNotes: orderNote,
                                        recur_interval: null, // Example value
                                        typeOfService: "", // Example value
                                        products: products,
                                        tableName: 'Table 1', // Example value
                                        staffName: 'John Doe', // Example value
                                      );

                                      // Assuming you have the required data in shared preferences for other fields
                                      // OrderTableModal newOrder = OrderTableModal(
                                      //   products: jsonData
                                      //       .map((item) => Product.fromJson(item))
                                      //       .toList(),
                                      //   finalTotal:
                                      //       "0.0", // Assign proper value or calculate from the products list
                                      //   typeOfService: null,
                                      //   business_id: 1,
                                      //   contact_id: 1,
                                      //   pay_term_number: "",
                                      //   pay_term_type: "",
                                      //   custom_field_4: 1001,
                                      //   transaction_date: formattedDate,
                                      //   created_at: formattedDate,
                                      //   is_kitchen_order: 1,

                                      // );

                                      // Call the placeOrder function with the created order object
                                      if (newOrder.products.length > 0) {
                                        await controller.placeOrder(newOrder);
                                        print("Place order");
                                        Get.to(() => OrderPlaced(
                                              title: "Order Place",
                                            ));
                                      } else {
                                        showProductSelectionDialog(context);
                                      }
                                    } else {
                                      showProductSelectionDialog(context);
                                    }
                                    // controller.updateOrder(order!);
                                  },
                                  child: Text(
                                    'Place Order',
                                    style: GoogleFonts.poppins(fontSize: 24),
                                  )),
                          SizedBox(
                            width: 10,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: () async {
                              bool? confirmDelete = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Confirm Deletion'),
                                    content: Text(
                                        'Are you sure you want to delete?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirmDelete == true) {
                                controller.cart.value.clearCartPreferences();
                                controller.cart.refresh();
                              }
                            },
                            child: Icon(
                              Icons.delete,
                              size: 30,
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Obx(() {
            if (controller.selectedCategoryIndex.value == -1 ||
                controller.selectedCategoryIndex.value == 100000)
              return Expanded(
                child: Container(
                    child: Container(
                  color: Color.fromARGB(255, 235, 232, 232),
                  child: ListView(
                    children: <Widget>[
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: 4,
                              width: 35,
                              color: const Color.fromARGB(255, 77, 77, 77),
                            ),
                            SizedBox(
                              height: 3,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 100,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 18,
                            ),
                            Expanded(
                              child: TextField(
                                style: GoogleFonts.poppins(fontSize: 24),
                                decoration: InputDecoration(
                                  hintStyle: GoogleFonts.poppins(fontSize: 20),
                                  hintText: 'Category Search...',
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Icon(
                                      Icons.search,
                                      size: 25,
                                    ),
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 5),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.qr_code_scanner,
                                        size: 25,
                                      ),
                                      onPressed: () {
                                        // Add functionality for barcode scanning
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            PopupMenuButton<int>(
                              icon: Icon(
                                Icons.more_vert,
                                size: 30,
                              ),
                              onSelected: (item) {},
                              itemBuilder: (context) => [
                                PopupMenuItem<int>(
                                  value: 0,
                                  child: Text('Option 1'),
                                ),
                                PopupMenuItem<int>(
                                  value: 1,
                                  child: Text('Option 2'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Divider(),
                      Card(
                        margin: EdgeInsets.only(left: 13),
                        color: Color.fromARGB(255, 235, 232, 232),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: List.generate(
                            controller.categories.length,
                            (index) {
                              final randomColor =
                                  a.colors[a.random.nextInt(a.colors.length)];
                              return GestureDetector(
                                onTap: () {
                                  print("Category tapped at index $index");
                                  controller.selectCategory(index);
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 2 -
                                      20,
                                  height: 85,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(6),
                                      topLeft: Radius.circular(6),
                                      bottomRight: Radius.circular(4),
                                      topRight: Radius.circular(4),
                                    ),
                                    border: Border.all(
                                      color: controller.selectedCategoryIndex ==
                                              index
                                          ? Colors.blue
                                          : Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        decoration: BoxDecoration(
                                          color: randomColor,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(6),
                                            bottomLeft: Radius.circular(6),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Text(
                                            controller.categories[index].name,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 18,
                                              fontWeight: controller
                                                          .selectedCategoryIndex ==
                                                      index
                                                  ? FontWeight.w500
                                                  : FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                )),
              );
            else
              return Expanded(
                child: Container(
                  //color: Color.fromARGB(255, 255, 255, 255),
                  child: DraggableScrollableSheet(
                    initialChildSize: 0.9,
                    minChildSize: 0.25,
                    maxChildSize: 0.9,
                    builder: (BuildContext context,
                        ScrollController scrollController) {
                      return Container(
                        color: Color.fromARGB(255, 235, 232, 232),
                        child: ListView(
                          controller: scrollController,
                          children: <Widget>[
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 4,
                                    width: 35,
                                    color:
                                        const Color.fromARGB(255, 77, 77, 77),
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 100,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 18,
                                  ),
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: 'Item Search...',
                                        prefixIcon: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5),
                                          child: Icon(Icons.search),
                                        ),
                                        suffixIcon: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 5),
                                          child: IconButton(
                                            icon: Icon(Icons.qr_code_scanner),
                                            onPressed: () {
                                              // Add functionality for barcode scanning
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  PopupMenuButton<int>(
                                    icon: Icon(Icons.more_vert),
                                    onSelected: (item) {},
                                    itemBuilder: (context) => [
                                      PopupMenuItem<int>(
                                        value: 0,
                                        child: Text('Option 1'),
                                      ),
                                      PopupMenuItem<int>(
                                        value: 1,
                                        child: Text('Option 2'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Divider(),
                            Align(
                              alignment: Alignment.topLeft,
                              child: GestureDetector(
                                onTap: () {
                                  controller.selectCategory(-1);
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Icon(
                                    Icons.arrow_back,
                                    size: 30,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              color: Color.fromARGB(255, 235, 232, 232),
                              child: Obx(() => Column(
                                    children: [
                                      Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 5),
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          physics:
                                              AlwaysScrollableScrollPhysics(),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                  width:
                                                      15), // Space at the start of the row
                                              Text(
                                                'QTY',
                                                style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              SizedBox(width: 15),
                                              for (int i = 1; i <= 4; i++) ...[
                                                GestureDetector(
                                                  onTap: () {
                                                    controller
                                                        .selectQuantity(i);
                                                  },
                                                  child: Obx(() => Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          4)),
                                                          color: controller
                                                                      .selectedQuantity
                                                                      .value ==
                                                                  i
                                                              ? const Color
                                                                  .fromARGB(255,
                                                                  88, 180, 255)
                                                              : Colors.grey,
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      15,
                                                                  vertical: 10),
                                                          child: Text(
                                                            '$i',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    color: Colors
                                                                        .white),
                                                          ),
                                                        ),
                                                      )),
                                                ),
                                                SizedBox(
                                                    width:
                                                        15), // Space between quantity options
                                              ],
                                              GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                            'Custom Quantity'),
                                                        content: TextField(
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          onChanged: (value) {
                                                            controller
                                                                .selectQuantity(
                                                                    int.parse(
                                                                        value));
                                                          },
                                                        ),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child:
                                                                Text('Cancel'),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: Text('Save'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Text(
                                                  'CUSTOM',
                                                  style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                              SizedBox(
                                                  width:
                                                      15), // Space at the end of the row
                                            ],
                                          ),
                                        ),
                                      ),
                                      Wrap(
                                        spacing: 10.0,
                                        runSpacing: 10.0,
                                        children: controller
                                            .categories[controller
                                                .selectedCategoryIndex.value]
                                            .products
                                            .map((product) {
                                          return InkWell(
                                            onTap: () {
                                              controller.addToCart(product);
                                            },
                                            child: SizedBox(
                                              width: (MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.45),
                                              child: Card(
                                                elevation: 3,
                                                child: Stack(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            product.id
                                                                .toString(),
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        10),
                                                            child: Text(
                                                              product.name,
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 0,
                                                      left: 0,
                                                      child: CustomPaint(
                                                        size: Size(30, 30),
                                                        painter:
                                                            a.TrianglePainter(),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  )),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
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

  void _showTableSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TableSelectionDialog(
          tables: controller.filteredData,
          selectedTableId: widget.tableId,
          selectedTableName: widget.tablename,
          onTableSelected: (tablename, tableId) {
            // Handle the table selection
            print('Selected Table: $tablename, ID: $tableId');
            setState(() {
              widget.tableId = tableId;
            widget.tablename = tablename;
            });
          },
        );
      },
    );
  }

  void showProductSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: Text(
            'Select Product',
            style:
                GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Please select at least one product to place the order.',
            style: GoogleFonts.poppins(fontSize: 18),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
