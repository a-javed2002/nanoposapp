import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NameScreen extends StatefulWidget {
  @override
  _NameScreenState createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final TextEditingController _baseUrlController = TextEditingController();
  String _currentBaseUrl = '';

  @override
  void initState() {
    super.initState();
    _getBaseUrl();
  }

  Future<void> _getBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedBaseUrl = prefs.getString('pos_name');
    setState(() {
      _currentBaseUrl = storedBaseUrl ?? 'No POS NAME set';
      _baseUrlController.text = storedBaseUrl ?? ''; // Populate TextField if URL exists
    });
  }

  Future<void> _updateBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('pos_name', _baseUrlController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('POS NAME updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    setState(() {
      _currentBaseUrl = _baseUrlController.text; // Update displayed POS NAME
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set/POS Name'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _getBaseUrl,
            tooltip: 'Refresh POS NAME',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current POS NAME:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal),
            ),
            SizedBox(height: 10),
            Text(
              _currentBaseUrl,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _baseUrlController,
              decoration: InputDecoration(
                labelText: 'Enter new POS NAME',
                labelStyle: TextStyle(color: Colors.teal),
                prefixIcon: Icon(Icons.shop, color: Colors.teal),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _updateBaseUrl,
              icon: Icon(Icons.update),
              label: Text('Update POS NAME'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
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
