import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewService {
  // Method to submit review with image
  Future<void> submitReviewWithImage({
    required String cleanerId,
    required String userId,
    required String reviewText,
    required double rating,
    required XFile imageFile,
  }) async {
    try {
      // Upload the image to Firebase Storage
      String imageUrl = await _uploadImage(imageFile);

      // Submit the review to Firestore
      await FirebaseFirestore.instance
          .collection('cleaners')
          .doc(cleanerId)
          .collection('detail_reviews')
          .add({
        'userId': userId,
        'reviewText': reviewText,
        'rating': rating,
        'timestamp': FieldValue.serverTimestamp(),
        'imageUrl': imageUrl,
      });
    } catch (e) {
      throw Exception("Error submitting review with image: $e");
    }
  }

  // Method to submit review without an image
  Future<void> submitReview({
    required String cleanerId,
    required String userId,
    required String reviewText,
    required double rating,
    String? imageUrl,
  }) async {
    try {
      // If user is not logged in, allow review submission without userId
      if (userId.isEmpty) {
        // Optionally, use an anonymous name or a placeholder
        userId = "Anonymous";
      }

      // Submit the review to Firestore
      await FirebaseFirestore.instance
          .collection('cleaners')
          .doc(cleanerId)
          .collection('detail_reviews')
          .add({
        'userId': userId,
        'reviewText': reviewText,
        'rating': rating,
        'timestamp': FieldValue.serverTimestamp(),
        'imageUrl': imageUrl ?? '',
      });
    } catch (e) {
      throw Exception("Error submitting review: $e");
    }
  }

  // Method to upload image to Firebase Storage
  Future<String> _uploadImage(XFile imageFile) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('review_images')
          .child(fileName);
      await storageRef.putFile(File(imageFile.path));
      String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception("Error uploading image: $e");
    }
  }

  // Method to get the name of a user from Firestore based on their userId
  Future<String> getUserName(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return userDoc['name']; // Assuming 'name' field is present
      } else {
        return "Anonymous"; // Default name if not found
      }
    } catch (e) {
      return "Anonymous"; // In case of any errors
    }
  }
}
