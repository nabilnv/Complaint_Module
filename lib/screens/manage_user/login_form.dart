import 'package:flutter/material.dart';
import 'package:sep_module_razzaq/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sep_module_razzaq/screens/manage_user/register_form.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _rememberMe = false;

  Future<void> _saveUserSession(int userId, String userRole) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
    await prefs.setString('userRole', userRole);
  }

  Future<bool> _validateUser(String email, String password) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('user_email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final userData = querySnapshot.docs.first.data();
      if (userData['user_password'] == password) {
        await _saveUserSession(userData['user_id'], userData['user_role']);
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity, // Full width
        height: MediaQuery.of(context).size.height, // Full height
        child: Container(
          color: Colors.yellow[400], // Set yellow as the background color
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal:60.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Image.asset(
                      'ccs_logo.png',
                      width: 100,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'CCS',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text(
                        'Sign In',
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
                            hintText: 'Enter your email',
                            hintStyle: TextStyle(color: Colors.grey[400]), // Light gray hex color
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20.0), // Indent hint text
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(80.0), // Rounded corners
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _email = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintStyle: TextStyle(color: Colors.grey[400]), // Light gray hex color
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20.0), // Indent hint text
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(80.0), // Rounded corners
                              borderSide: BorderSide.none,
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _password = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  fillColor: WidgetStateProperty.all(Colors.white), // White fill color
                                  checkColor: Colors.black,                            
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value!;
                                    });
                                  },
                                ),
                                const Text('Remember Me'),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                print('Forgot Password');
                              },
                              child: const Text('Forget Password?'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                bool isValidUser =
                                    await _validateUser(_email, _password);
                                  
                                if (isValidUser) {
                                  final prefs = await SharedPreferences.getInstance();
                                  int userId = prefs.getInt('userId') ?? 0;
                                  
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DrawerMenu(userId: userId)));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Invalid email or password'),
                                    ),
                                  );
                                }
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
                            child: const Text('SIGN IN',
                              style: TextStyle(fontSize: 16.0),),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/ccs.png',
                    width: 200,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterForm(),
                            ),
                          );
                        },
                        child: const Text('Create Account'),
                      ),
                    ],
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
