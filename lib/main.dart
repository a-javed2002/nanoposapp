import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nano/View/Checkout.dart';
import 'package:nano/View/Login.dart';
import 'package:nano/View/Order.dart';
import 'package:nano/View/OrderTable.dart';
import 'package:nano/View/Splash/SplashScreen.dart';




void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme(
     
          brightness: Brightness.light,
           primary: Color.fromRGBO(144, 224, 239, 1),
            onPrimary: Color.fromRGBO(3, 4, 94, 1),
            secondary: Color.fromRGBO(202, 240, 248, 1),
            onSecondary: Color.fromRGBO(3, 4, 94, 1),
            error: Color.fromRGBO(193, 18, 31, 1),
            onError: Colors.white,
            surface: Color.fromRGBO(202, 240, 248, 1),
            onSurface: Color.fromRGBO(3, 4, 94, 1)
           ),
           textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Color.fromRGBO(3, 4, 94, 1)
            )
           ),
        inputDecorationTheme: InputDecorationTheme(

          filled: true,
                fillColor: Color.fromRGBO(144, 224, 239, 1),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(3, 4, 94, 1),
                    width: 5
                  ),
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                labelStyle: GoogleFonts.poppins(color: Color.fromRGBO(3, 4, 94, 1)),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
           backgroundColor: Color.fromRGBO(3, 4, 94, 1),
          foregroundColor: Colors.white,
          elevation: 8,
        ),
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            )
          ),
          backgroundColor: Color.fromRGBO(3, 4, 94, 1),
          foregroundColor: Colors.white,
          elevation: 8,
        )
      )
      ),
      debugShowCheckedModeBanner: false,
      title: 'Nano POS',
      home: OrderTable(),
    );
  }
}
