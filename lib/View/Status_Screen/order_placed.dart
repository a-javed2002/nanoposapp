import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nano/Controller/OrderController.dart';
import 'package:nano/View/OrderTable.dart';

class OrderPlaced extends StatelessWidget {
  final GlobalKey lottieKey = GlobalKey();

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
              "Yahooo!",
            style: TextStyle(fontFamily: 'Poppins',
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "ORDER PLACED SUCCESSFULLY",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: const Center(
                child: Text(
                  "You will be redirected to Back shortly or click here to return to the home page",
                  textAlign: TextAlign.center,
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
                child: const Text(
                  "Back",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}



