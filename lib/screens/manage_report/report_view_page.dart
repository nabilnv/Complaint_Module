import 'package:flutter/material.dart';

class ReportViewPage extends StatelessWidget {
  final String reportId;
  final Map<String, dynamic> reportData;

  const ReportViewPage({
    Key? key,
    required this.reportId,
    required this.reportData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          toolbarHeight: 100,
          elevation: 4,
          title: const Center(
            child: Text(
              'REPORT',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 20.0, left: 30, right: 30),
        child: Card(
          color: Colors.yellow[400],
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // House Image & Report ID in Row
                Row(
                  children: [
                    // House Image
                    if (reportData.containsKey('house_img_link') && reportData['house_img_link'] != null)
                      Image.network(
                        reportData['house_img_link'],
                        width: 100.0,
                        height: 100.0,
                        fit: BoxFit.cover,
                      ),
                    const SizedBox(width: 16.0),
                    // Report ID
                    Text(
                      'Report ID:   ',
                      style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      reportId,
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),

                // House Address
                if (reportData.containsKey('house_address'))
                  Row(
                    children: [
                      const Text(
                        'House Address:',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Text(
                          reportData['house_address'],
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 8.0),

                // Report Date & Report Time in Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (reportData.containsKey('report_date') & reportData.containsKey('report_time'))
                      Row(
                        children: [
                          const Text(
                            'Report Date & Time:',
                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 16.0),
                          Text(
                            '${reportData['report_date']} (${reportData['report_time']})',
                            style: const TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 8.0),

                // Report Summary (One line)
                if (reportData.containsKey('report_summary'))
                  Row(
                    children: [
                      const Text(
                        'Report Summary:',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Text(
                          reportData['report_summary'],
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16.0),

                // Report Constraint Card
                if (reportData.containsKey('report_constraint'))
                  Row(
                    children: [
                      const Text(
                        'Report Constraint:',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Text(
                          reportData['report_constraint'],
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16.0),

                // Report Media Card
                if (reportData.containsKey('report_medias_path') && reportData['report_medias_path'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Report Media:',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8.0),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: List.generate(
                          reportData['report_medias_path'].length,
                          (index) => Image.network(
                            reportData['report_medias_path'][index],
                            width: 100.0,
                            height: 100.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
