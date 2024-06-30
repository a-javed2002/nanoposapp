import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'order_controller.dart'; // Ensure your controller is properly imported

class OrdersPage extends StatelessWidget {
  final OrderController orderController = Get.find<OrderController>(); // Ensure your controller is properly initialized

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body:
       GetBuilder<OrderController>(
        init: orderController,
        builder: (controller) => StreamBuilder<List<Order>>(
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
                  mainAxisExtent: MediaQuery.of(context).size.height * 0.35,
                ),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final order = snapshot.data![index];
                  return GestureDetector(
                    onTap: () {},
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    order.staffName,
                                    style: TextStyle(fontFamily: 'Poppins'),
                                    maxLines: 2,
                                    softWrap: true,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  order.tableName,
                                  style: TextStyle(fontFamily: 'Poppins'),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Align(
                                alignment: Alignment(-1, 0),
                                child: Text(
                                  'Item Is Ready',
                                  style: TextStyle(fontFamily: 'Poppins'),
                                ),
                              ),
                            ),
                            Divider(color: Colors.grey, thickness: 1),
                            // Use Flexible to allow SingleChildScrollView to expand
                            Flexible(
                              child: SingleChildScrollView(
                                physics: AlwaysScrollableScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: order.productNames
                                          .map(
                                            (productName) => Text(
                                              productName,
                                              style: TextStyle(fontFamily: 'Poppins'),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                    SizedBox(height: 16), // Adjust spacing as needed
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 8), // Adjust spacing as needed
                            Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Divider(color: Colors.grey, thickness: 1),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Align(
                                          child: Text(
                                            '${order.finalTotal} Rs',
                                            style: TextStyle(fontFamily: 'Poppins'),
                                          ),
                                          alignment: Alignment(1, 0),
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
      ),
   
   
    );
  }
}
