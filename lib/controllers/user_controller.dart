import 'package:cloud_firestore/cloud_firestore.dart';

class UserController {
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  // Add a new user
  Future<void> addUser(
      int userId, String userName, String userEmail, String userPassword, String userPhoneNumber, String userRole) {
    return userCollection.doc(userId.toString()).set({
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'user_password': userPassword,
      'user_phone_number': userPhoneNumber,
      'user_role': userRole,
    });
  }

  // Validate user login
  Future<Map<String, dynamic>?> validateUser(String email, String password) async {
    final querySnapshot = await userCollection
        .where('user_email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
      if (userData['user_password'] == password) {
        return userData;
      }
    }
    return null;
  }

  // Fetch all users
  Stream<QuerySnapshot> getUsers() {
    return userCollection.orderBy('user_id').snapshots();
  }

  // Update a user's data
  Future<void> updateUser(int userId, String userName, String userEmail,
      String userPassword, String userPhoneNumber, String userRole) {
    return userCollection.doc(userId.toString()).update({
      'user_name': userName,
      'user_email': userEmail,
      'user_password': userPassword,
      'user_phone_number': userPhoneNumber,      
      'user_role': userRole,
    });
  }

  // Delete a user
  Future<void> deleteUser(int userId) {
    return userCollection.doc(userId.toString()).delete();
  }
}
