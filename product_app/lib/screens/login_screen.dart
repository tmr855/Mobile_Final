import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'product_list_screen.dart';

class LoginScreen extends StatefulWidget {
  final String apiUrl;
  final email = TextEditingController(), password = TextEditingController();
  LoginScreen({Key? key, required this.apiUrl}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? errorMessage;

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('${widget.apiUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': widget.email.text,
          'password': widget.password.text,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final token = data['token'];
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ProductListScreen(token: token)),
        );
      } else {
        setState(() {
          errorMessage = data['message'] ?? 'Login failed';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error connecting to server';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (errorMessage != null)
                Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                controller: widget.email,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter email';
                  if (!val.contains('@')) return 'Enter valid email';
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                controller: widget.password,
                validator: (val) {
                  if (val == null || val.isEmpty)
                    return 'Please enter password';
                  if (val.length < 8)
                    return 'Password must be at least 8 characters';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: login,
                    child: const Text('Login'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
