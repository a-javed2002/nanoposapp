import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nano/Controller/OrderController.dart';
import 'package:nano/View/Home/OrderTable.dart';

class PaymentPaidScreen extends StatefulWidget {
  @override
  State<PaymentPaidScreen> createState() => _PaymentPaidScreenState();
}

class _PaymentPaidScreenState extends State<PaymentPaidScreen> {
  @override
  void initState() {
    super.initState();
    // Add a delay and redirect to the dashboard if needed
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderTable(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/gifs/payment.gif",
                  width: 350,
                  height: 350,
                ),
                Text(
                  "THANK YOU!",
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "PAYMENT DONE SUCCESSFULLY",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                      textAlign: TextAlign.center, // Center align t
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "You will be redirected to the Dashboard shortly or click here to return to the home page",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _buildDashboardButton(context),
                const SizedBox(height: 20),
                _buildPrintButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 45),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OrderTable(),
            ),
          );
        },
        child: Text(
          "Dashboard",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPrintButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 45),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          // Implement the print functionality here
        },
        child: Text(
          "Print",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
