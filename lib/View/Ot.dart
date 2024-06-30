import 'package:flutter/material.dart';


class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return 
    Scaffold(
     appBar: AppBar(
        title: 
            Text(
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
                          style: TextStyle(fontFamily: 'Poppins',fontSize: 20),
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
                                style: TextStyle(fontFamily: 'Poppins',fontSize: 10),
                                ),
                                onTap: () {
                                  // Handle sort by table action
                                },
                              ),
                              ListTile(
                                title: Text(
                                  'By Status',
                                style: TextStyle(fontFamily: 'Poppins',fontSize: 10),
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
        
        
          // IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Get.to(() => MyTable());
        },
      ),
      body:
       Container(
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
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 3 / 2,
                    mainAxisExtent: MediaQuery.of(context).size.height * 0.35),
                itemCount: 6, // Adjust the item count as needed
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => Order());
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: Column(
                                children: [
                                 
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('farya',
                                        style: TextStyle(fontFamily: 'Poppins')),
                                     Text(" C-${index + 1}",
                                        style: TextStyle(fontFamily: 'Poppins')),
                                    ],
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: Align(
                                      alignment: Alignment(-1, 0),
                                      child: Text('Item Is ready',
                                        style: TextStyle(fontFamily: 'Poppins')),
                                    ),
                                  ),
                                  Divider(
                                    color: Colors.grey,
                                    thickness: 1,
                                  ),
                                  Align(
                                    child: Text('Mexican',
                                      style: TextStyle(fontFamily: 'Poppins')),
                                    alignment: Alignment(-1, 0),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.height * 0.5,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Divider(
                                    color: Colors.grey,
                                    thickness: 1,
                                  ),
                                  Row(
                                           children:[

                              
                                  Align(
                                    child: Text(
                                      '10.00 Rs',
                                    style: TextStyle(fontFamily: 'Poppins'),
                                    ),
                                    alignment: Alignment(1, 0),
                                  ),
                                  ])
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    
    
    
    );
  
  
  }


}
