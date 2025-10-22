import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  // Controllers to get text from TextFields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Loading state
  bool _isLoading = false;

  // Login function
  Future<void> _login() async {
    // Get the values from text fields
    String username = _usernameController.text;
    String password = _passwordController.text;

    // Basic validation
    if (username.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Your API endpoint - replace with your actual URL
      final String apiUrl = 'http://10.0.2.2:3000/api/login';
      
      // Create request body
      Map<String, dynamic> requestBody = {
        'username': username,
        'password': password,
      };

      // Make POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      // Handle response
      if (response.statusCode == 200) {
        // Login successful
        Map<String, dynamic> responseData = json.decode(response.body);
        _showSnackBar('Login successful!');
        print('User data: $responseData');
        
        // Navigate to next screen or do something with the response
        // Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
        
      } else {
        // Login failed
        Map<String, dynamic> errorData = json.decode(response.body);
        _showSnackBar('Login failed: ${errorData['message']}');
      }
    } catch (e) {
      // Network or other errors
      _showSnackBar('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Signup function (similar to login)
  Future<void> _signup() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String apiUrl = 'http://10.0.2.2:3000/api/signup';
      
      Map<String, dynamic> requestBody = {
        'username': username,
        'password': password,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        _showSnackBar('Signup successful!');
      } else {
        Map<String, dynamic> errorData = json.decode(response.body);
        _showSnackBar('Signup failed: ${errorData['message']}');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Username Field
            Container(
              width: 300,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Username'
                ),
              ),
            ),
            
            // Password Field
            Container(
              width: 300,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password'
                ),
              ),
            ),
            
            // Login Button
            Container(
              width: 300,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login, // Disable when loading
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: _isLoading 
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text('Login'),
              ),
            ),
            
            // Signup Button
            Container(
              width: 300,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: OutlinedButton(
                onPressed: _isLoading ? null : _signup,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text('Sign Up'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up controllers
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}