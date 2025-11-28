import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Profilepages/profile.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final storage = FlutterSecureStorage();
  bool _isLoading = false;

  // ==========================
  // LOGIN
  // ==========================
  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      const apiUrl = 'http://localhost:3001/api/auth/login';

      Map<String, dynamic> requestBody = {
        'email': email,
        'password': password,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final token = responseData['token'];

        if (token != null) {
          await storage.write(key: 'auth_token', value: token);
          _showSnackBar('Login successful!');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => Profile()),
          );
        } else {
          _showSnackBar('Login failed: No token received');
        }
      } else {
        final errorData = jsonDecode(response.body);
        _showSnackBar('Login failed: ${errorData['message']}');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ==========================
  // SIGNUP
  // ==========================
  Future<void> _signup() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      const apiUrl = 'http://localhost:3001/api/auth/signup';

      Map<String, dynamic> requestBody = {
        'name': name,
        'email': email,
        'password': password,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final token = responseData['token'];

        await storage.write(key: 'auth_token', value: token);

        _showSnackBar('Signup successful!');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Profile()),
        );
      } else {
        final errorData = jsonDecode(response.body);
        _showSnackBar('Signup failed: ${errorData['message']}');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Snackbar helper
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Signup / Login')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name (only for Signup)',
              ),
            ),
            SizedBox(height: 16),

            // Email
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 16),

            // Password
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
            ),
            SizedBox(height: 20),

            // Login Button
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(padding: EdgeInsets.all(15)),
              child: _isLoading
                  ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Text('Login'),
            ),

            SizedBox(height: 16),

            // Signup Button
            OutlinedButton(
              onPressed: _isLoading ? null : _signup,
              style: OutlinedButton.styleFrom(padding: EdgeInsets.all(15)),
              child: Text('Sign Up'),
            ),
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