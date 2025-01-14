import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sep_module_razzaq/screens/manage_user/login_form.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _phoneNumber = '';
  bool _isHouseOwner = true; // Default to House Owner

  Future<void> _registerUser() async {
    try {
      final userId = DateTime.now().millisecondsSinceEpoch; // Unique ID
      await FirebaseFirestore.instance.collection('users').doc(userId.toString()).set({
        'user_id': userId,
        'user_name': _email,
        'user_email': _email,
        'user_password': _password,
        'user_phone_number': _phoneNumber,
        'user_role': _isHouseOwner ? 'House Owner' : 'Cleaner',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User registered successfully!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginForm()),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity, // Full width
        height: MediaQuery.of(context).size.height, // Full height
        child: Container(
          color: Colors.yellow[400],
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal:60.0),
              child: Column(
                children: [
                  Image.asset(
                    'ccs_logo.png', // Replace with actual image path
                    width: 100,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'CCS',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text(
                        'Create an account',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your Email',
                            hintStyle: TextStyle(color: Colors.grey[400]), // Light gray hex color
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(horizontal: 20.0), // Indent hint text
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(80.0), // Rounded corners
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
                          onChanged: (value) => _email = value,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your Password',
                            hintStyle: TextStyle(color: Colors.grey[400]), // Light gray hex color
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(horizontal: 20.0), // Indent hint text
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(80.0), // Rounded corners
                              borderSide: BorderSide.none,
                            ),
                          ),
                          obscureText: true,
                          validator: (value) => value!.isEmpty ? 'Please enter your password' : null,
                          onChanged: (value) => _password = value,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            hintText: 'Enter your Phone Number',
                            hintStyle: TextStyle(color: Colors.grey[400]), // Light gray hex color
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(horizontal: 20.0), // Indent hint text
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(80.0), // Rounded corners
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
                          onChanged: (value) => _phoneNumber = value,
                        ),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Radio<bool>(
                                  value: true,
                                  groupValue: _isHouseOwner,
                                  onChanged: (value) => setState(() => _isHouseOwner = value!),
                                  fillColor: WidgetStateProperty.all(Colors.black), // White fill color
                                ),
                                const Text('House Owner'),
                              ],
                            ),
                            Row(
                              children: [
                                Radio<bool>(
                                  value: false,
                                  groupValue: _isHouseOwner,
                                  onChanged: (value) => setState(() => _isHouseOwner = value!),
                                  fillColor: WidgetStateProperty.all(Colors.black), // White fill color
                                ),
                                const Text('Cleaner'),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _registerUser();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black, // Set button color to black
                              foregroundColor: Colors.white, // Set text color to white
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(80.0), // Optional rounded corners
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 20.0), // Adjust height
                            ),
                            child: const Text('REGISTER', style: TextStyle(fontSize: 16.0),),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Have an account?"),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginForm(),
                                  ),
                                );
                              },
                              child: const Text('Log In'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
