import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileEditForm extends StatefulWidget {
  final int userId;
  final String currentName;
  final String currentPhone;
  final String currentEmail;  // Add currentEmail for email input

  const ProfileEditForm({
    Key? key,
    required this.userId,
    required this.currentName,
    required this.currentPhone,
    required this.currentEmail,  // Receive email from ProfileViewPage
  }) : super(key: key);

  @override
  _ProfileEditFormState createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends State<ProfileEditForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late String userRole;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _phoneController = TextEditingController(text: widget.currentPhone);
    _emailController = TextEditingController(text: widget.currentEmail); // Initialize email controller
    
        _getUserRole(); // Retrieve user role when the form initializes

  }

  // Function to get the user role from shared preferences
  Future<void> _getUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('userRole')!;  // Default to 'Guest' if no role is found
    });
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId.toString())
            .update({
          'user_name': _nameController.text,
          'user_phone_number': _phoneController.text,
          'user_email': _emailController.text,  // Update email
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );

        // Optionally, navigate back after successful update
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0), // Set the height of the AppBar
        child: AppBar(
          backgroundColor: Colors.white, // Set the background color of the AppBar
          centerTitle: true,
          toolbarHeight: 100,
          elevation: 4, // Add shadow/line below AppBar
          title: const Center(
            child: Text(
              'EDIT PROFILE',
                style: TextStyle(
                letterSpacing: 1.5,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black, 
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 30.0),
        child: Column(
          children: [
            // Yellow Rounded Card
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.yellow[400],
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                children: [
                  Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Placeholder for rounded profile picture
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.grey[300],
                              child: const Icon(Icons.person, size: 50, color: Colors.white),
                            ),
                            const SizedBox(width: 20),
                            // Role
                            Expanded(
                              child: Text(
                                userRole,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                  // Name, Email, Phone (Column)
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name Field
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Name'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Phone Field
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(labelText: 'Phone Number'),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 40),
                        // Done Button (aligned to the right)
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: _updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black, // Set button color to black
                              foregroundColor: Colors.white, // Set text color to white
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(80.0), // Optional rounded corners
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40), // Adjust height
                            ),
                            child: const Text('Done'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
