import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nano/View/Auth/baseUrl.dart';
import 'package:nano/View/Auth/updatePassword.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Settings header
            Text(
              'Account Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 20),
            // Update Password button
            ElevatedButton.icon(
              onPressed: () {
                Get.to(UpdatePasswordScreen());
              },
              icon: Icon(Icons.lock, color: Colors.white),
              label: Text('Update Password'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(vertical: 12),
                textStyle: TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Set Base URL button
            ElevatedButton.icon(
              onPressed: () {
                Get.to(BaseUrlScreen());
              },
              icon: Icon(Icons.link, color: Colors.white),
              label: Text('Set Base URL'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                padding: EdgeInsets.symmetric(vertical: 12),
                textStyle: TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Spacer(),
            // Footer with a logout button
            // ElevatedButton.icon(
            //   onPressed: () {
            //     // Handle logout
            //   },
            //   icon: Icon(Icons.logout, color: Colors.white),
            //   label: Text('Logout'),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.redAccent,
            //     padding: EdgeInsets.symmetric(vertical: 12),
            //     textStyle: TextStyle(fontSize: 16),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
