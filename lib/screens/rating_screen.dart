import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sep_module_razzaq/cleaner_detail_screen.dart';

class RatingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rating/Complaint"),
        backgroundColor: Colors.yellow[700],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cleaners').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error fetching cleaners"));
          }

          final cleaners = snapshot.data?.docs ?? [];

          if (cleaners.isEmpty) {
            return const Center(child: Text("No cleaners available"));
          }

          return ListView.builder(
            itemCount: cleaners.length,
            itemBuilder: (context, index) {
              final cleaner = cleaners[index];
              final cleanerId = cleaner.id; // Document ID (unique)

              // Query the 'detail_reviews' subcollection
              final reviewsStream = FirebaseFirestore.instance
                  .collection('cleaners')
                  .doc(cleanerId)
                  .collection('detail_reviews')
                  .snapshots();

              return StreamBuilder<QuerySnapshot>(
                stream: reviewsStream,
                builder: (context, reviewSnapshot) {
                  if (reviewSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (reviewSnapshot.hasError) {
                    return const Center(child: Text("Error fetching reviews"));
                  }

                  final reviews = reviewSnapshot.data?.docs ?? [];
                  final totalReviews = reviews.length;

                  // Calculate the sum of ratings
                  int sumOfRatings = 0;
                  for (var review in reviews) {
                    final rating = review['rating'];
                    if (rating is int) {
                      sumOfRatings += rating;
                    } else if (rating is double) {
                      sumOfRatings += rating.toInt();
                    }
                  }

                  final averageRating = reviews.isNotEmpty ? sumOfRatings / reviews.length : 0;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(cleaner['imageUrl'] ?? 'https://via.placeholder.com/150'),
                        radius: 30,
                      ),
                      title: Text(
                        cleaner['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${averageRating.toStringAsFixed(1)}/5 ($totalReviews reviews)",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          // Display stars
                          Row(
                            children: List.generate(
                              averageRating.toInt(), // Ensure this is an integer
                                  (index) => const Icon(
                                Icons.star,
                                color: Color(0xFFE8D200),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Display role (cleaner)
                          Text(
                            cleaner['role'] ?? 'Role not available',  // Display role here
                            style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () {
                        // Navigate to CleanerDetailScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CleanerDetailsScreen(
                              cleanerId: cleanerId, userId: 'You',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
