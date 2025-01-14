import 'package:cloud_firestore/cloud_firestore.dart';

String formatDate(DateTime date) {
  String day = date.day.toString().padLeft(2, '0');   // Ensure day is two digits
  String month = date.month.toString().padLeft(2, '0'); // Ensure month is two digits
  String year = date.year.toString().substring(2);     // Get the last two digits of the year

  return '$day/$month/$year'; // Return formatted date
}

Future<void> seedReports() async {
  final CollectionReference reportsCollection =
      FirebaseFirestore.instance.collection('reports');

  final List<Map<String, dynamic>> dummyReports = [
    {
      'report_id': 1,
      'report_date': formatDate(DateTime(2025, 01, 01)), // '01/01/25'
      'report_time': '10:00 AM',
      'report_summary': 'Report summary 1',
      'report_constraint': 'Constraint 1',
      'report_medias_path': [
        'assets/image1.jpg',
      ],
      'schedule_id': 101,
      'house_address': 'No. 12, Jalan Merdeka, 54000 Kuala Lumpur, Malaysia',
      'house_img_link': 'assets/house.jpg',
    },
    {
      'report_id': 2,
      'report_date': formatDate(DateTime(2025, 01, 02)), // '02/01/25'
      'report_time': '11:00 AM',
      'report_summary': 'Report summary 2',
      'report_constraint': 'Constraint 2',
      'report_medias_path': [
        'assets/image1.jpg',
        'assets/image2.jpg',
        'assets/image3.jpg',
      ],
      'schedule_id': 102,
      'house_address': 'No. 34, Lorong Damai, 93350 Kuching, Sarawak, Malaysia',
      'house_img_link': 'assets/house.jpg',
    },
    {
      'report_id': 3,
      'report_date': formatDate(DateTime(2025, 01, 03)), // '03/01/25'
      'report_time': '12:00 PM',
      'report_summary': 'Report summary 3',
      'report_constraint': 'Constraint 3',
      'report_medias_path': [
        'assets/image1.jpg',
        'assets/image2.jpg',
      ],
      'schedule_id': 103,
      'house_address': 'No. 56, Jalan Tun Razak, 50400 Kuala Lumpur, Malaysia',
      'house_img_link': 'assets/house.jpg',
    },
  ];

  final WriteBatch batch = FirebaseFirestore.instance.batch();

  for (final report in dummyReports) {
    final DocumentReference docRef =
        reportsCollection.doc(report['report_id'].toString());
    batch.set(docRef, report);
  }

  try {
    await batch.commit();
    print('Dummy data inserted successfully!');
  } catch (e) {
    print('Error inserting dummy data: $e');
  }
}
