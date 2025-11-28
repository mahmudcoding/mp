import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../main.dart';
import 'package:http/http.dart' as http;

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic> userData = {};

  bool isLoading = true;            // FIX
  String errorMessage = '';         // FIX
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile(); // FIX — use unified fetch method
  }

  // =======================
  // LOAD USER DATA (FIXED)
  // =======================
  Future<void> _fetchUserProfile() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final storage = FlutterSecureStorage();
      String? token = await storage.read(key: 'auth_token');

      if (token == null) {
        throw Exception("No token found");
      }

      var response = await http.get(
        Uri.parse('http://localhost:3001/api/profile/products'),
        headers: {
          'authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();   // FIX
      });
    }
  }

  void _btnPressed() {
    print('buttonpressed');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 3)),
    );
  }

  Widget _buildNavItem(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _selectedTab == index ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _selectedTab == index ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentContent() {
    switch (_selectedTab) {
      case 0:
        return Center(child: Text('Bought Items will appear here'));
      case 1:
        return Center(child: Text('Swapped Items will appear here'));
      case 2:
        return userData['products'] != null && userData['products'].length > 0
            ? ListView.builder(
          itemCount: userData['products'].length,
          itemBuilder: (context, index) {
            var product = userData['products'][index];
            return ListTile(
              leading: Icon(Icons.shopping_bag),
              title: Text(product['product_name']),
              subtitle: Text('\$${product['price']}'),
            );
          },
        )
            : Center(child: Text('No items yet'));
      default:
        return Center(child: Text('Select a tab'));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $errorMessage'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchUserProfile,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _btnPressed,
        icon: Icon(Icons.add),
        label: Text('Upload Product'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => MainPage()));
          },
        ),
        title: Text('Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // =======================
            // Profile Header
            // =======================
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.greenAccent,
                    child: Text('BO'),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData['user']['name'],
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Text(
                      userData['user']['email'],
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Spacer(),
                TextButton(
                  onPressed: () async {
                    final storage = FlutterSecureStorage();
                    await storage.deleteAll();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => MainPage()),
                    );
                    _showSnackBar("Logout Successful!");
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Logout',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // =======================
            // Nav Tabs
            // =======================
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  _buildNavItem('Bought', 0),
                  _buildNavItem('Swapped', 1),
                  _buildNavItem('Own Items', 2),
                ],
              ),
            ),

            SizedBox(height: 16),

            // =======================
            // Content Area
            // =======================
            Expanded(child: _buildCurrentContent()),
          ],
        ),
      ),
    );
  }
}