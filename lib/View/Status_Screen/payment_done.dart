import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nano/Controller/OrderController.dart';
import 'package:nano/View/OrderTable.dart';
import 'package:google_fonts/google_fonts.dart';
class PaymentPaidScreen extends StatefulWidget {

  @override
  State<PaymentPaidScreen> createState() => _PaymentPaidScreenState();
}

class _PaymentPaidScreenState extends State<PaymentPaidScreen> {
  

  @override
  void initState() {
  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          
          Image.asset("assets/gifs/payment.gif"),
           Text(
            "THANK YOU!",
            style:  GoogleFonts.poppins(
                fontSize: 25,
             
                fontWeight: FontWeight.bold),
          ),
          
        Text(
            "PAYMENT DONE SUCCESSFULLY",
            style:  GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: const Center(
              child: Text(
                "You will be redirected to Dashboard shortly or click here to return to the home page",
                textAlign: TextAlign.center, 
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 45),
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12), // Adjust the radius as needed
                ),
             
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderTable(
               
                    ),
                  ),
                );
              },
              child: Text(
                "Dashboard",
                style:  GoogleFonts.poppins(),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 45),
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12), // Adjust the radius as needed
                ),
            
              ),
              onPressed: () {
              
              },
              child:  Text(
                "Print",
             style:  GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
