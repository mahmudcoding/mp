import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../main.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic> userData = {};
  bool loading = true; // Use 'loading' instead of 'isLoading'
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
      loading = true;
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
          loading = false;
        });
      } else {
        // FIX: Handle specific status codes if needed, or assume any non-200 is a failure
        String errorMessage =
            "Failed to load profile. Status: ${response.statusCode}";
        if (response.statusCode == 401) {
          errorMessage = "Authentication failed. Please log in again.";
        } else if (response.statusCode == 404) {
          errorMessage = "User data not found.";
        }

        print(errorMessage); // Log the specific error

        // Set loading to false so the UI doesn't hang on a spinner
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      {
        // Handle network or other exceptions
        print("Error loading products: $e");
        setState(() {
          // Here, 'loading' is set to false, which will allow the UI to display the profile structure
          // If userData remains empty, it will show "No items yet" in the Own Items tab.
          loading = false;
        });
      }
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
    // Safely check for 'products' key and if it's a non-empty list
    List? products = userData['products'] as List?;
    bool hasProducts = products != null && products.isNotEmpty;

    switch (_selectedTab) {
      case 0:
        return Center(child: Text('Bought Items will appear here'));
      case 1:
        return Center(child: Text('Swapped Items will appear here'));
      case 2: // Own Items
        return hasProducts
            ? ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  var product = products[index];
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
    // FIX 1: Use the defined variable 'loading' instead of 'isLoading'
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
            Navigator.push(context, MaterialPageRoute(builder: (_) => MainPage()));
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
                  // 1. Profile Info Row (with CircleAvatar, Name/Email, and Logout Button)
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.greenAccent,
                          // Safely access user data
                          child: Text(userData['user']?['name'] != null
                              ? userData['user']['name'][0]
                              : 'U'),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Safely access user data
                          Text(userData['user']?['name'] ?? 'Loading Name...',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              )),
                          Text(
                            // Safely access user data
                            userData['user']?['email'] ?? 'Loading Email...',
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
                          _showSnackBar("Logout Successful!");
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

                  // 2. Navigation Tabs Row
                  Row(
                    children: [
                      _buildNavItem('Bought', 0),
                      SizedBox(width: 8),
                      _buildNavItem('Swapped', 1),
                      SizedBox(width: 8),
                      _buildNavItem('Own Items', 2),
                    ],
                  ),
                  
                  SizedBox(height: 16),
                  
                  // 3. Content area
                  Expanded(
                    child: _buildCurrentContent(),
                  ),
                ],
              ),
      ),
    );
  }
}