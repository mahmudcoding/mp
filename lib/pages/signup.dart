import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'profile.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  // Controllers to get text from TextFields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final storage = FlutterSecureStorage();
  
  // Loading state
  bool _isLoading = false;

  // Login function
  Future<void> _login() async {
  String name = _nameController.text;
  String email = _emailController.text;
  String password = _passwordController.text;

  if (email.isEmpty || password.isEmpty) {
    _showSnackBar('Please fill in all fields');
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    final String apiUrl = 'http://localhost:3000/api/auth/login';
    
    Map<String, dynamic> requestBody = {
      'name': name,
      'email': email,
      'password': password,
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      
      // Extract token from response
      final token = responseData['token'];
      
      if (token != null && token.isNotEmpty) {
        // Save token to secure storage
        await storage.write(key: 'auth_token', value: token);
        _showSnackBar('Login successful!');
        print('Token saved: $token');
        
        // Navigate after saving token
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => Profile())
          );
        });
      } else {
        _showSnackBar('Login failed: No token received');
      }
    } else {
      Map<String, dynamic> errorData = json.decode(response.body);
      _showSnackBar('Login failed: ${errorData['message']}');
    }
  } catch (e) {
    _showSnackBar('Error: $e');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  // Signup function (similar to login)
  Future<void> _signup() async {
    String name = _nameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String apiUrl = 'http://localhost:3000/api/auth/signup';

      Map<String, dynamic> requestBody = {
        'name': name, // Include the name in the signup request
        'email': email,
        'password': password,
      };

      final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestBody),
        );

        if (response.statusCode == 200) {
          _showSnackBar('Signup successful!');

          // Decode the response body (which is a JSON string)
          final responseData = json.decode(response.body);

          final token = responseData['token'];

          final tokenSaved = await storage.write(key: 'auth_token', value: token);

          print("Navigating to ProfilePage...");
          WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => Profile())
          );
        });
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
      appBar: AppBar(
        title: Text('Signup/Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Name Field
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name',
                ),
              ),
              SizedBox(height: 16),
              
              // Username Field
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 16),
              
              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
              SizedBox(height: 16),
              
              // Login Button
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading 
                    ? SizedBox(
                        height: 20,
                        width: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text('Login'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(15),
                ),
              ),
              SizedBox(height: 16),
              
              // Signup Button
              OutlinedButton(
                onPressed: _isLoading ? null : _signup,
                child: Text('Sign Up'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.all(15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
