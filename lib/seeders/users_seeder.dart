import 'package:cloud_firestore/cloud_firestore.dart';

class UserController {
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  // Add a new user
  Future<void> addUser(int userId, String userName, String userEmail, String userPassword, String userPhoneNumber, String userRole) {
    return userCollection.doc(userId.toString()).set({
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'user_password': userPassword,
      'user_phone_number': userPhoneNumber,
      'user_role': userRole,
    });
  }
}

Future<void> seedUsers() async {
  final UserController userController = UserController();

  final List<Map<String, dynamic>> dummyUsers = [
    {
      'user_id': 1,
      'user_name': 'Ahmad Bin Ali',
      'user_email': 'ahmad@example.com',
      'user_password': 'password',
      'user_phone_number': '0112783764',
      'user_role': 'Cleaner',
    },
    {
      'user_id': 2,
      'user_name': 'Siti Aishah Binti Aziz',
      'user_email': 'siti@example.com',
      'user_password': 'password',
      'user_phone_number': '0112783764',
      'user_role': 'House Owner',
    },
    {
      'user_id': 3,
      'user_name': 'Zainal Abidin Bin Mohamed',
      'user_email': 'zainal@example.com',
      'user_password': 'password',
      'user_phone_number': '0112783764',
      'user_role': 'Cleaner',
    },
    {
      'user_id': 4,
      'user_name': 'Nurul Huda Binti Mohd',
      'user_email': 'nurul@example.com',
      'user_password': 'password',
      'user_phone_number': '0112783764',
      'user_role': 'House Owner',
    },
    {
      'user_id': 5,
      'user_name': 'Kamaludin Bin Abdullah',
      'user_email': 'kamaludin@example.com',
      'user_password': 'password',
      'user_phone_number': '0112783764',
      'user_role': 'Cleaner',
    },
  ];

  // Adding users to Firestore
  for (final user in dummyUsers) {
    await userController.addUser(
      user['user_id'],
      user['user_name'],
      user['user_email'],
      user['user_password'],
      user['user_phone_number'],
      user['user_role'],
    );
  }

  print('Dummy users inserted successfully!');
}
