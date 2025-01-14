import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sep_module_razzaq/screens/manage_report/report_edit_form.dart';
import 'package:sep_module_razzaq/screens/manage_report/report_form.dart';
import 'package:sep_module_razzaq/screens/manage_report/report_view_page.dart';
import 'package:sep_module_razzaq/controllers/report_controller.dart';

class ReportPage extends StatelessWidget {
  final ReportController _reportController = ReportController();

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
              'LIST OF REPORT',
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
      body: Column(
        children: [
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to the ReportForm page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReportForm()),
                );
              },
              child: const Text('Add New Report'),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              child: StreamBuilder<QuerySnapshot>(
                stream: _reportController.getReports(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
              
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
              
                  final reports = snapshot.data!.docs;
              
                  return ListView.builder(
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      final reportData = report.data() as Map<String, dynamic>;
              
                      return GestureDetector(
                        onTap: () {
                          // Navigate to ReportViewPage with report data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReportViewPage(
                                reportId: reportData['report_id'].toString(),
                                reportData: reportData,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.yellow[400],  // Set the card color to yellow[400]
                          margin: const EdgeInsets.all(8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Column: Image, Date, and Time
                                Column(
                                  children: [
                                    Image.network(
                                      reportData['house_img_link'] ?? 'assets/house.jpg',
                                      width: 80.0,
                                      height: 80.0,
                                      fit: BoxFit.cover,
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      reportData['report_date'],
                                      style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      reportData['report_time'],
                                      style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16.0),
                                // Right Column: Address, Media Container, Buttons
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 15,
                                            backgroundColor: Colors.black,
                                            child: const Icon(Icons.location_on, size: 20, color: Colors.white),
                                          ),
                                          const SizedBox(width: 4.0),
                                          Expanded(
                                            child: Text(
                                              reportData['house_address'],
                                              style: const TextStyle(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8.0),
              
                                      Card(
                                        color: Colors.white,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SizedBox(
                                            height: 70.0,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: reportData['report_medias_path'] != null
                                                  ? reportData['report_medias_path'].length
                                                  : 0, // Get the length of the media array, or 0 if it's null
                                              itemBuilder: (context, mediaIndex) {
                                                // Ensure that each media item exists in the array, fallback to default if not
                                                String mediaImagePath = reportData['report_medias_path'][mediaIndex] ?? 'assets/image.png';
                                                
                                                return Padding(
                                                  padding: const EdgeInsets.only(right: 8.0),
                                                  child: Image.network(
                                                    mediaImagePath, // Use image URL from Firestore if available
                                                    width: 100.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                        
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text('Confirm Deletion'),
                                                    content: const Text('Are you sure you want to delete this report?'),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context).pop(); // Close the dialog without deleting
                                                        },
                                                        child: const Text('Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          _reportController.deleteReport(reportData['report_id']).then((_) {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              const SnackBar(
                                                                content: Text('Report deleted successfully'),
                                                              ),
                                                            );
                                                          });
                                                          Navigator.of(context).pop(); // Close the dialog after deleting
                                                        },
                                                        style: TextButton.styleFrom(
                                                          foregroundColor: Colors.red,
                                                        ),
                                                        child: const Text(
                                                          'Delete', 
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                            child: const Text(
                                              'Delete', 
                                              style: TextStyle(
                                                decoration: TextDecoration.underline,
                                                decorationColor: Colors.red, 
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10,),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ReportEditForm(
                                                    reportId: reportData['report_id'],
                                                    initialData: reportData,
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
                                              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30), // Adjust height
                                            ),
                                            child: const Text('Edit'),
                                          ),
                                          const SizedBox(width: 8.0),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
