import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sep_module_razzaq/screens/add_review_screen.dart';

class CleanerDetailsScreen extends StatefulWidget {
  final String cleanerId;
  final String userId;

  CleanerDetailsScreen({required this.cleanerId, required this.userId});

  @override
  _CleanerDetailsScreenState createState() => _CleanerDetailsScreenState();
}

class _CleanerDetailsScreenState extends State<CleanerDetailsScreen> {
  late Stream<DocumentSnapshot> cleanerStream;
  late Stream<QuerySnapshot> reviewsStream;

  @override
  void initState() {
    super.initState();
    cleanerStream = FirebaseFirestore.instance
        .collection('cleaners')
        .doc(widget.cleanerId)
        .snapshots();

    reviewsStream = FirebaseFirestore.instance
        .collection('cleaners')
        .doc(widget.cleanerId)
        .collection('detail_reviews')
        .snapshots();
  }

  // Function to delete a review
  Future<void> deleteReview(String reviewId) async {
    try {
      await FirebaseFirestore.instance
          .collection('cleaners')
          .doc(widget.cleanerId)
          .collection('detail_reviews')
          .doc(reviewId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Review deleted successfully!'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error deleting review: $e'),
      ));
    }
  }

  // Function to fetch the username based on userId
  Future<String> fetchUsername(String userId) async {
    try {
      // If the userId matches the current user's ID, return "You"
      if (userId == widget.userId) {
        return 'You';
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return userDoc['user_name'] ?? 'Unknown';
      } else {
        return 'Unknown';
      }
    } catch (e) {
      return 'Unknown'; // Default value if there's an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cleaner Details"),
        backgroundColor: Colors.yellow[700],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: cleanerStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var cleanerData = snapshot.data!;
          String cleanerName = cleanerData['name'] ?? 'No name';
          String cleanerEmail = cleanerData['email'] ?? 'No email';
          double cleanerRating = (cleanerData['rating'] is double)
              ? cleanerData['rating']
              : (cleanerData['rating'] as int).toDouble();

          return StreamBuilder<QuerySnapshot>(
            stream: reviewsStream,
            builder: (context, reviewSnapshot) {
              if (!reviewSnapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var reviews = reviewSnapshot.data!.docs;
              return ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  // Display cleaner details
                  Row(
                    children: [
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cleanerName,
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Email: $cleanerEmail',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: List.generate(
                              5,
                                  (index) => Icon(
                                index < cleanerRating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.yellow[700],
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Rating: ${cleanerRating.toStringAsFixed(1)} / 5',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Divider(),
                  SizedBox(height: 10),

                  // Display reviews section
                  Text(
                    'Reviews:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  if (reviews.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        'No reviews yet!',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  for (var review in reviews) ...[
                    FutureBuilder<String>(
                      future: fetchUsername(review['userId']), // Fetch the username using userId from the review document
                      builder: (context, usernameSnapshot) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Display the username or a loading/error message
                              Text(
                                usernameSnapshot.connectionState == ConnectionState.waiting
                                    ? 'Loading...'
                                    : usernameSnapshot.hasError
                                    ? 'Error fetching username'
                                    : usernameSnapshot.data!,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              // Display the review rating
                              Row(
                                children: List.generate(
                                  5,
                                      (index) => Icon(
                                    index < review['rating'] ? Icons.star : Icons.star_border,
                                    color: Colors.yellow[700],
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              // Display the review text
                              Text(
                                review['reviewText'] ?? '',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 5),
                              // Display the review timestamp
                              Text(
                                'Posted on: ${review['timestamp'].toDate().toString()}',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),

                              // Show Edit/Delete buttons if the review belongs to the current user
                              if (review['userId'] == widget.userId)
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AddReviewScreen(
                                              cleanerId: widget.cleanerId,
                                              userId: widget.userId,
                                              reviewId: review.id,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        deleteReview(review.id);
                                      },
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddReviewScreen(
                cleanerId: widget.cleanerId,
                userId: widget.userId,
              ),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.yellow[700],
      ),
    );
  }
}
