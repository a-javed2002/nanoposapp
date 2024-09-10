import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseUrlScreen extends StatefulWidget {
  @override
  _BaseUrlScreenState createState() => _BaseUrlScreenState();
}

class _BaseUrlScreenState extends State<BaseUrlScreen> {
  final TextEditingController _baseUrlController = TextEditingController();
  String _currentBaseUrl = '';

  @override
  void initState() {
    super.initState();
    _getBaseUrl();
  }

  Future<void> _getBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedBaseUrl = prefs.getString('base_url');
    setState(() {
      _currentBaseUrl = storedBaseUrl ?? 'No base URL set';
      _baseUrlController.text = storedBaseUrl ?? ''; // Populate TextField if URL exists
    });
  }

  Future<void> _updateBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('base_url', _baseUrlController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Base URL updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    setState(() {
      _currentBaseUrl = _baseUrlController.text; // Update displayed base URL
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set/Update Base URL'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _getBaseUrl,
            tooltip: 'Refresh Base URL',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Base URL:',
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
                labelText: 'Enter new base URL',
                labelStyle: TextStyle(color: Colors.teal),
                prefixIcon: Icon(Icons.link, color: Colors.teal),
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
              label: Text('Update Base URL'),
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
