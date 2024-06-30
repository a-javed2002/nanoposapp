import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:nano/View/OrderTable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String emailLabelText = 'Email Address';
  String passwordLabelText = 'Password';
  final TextEditingController emailController =
      TextEditingController(text: 'owais altaf');
  final TextEditingController passwordController =
      TextEditingController(text: 'N@no786');

  Future<void> login() async {
    final String url = 'https://alarahi.nanotechnology.com.pk/api/login';
    final Map<String, dynamic> requestBody = {
      'username': emailController.text,
      'password': passwordController.text,
    };
    try {
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
          print('No categories found');
        // Save the data to shared preferences
   // Save the data to shared preferences
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('categories', jsonEncode(responseData['Categories']));
        await prefs.setString('products', jsonEncode(responseData['Products']));
        await prefs.setString('user', jsonEncode(responseData['User']));
  
        Get.to(OrderTable());
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        Get.snackbar('Invalid', 'Email or password is incorrect');
      }
    } catch (e) {
      print('Exception: $e');
      Get.snackbar('Error', 'An error occurred during login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/Lottie/HgdBrd017Y.json',
            width: 300,
            height: 300,
            repeat: false,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: TextStyle(
                  fontFamily: 'Poppins', color: Color.fromRGBO(3, 4, 94, 1)),
              controller: emailController,
              onChanged: (value) {
                setState(() {
                  emailLabelText = value.isEmpty ? 'Email Address' : '';
                });
              },
              onTap: () {
                setState(() {
                  emailLabelText = '';
                });
              },
              decoration: InputDecoration(
                labelText: emailLabelText,
              ),
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: TextStyle(
                  fontFamily: 'Poppins', color: Color.fromRGBO(3, 4, 94, 1)),
              controller: passwordController,
              onChanged: (value) {
                setState(() {
                  passwordLabelText = value.isEmpty ? 'Password' : '';
                });
              },
              onTap: () {
                setState(() {
                  passwordLabelText = '';
                });
              },
              obscureText: true,
              decoration: InputDecoration(
                labelText: passwordLabelText,
              ),
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: login,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Login',
                style: TextStyle(
                    fontFamily: 'Poppins', color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
