import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nano/Controller/OrderController.dart';
import 'package:nano/Controller/SummaryController.dart';
import 'package:nano/View/Checkout.dart';
import 'package:nano/View/Status_Screen/order_placed.dart';

class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SummaryController>(() => SummaryController());
  }
}


class Order extends StatelessWidget {
  final String? tablename;

  Order({this.tablename});
  
  @override
  Widget build(BuildContext context) {
    final OrderController controller = Get.put(OrderController());

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'Nano POS',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 20),
            ),
          ],
        ),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Flexible(
                child: Container(
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
                                    '${tablename != null ? 'Table : $tablename' : 'Guest-1 '}  ${controller.cart.value.calculateSubtotal()} Rs',
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                )),
                            PopupMenuButton<int>(
                              icon: Icon(Icons.more_vert),
                              onSelected: (item) {
                                switch (item) {
                                  case 0:
                                Get.to(() => CheckoutPage(), binding: CheckoutBinding());
                                    break;
                                  case 1:
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem<int>(
                                  value: 0,
                                  child: Text('Go to Checkout'), // Option 1
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
                                CartItem cartItem =
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
                            ElevatedButton(
                                onPressed: () {
                                  Get.to(() => OrderPlaced());
                                },
                                child: Text('Place Order')),
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
                              child: Icon(Icons.delete),
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
                                  decoration: InputDecoration(
                                    hintText: 'Item Search...',
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Icon(Icons.search),
                                    ),
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.only(right: 5),
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
                                    colors[random.nextInt(colors.length)];
                                return GestureDetector(
                                  onTap: () {
                                    print("Category tapped at index $index");
                                    controller.selectCategory(index);
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2 -
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
                                        color:
                                            controller.selectedCategoryIndex ==
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
                                                for (int i = 1;
                                                    i <= 4;
                                                    i++) ...[
                                                  GestureDetector(
                                                    onTap: () {
                                                      controller
                                                          .selectQuantity(i);
                                                    },
                                                    child: Obx(() => Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            4)),
                                                            color: controller
                                                                        .selectedQuantity
                                                                        .value ==
                                                                    i
                                                                ? const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    88,
                                                                    180,
                                                                    255)
                                                                : Colors.grey,
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        15,
                                                                    vertical:
                                                                        10),
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
                                                      builder: (BuildContext
                                                          context) {
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
                                                              child: Text(
                                                                  'Cancel'),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child:
                                                                  Text('Save'),
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
                                                            const EdgeInsets
                                                                .all(10.0),
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
                                                                style:
                                                                    GoogleFonts
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
                                                              TrianglePainter(),
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
          ],
        ),
      ),
    );
  }
}
