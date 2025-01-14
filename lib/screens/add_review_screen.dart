import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'review_service.dart'; // Ensure this is the correct path for your ReviewService

class AddReviewScreen extends StatefulWidget {
  final String cleanerId;
  final String userId;
  final String? reviewId;

  AddReviewScreen({
    required this.cleanerId,
    required this.userId,
    this.reviewId,
  });

  @override
  _AddReviewScreenState createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  late TextEditingController _reviewController;
  int rating = 0;
  String reviewText = '';
  XFile? imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _reviewController = TextEditingController();

    if (widget.reviewId != null) {
      _loadReview();
    }
  }

  // Load existing review for editing
  Future<void> _loadReview() async {
    DocumentSnapshot reviewDoc = await FirebaseFirestore.instance
        .collection('cleaners')
        .doc(widget.cleanerId)
        .collection('detail_reviews')
        .doc(widget.reviewId)
        .get();

    if (reviewDoc.exists) {
      setState(() {
        rating = reviewDoc['rating'];
        _reviewController.text = reviewDoc['reviewText'];
        reviewText = reviewDoc['reviewText'];
      });
    }
  }

  // Function to submit the review without the image
  Future<void> submitReview() async {
    if (reviewText.isEmpty || rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill in your review and rating'),
      ));
      return;
    }

    try {
      // Directly submit text and rating only
      await FirebaseFirestore.instance.collection('cleaners')
          .doc(widget.cleanerId)
          .collection('detail_reviews')
          .add({
        'reviewText': reviewText,
        'rating': rating,
        'userId': widget.userId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Review submitted successfully!'),
      ));

      // After submission, navigate back to the cleaner's detail page
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error submitting review: $e'),
      ));
    }
  }

  // Function to pick an image (though it won't be saved)
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageFile = pickedFile;
    });
  }

  // Function to handle rating star click
  void _setRating(int newRating) {
    setState(() {
      rating = newRating;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.reviewId == null ? Text("Add Review") : Text("Edit Review"),
        backgroundColor: Colors.yellow[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Rating stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.yellow[700],
                    ),
                    onPressed: () => _setRating(index + 1),
                  );
                }),
              ),
              SizedBox(height: 20),

              // Review text field
              TextField(
                controller: _reviewController,
                maxLines: 5,
                onChanged: (text) {
                  setState(() {
                    reviewText = text;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Write your review here...",
                  border: OutlineInputBorder(),
                  labelText: "Review",
                ),
              ),
              SizedBox(height: 20),

              // Pick Image button (image won't be saved)
              ElevatedButton(
                onPressed: _pickImage,
                child: Text(imageFile == null ? "Add Image" : "Change Image"),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.yellow[700]),
                ),
              ),
              SizedBox(height: 20),

              // Display selected image (if any) but won't be saved
              if (imageFile != null)
                Image.file(
                  File(imageFile!.path),
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              SizedBox(height: 20),

              // Submit button
              ElevatedButton(
                onPressed: submitReview,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.yellow[700]),
                ),
                child: Text(widget.reviewId == null ? "Submit Review" : "Update Review"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
