import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nano/View/Auth/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdatePasswordScreen extends StatefulWidget {
  @override
  _UpdatePasswordScreenState createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscured = true;

  Future<void> _updatePassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('initial_password', _passwordController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Password updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    Get.offAll(LoginPage()); // Go back to previous screen after update
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Password'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              obscureText: _isObscured,
              decoration: InputDecoration(
                labelText: 'Enter new password',
                labelStyle: TextStyle(color: Colors.deepPurple),
                prefixIcon: Icon(Icons.lock, color: Colors.deepPurple),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility : Icons.visibility_off,
                    color: Colors.deepPurple,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                ),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _updatePassword,
              icon: Icon(Icons.update),
              label: Text('Update Password'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
