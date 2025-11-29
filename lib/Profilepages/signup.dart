import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io'; // Add this import for SocketException
import 'dart:convert';
import 'profile.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final storage = FlutterSecureStorage();
  
  bool _isLoading = false;

  // Helper function to show messages
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Test server connection
  Future<void> testServerConnection() async {
    try {
      print('🧪 Testing server connection...'); 
      final response = await http.get(
        Uri.parse('http://localhost:3001/api/auth/login'),
      ).timeout(Duration(seconds: 5));
      
      print('✅ Server is reachable! Status: ${response.statusCode}');
    } catch (e) {
      print('❌ Cannot reach server: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      testServerConnection();
    });
  }

  Future<void> _signup() async {
    String name = _nameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    print('=== SIGNUP ATTEMPT ===');
    print('Name: $name');
    print('Email: $email');
    print('Password: ${'*' * password.length}');

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    setState(() { 
      _isLoading = true; 
    });

    try {
      final String apiUrl = 'http://localhost:3001/api/auth/signup';
      print('🔗 URL: $apiUrl');

      final requestBody = {
        'name': name,
        'email': email,
        'password': password,
      };
      
      print('📦 Request: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200 ) {
        _showSnackBar('Signup successful!');
        final responseData = json.decode(response.body);
        final token = responseData['token'];

        if (token != null) {
          await storage.write(key: 'auth_token', value: token);
          print('🔐 Token saved successfully');
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => Profile())
            );
          });
        } else {
          _showSnackBar('Signup failed: No token received');
        }
      } else {
        print('❌ Server error: ${response.statusCode}');
        Map<String, dynamic> errorData = json.decode(response.body);
        _showSnackBar('Signup failed: ${errorData['message'] ?? 'Unknown error'}');
      }

    } on http.ClientException catch (e) {
      print('💥 HTTP Client Exception: $e');
      _showSnackBar('Network error: Cannot connect to server');
    } on SocketException catch (e) {
      print('💥 Socket Exception: $e');
      _showSnackBar('Connection failed: Server unreachable');
    } catch (e) {
      print('💥 Unknown Exception: $e');
      print('💥 Exception type: ${e.runtimeType}');
      _showSnackBar('Unexpected error: $e');
    } finally {
      setState(() { 
        _isLoading = false; 
      });
    }
  }

  Future<void> _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    print('=== LOGIN ATTEMPT ===');
    print('Email: $email');
    print('Password: ${'*' * password.length}');

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String apiUrl = 'http://localhost:3001/api/auth/login';
      print('🔗 URL: $apiUrl');
      
      Map<String, dynamic> requestBody = {
        'email': email,
        'password': password,
      };

      print('📦 Request: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      ).timeout(Duration(seconds: 10));

      print('📨 Response status: ${response.statusCode}');
      print('📨 Response body: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        final token = responseData['token'];
        
        if (token != null && token.isNotEmpty) {
          await storage.write(key: 'auth_token', value: token);
          _showSnackBar('Login successful!');
          print('🔐 Token saved: $token');
          
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
        _showSnackBar('Login failed: ${errorData['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('💥 Login Exception: $e');
      _showSnackBar('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signup/Login'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name',
                hintText: 'Enter your full name',
              ),
            ),
            SizedBox(height: 16),
            
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
                hintText: 'Enter your email',
              ),
            ),
            SizedBox(height: 16),
            
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
                hintText: 'Enter your password',
              ),
            ),
            SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(16),
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
            SizedBox(height: 12),
            
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isLoading ? null : _signup,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.all(16),
                ),
                child: Text('Sign Up'),
              ),
            ),
            SizedBox(height: 20),
          ],
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