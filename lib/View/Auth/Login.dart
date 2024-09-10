import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:nano/View/Auth/settings.dart';
import 'dart:convert';
import 'package:nano/View/Home/OrderTable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String emailLabelText = 'Username';
  String passwordLabelText = 'Password';
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isObscure = true; // Initially obscure password
  bool isLoading = false; // Loading state
  String _password = '';

  @override
  void initState() {
    super.initState();
    _getStoredPassword();
  }

  Future<String> _getBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedBaseUrl = prefs.getString('base_url') ?? "";

    return storedBaseUrl; // Return the value
  }

  Future<void> login(BuildContext context) async {
    
    final Map<String, dynamic> requestBody = {
      'username': emailController.text,
      'password': passwordController.text,
    };

    print(_password);
    print("------------------------");
    print(passwordController.text);

    if (_password == passwordController.text) {
      Get.to(SettingsScreen());
      return;
    }

    String baseUrl = await _getBaseUrl();
    if (baseUrl == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Base URL Not Set!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final String url = '$baseUrl/api/login';
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData['Products']);

        // Save data to SharedPreferences
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'categories', jsonEncode(responseData['Categories']));
        await prefs.setString('products', jsonEncode(responseData['Products']));
        await prefs.setString('user', jsonEncode(responseData['User']));
        await prefs.setString(
            'tax_rates', jsonEncode(responseData['tax_rates']));

        Get.offAll(OrderTable());
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        Get.snackbar('Invalid', 'Username or password is incorrect');
      }
    } catch (e) {
      print('Exception: $e');
      Get.snackbar('Error', 'An error occurred during login');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _getStoredPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedPassword = prefs.getString('initial_password');

    setState(() {
      _password = storedPassword ?? 'No password found';
    });
  }

  void toggleObscureText() {
    setState(() {
      isObscure = !isObscure;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
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
                  fontFamily: 'Poppins',
                  color: Color.fromRGBO(3, 4, 94, 1),
                  fontSize: 24,
                ),
                controller: emailController,
                onChanged: (value) {
                  setState(() {
                    emailLabelText = value.isEmpty ? 'Username' : '';
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
                  fontFamily: 'Poppins',
                  color: Color.fromRGBO(3, 4, 94, 1),
                  fontSize: 24,
                ),
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
                obscureText: isObscure,
                decoration: InputDecoration(
                  labelText: passwordLabelText,
                  suffixIcon: IconButton(
                    icon: Icon(
                      isObscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: toggleObscureText,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: (){
                      login(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 8, bottom: 8, left: 12, right: 12),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontSize: 32,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
