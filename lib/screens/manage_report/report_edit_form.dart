import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sep_module_razzaq/controllers/report_controller.dart';

class ReportEditForm extends StatefulWidget {
  final int reportId; // Pass the report ID to edit
  final Map<String, dynamic> initialData; // Initial data for pre-filling the form

  const ReportEditForm({
    super.key,
    required this.reportId,
    required this.initialData,
  });

  @override
  State<ReportEditForm> createState() => _ReportEditFormState();
}

class _ReportEditFormState extends State<ReportEditForm> {
  final _formKey = GlobalKey<FormState>();
  late String _jobCompletedSummary;
  late String _jobConstraintSummary;
  List<PlatformFile> _mediaFiles = [];
  late List<String> _existingMediaFiles;

  @override
  void initState() {
    super.initState();
    _jobCompletedSummary = widget.initialData['report_summary'];
    _jobConstraintSummary = widget.initialData['report_constraint'];
    _existingMediaFiles = List<String>.from(widget.initialData['report_medias_path']);
  }

  Future<void> _pickMediaFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _mediaFiles = result.files;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No files selected')),
      );
    }
  }

  void _deleteMediaFile(PlatformFile file) {
    setState(() {
      _mediaFiles.remove(file); // Remove the file from the list
    });
  }

  void _submitReport() async {
    if (_formKey.currentState!.validate()) {
      final reportSummary = _jobCompletedSummary;
      final reportConstraint = _jobConstraintSummary;

      // Combine existing media with newly uploaded files
      List<String> reportMediasPath = [
        ..._existingMediaFiles,
        ..._mediaFiles.map((file) => file.path ?? file.name),
      ];

      final reportController = ReportController();
      await reportController.updateReport(
        widget.reportId,
        widget.initialData['report_date'],
        widget.initialData['report_time'],
        reportSummary,
        reportConstraint,
        reportMediasPath,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report updated successfully!')),
      );
      Navigator.pop(context);
    }
  }

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
              'EDIT REPORT FORM',
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
                  child: Text('Edit Report', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                          initialValue: _jobCompletedSummary,
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
                          initialValue: _jobConstraintSummary,
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
                        // Show existing media
                        _existingMediaFiles.isNotEmpty
                            ? Column(
                                children: _existingMediaFiles.map((path) {
                                  return ListTile(
                                    leading: path.endsWith('.mp4')
                                        ? const Icon(Icons.videocam)
                                        : const Icon(Icons.image),
                                    title: Text(path.split('/').last),
                                  );
                                }).toList(),
                              )
                            : const Text('No existing media.'),
                        // Show newly uploaded files
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
                                        _deleteMediaFile(file); // Remove the file
                                      },
                                    ),
                                  );
                                }).toList(),
                              )
                            : const Text('No new media uploaded.'),
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
