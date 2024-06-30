import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nano/View/Login.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Color.fromRGBO(3, 4, 94, 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Nano POS',
              style: TextStyle(fontFamily: 'Poppins'
                    ,fontSize: 50,
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                    ),
              ),
              Center(
                child: Lottie.asset(
                  'assets/Lottie/1Q8ybemXun.json',
                  width: 300,
                  height: 300,
                  reverse: false,
                  repeat: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
