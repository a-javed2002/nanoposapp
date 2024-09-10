import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nano/Controller/OrderController.dart';
import 'package:nano/View/Home/OrderTable.dart';

class OrderPlaced extends StatelessWidget {
  final GlobalKey lottieKey = GlobalKey();
  final String title;

  // Constructor to accept title
  OrderPlaced({super.key, required this.title});

  Future<void> loadLottieAsset() async {
    await Future.delayed(Duration(milliseconds: 500)); // Simulate a small delay
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FutureBuilder(
              future: loadLottieAsset(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Text("Error loading animation");
                  } else {
                    return Container(
                      height: 300,
                      width: 300,
                      child: Lottie.asset(
                        "assets/Lottie/kNMKF7dgJ0.json",
                        key: lottieKey, // Add a key to the Lottie widget
                        width: 300,
                        height: 300,
                        repeat: false,
                        errorBuilder: (context, error, stackTrace) {
                          return Text("Error loading animation");
                        },
                      ),
                    );
                  }
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
       
          Text(
                "$title SUCCESSFULLY",
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center, // Center align text
              ),
            Container(
              margin:  EdgeInsets.symmetric(horizontal: 10),
              child:  Center(
                child: Text(
                  "You will be redirected to Back shortly or click here to return to the home page",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 45),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderTable(),
                    ),
                  );
                },
                child:  Text(
                  "Back",
                  style: GoogleFonts.poppins(color: Colors.white,fontSize: 26),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}



