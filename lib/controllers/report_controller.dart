import 'package:cloud_firestore/cloud_firestore.dart';

class ReportController {
  final CollectionReference reportCollection =
      FirebaseFirestore.instance.collection('reports');

  // Add a new report
  Future<void> addReport(
    int reportId,
    String reportDate,
    String reportTime,
    String reportSummary,
    String reportConstraint,
    List<String> reportMediasPath,  // Store both images and videos in this list
    int scheduleId,
    String houseAddress,
    String houseImgLink,
  ) {
    return reportCollection.doc(reportId.toString()).set({
      'report_id': reportId,
      'report_date': reportDate,
      'report_time': reportTime,
      'report_summary': reportSummary,
      'report_constraint': reportConstraint,
      'report_medias_path': reportMediasPath,  // Use a single field for all media
      'schedule_id': scheduleId,
      'house_address': houseAddress,
      'house_img_link': houseImgLink,
    });
  }

  // Fetch all reports
  Stream<QuerySnapshot> getReports() {
    return reportCollection.orderBy('report_date', descending: true).snapshots();
  }

  // Update a report
  Future<void> updateReport(
    int reportId,
    String reportDate,
    String reportTime,
    String reportSummary,
    String reportConstraint,
    List<String> reportMediasPath,  // Update the field to accept media list
  ) {
    return reportCollection.doc(reportId.toString()).update({
      'report_date': reportDate,
      'report_time': reportTime,
      'report_summary': reportSummary,
      'report_constraint': reportConstraint,
      'report_medias_path': reportMediasPath,  // Use the updated field for media
    });
  }

  // Delete a report
  Future<void> deleteReport(int reportId) {
    return reportCollection.doc(reportId.toString()).delete();
  }
}
