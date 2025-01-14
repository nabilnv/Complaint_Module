import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sep_module_razzaq/screens/manage_user/login_form.dart';
import 'package:sep_module_razzaq/screens/manage_user/profile_edit_form.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileViewPage extends StatelessWidget {
  final int userId;

  const ProfileViewPage({super.key, required this.userId});

  // Get user data from Firestore
  Stream<DocumentSnapshot> getUserData(int userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId.toString())
        .snapshots();
  }

  Future<void> _deleteUserAccount(int userId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId.toString()).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User account deleted successfully')),
      );
      // After deleting, clear session data and navigate to login page
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();  // Clear shared preferences data
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginForm()),
        (route) => false, // Removes all previous routes
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting account: $e')),
      );
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
              'PROFILE',
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: getUserData(userId), // Listen for real-time data updates
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No user data available'));
          } else {
            final userData = snapshot.data!.data() as Map<String, dynamic>;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 30.0),
              child: Column(
                children: [
                  // Yellow Rounded Card/Box
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.yellow[400],
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Column(
                      children: [
                        // Row: Profile Picture & Role
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
                                userData['user_role'],
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Name, Email, Phone (Column)
                        // Inside the Column for user details
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: 100, // Fixed width for alignment
                                  child: Text(
                                    'Name',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    ': ' + userData['user_name'],
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Email Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: 100, // Same fixed width
                                  child: Text(
                                    'Email',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    ': ' + userData['user_email'],
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Phone Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: 100, // Same fixed width
                                  child: Text(
                                    'Phone',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    ': ' + userData['user_phone_number'],
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Edit Button (aligned to the right)
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to Edit Profile page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfileEditForm(
                                    userId: userId,
                                    currentName: userData['user_name'],
                                    currentEmail: userData['user_email'],
                                    currentPhone: userData['user_phone_number'],
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black, // Set button color to black
                              foregroundColor: Colors.white, // Set text color to white
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(80.0), // Optional rounded corners
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40), // Adjust height
                            ),
                            child: const Text('Edit Profile'),
                          ),
                        ),
                          const SizedBox(height: 60),
                        GestureDetector(
                            onTap: () {
                            // Show confirmation dialog before deletion
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirm Deletion'),
                                  content: const Text(
                                      'Are you sure you want to delete your account? This action cannot be undone.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Close the dialog
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Close the dialog
                                        _deleteUserAccount(userId, context);
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text(
                            'Delete Account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white, // Set underline color to white
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
