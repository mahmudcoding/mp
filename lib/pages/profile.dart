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
  bool loading = true;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    loadProducts(); // Runs once when page loads
  }

  Future<void> loadProducts() async {
    try {
      final storage = FlutterSecureStorage();
      String? token = await storage.read(key: 'auth_token');

      if (token == null) {
        throw Exception('No token found');
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
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  void _btnPressed() {
    print('buttonpressed');
  }

  // Helper function to show messages
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Widget _buildNavItem(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
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
      case 0: // Bought
        return Center(child: Text('Bought Items will appear here'));
      case 1: // Swapped
        return Center(child: Text('Swapped Items will appear here'));
      case 2:
        return userData['products']?.length > 0
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
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _btnPressed,
          label: Text('Upload Product'),
          icon: Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => MainPage()));
          },
        ),
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: loading
            ? Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.greenAccent,
                          child: const Text('BO'),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userData['user']['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              )),
                          Text(
                            userData['user']['email'],
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          )
                        ],
                      ),
                      Spacer(),
                      TextButton(
                        onPressed: () async {
                          final storage = FlutterSecureStorage();
                          await storage.deleteAll();
                          // Navigate to login or home page
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (_) => MainPage()));
                          _showSnackBar("Logout Successfull !");
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
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

                  // Content area
                  Expanded(
                    child: _buildCurrentContent(),
                  ),                  
                ],
              ),
      ),
    );
  }
}
