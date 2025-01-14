import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sep_module_razzaq/controllers/report_controller.dart';

class ReportForm extends StatefulWidget {
  const ReportForm({super.key});

  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  final _formKey = GlobalKey<FormState>();
  String _jobCompletedSummary = '';
  String _jobConstraintSummary = '';
  List<PlatformFile> _mediaFiles = [];

  Future<void> _pickMediaFiles() async {
    // Allow users to pick multiple images or videos
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _mediaFiles = result.files;
      });
    } else {
      // Handle case where no files are selected
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No files selected')));
    }
  }

  // Function to format date as 'dd/MM/yy'
  String formatDate(DateTime date) {
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString().substring(2);
    return '$day/$month/$year';
  }

  // Function to format time as 'hh:mm a' (AM/PM)
  String formatTime(DateTime time) {
    int hour = time.hour;
    int minute = time.minute;
    String ampm = hour >= 12 ? 'PM' : 'AM';
    
    if (hour > 12) {
      hour -= 12;
    }
    if (hour == 0) {
      hour = 12; 
    }
    
    String formattedMinute = minute.toString().padLeft(2, '0');
    return '$hour:$formattedMinute $ampm';
  }

  void _submitReport() async {
    if (_formKey.currentState!.validate()) {
      final reportId = DateTime.now().millisecondsSinceEpoch;
      final reportDate = DateTime.now();
      final formattedDate = formatDate(reportDate);
      final formattedTime = formatTime(reportDate);

      final reportSummary = _jobCompletedSummary;
      final reportConstraint = _jobConstraintSummary;

      List<String> reportMediasPath = _mediaFiles.map((file) => file.path ?? file.name).toList();

      final reportController = ReportController();
      await reportController.addReport(
        reportId,
        formattedDate,
        formattedTime,
        reportSummary,
        reportConstraint,
        reportMediasPath,
        1,
        'Sample House Address',
        'assets/house.jpg',
      );

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted successfully!')));
      Navigator.pop(context);
    }
  }

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
              'REPORT FORM',
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          child: Card(
            color: Colors.yellow[400],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, top: 20.0),
                  child: Text('New Report', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10.0),
                Container(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Job Completed Summary:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        TextFormField(
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Enter job completed summary',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter job completed summary';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _jobCompletedSummary = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Job Constraint Summary:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        TextFormField(
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Enter job constraint summary',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter job constraint summary';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _jobConstraintSummary = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Result of Cleaning (Upload Media):',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),  
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: _pickMediaFiles,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 30),
                            ),
                            child: const Text('Upload Images/Videos'),
                          ),
                        ),                      
                        _mediaFiles.isNotEmpty
                            ? Column(
                                children: _mediaFiles.map((file) {
                                  return ListTile(
                                    leading: file.extension == 'mp4'
                                        ? const Icon(Icons.videocam)
                                        : const Icon(Icons.image),
                                    title: Text(file.name),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        setState(() {
                                          _mediaFiles.remove(file);  // Remove the file from the list
                                        });
                                      },
                                    ),
                                  );
                                }).toList(),
                              )
                            : const Text('No media uploaded.'),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitReport,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(80.0),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 20.0),
                            ),
                            child: const Text('Submit'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
