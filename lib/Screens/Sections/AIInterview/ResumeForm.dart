import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:job_apply_hub/Screens/Sections/AIInterview/InterviewScreen.dart';
import 'package:job_apply_hub/Screens/ads/bannerAdWidget.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';

class ResumeFormScreen extends StatefulWidget {
  @override
  _ResumeFormScreenState createState() => _ResumeFormScreenState();
}

class _ResumeFormScreenState extends State<ResumeFormScreen> {
  final TextEditingController candidateNameController = TextEditingController();
  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController roleDescriptionController = TextEditingController();

  String resumeText = '';
  String experience = 'Fresher';
  bool isLoading = false;

  final List<String> experienceOptions = [
    'Fresher',
    'Experience 2+ years',
    'Experience 5+ years',
    'Experience 10+ years',
  ];

  Future<String> extractTextFromPdf(String filePath) async {
    try {
      File file = File(filePath);
      final PdfDocument document = PdfDocument(inputBytes: file.readAsBytesSync());
      String extractedText = PdfTextExtractor(document).extractText();
      document.dispose();
      return extractedText;
    } catch (e) {
      return "Error extracting text: $e";
    }
  }

  Future<void> uploadAndExtractResume() async {
    setState(() {
      isLoading = true;
      resumeText = '';
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        String filePath = result.files.single.path!;
        String text = await extractTextFromPdf(filePath);

        setState(() {
          resumeText = text;
        });
      } else {
        setState(() {
          resumeText = "No file selected.";
        });
      }
    } catch (e) {
      setState(() {
        resumeText = "Error extracting text: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void goToInterviewScreen() {
    String candidateName = candidateNameController.text.trim();
    String jobTitle = jobTitleController.text.trim();
    String roleDescription = roleDescriptionController.text.trim();

    if (resumeText.isEmpty || resumeText == "No file selected.") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please upload a resume first!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (candidateName.isEmpty || jobTitle.isEmpty || roleDescription.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    String jobDescription =
        "Candidate: $candidateName, Job Title: $jobTitle, Experience: $experience, Role: $roleDescription.";

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InterviewScreen(
          resumeText: "Extracted Resume Text: $resumeText",
          jobDescriptionText: jobDescription,
          userName: candidateName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text('AI Interviewer',style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      
      body: Container(
        
        child: SingleChildScrollView(
          padding: EdgeInsets.zero, // Remove extra padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resume Upload Section
              Card(
                color: Colors.grey[900],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload Resume (PDF)',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.tealAccent),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: uploadAndExtractResume,
                        icon: Icon(Icons.upload_file, color: Colors.black),
                        label: Text('Upload Resume', style: TextStyle(color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.tealAccent,
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                      if (isLoading)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(color: Colors.tealAccent),
                          ),
                        )
                      else if (resumeText.isNotEmpty && resumeText != "No file selected.")
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            'Resume uploaded and text extracted!',
                            style: TextStyle(color: Colors.greenAccent),
                          ),
                        )
                      else if (resumeText == "No file selected.")
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            'No file selected.',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              //Center(child: BannerAdWidget()),

              // Form Section
              Card(
                color: Colors.grey[900],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: candidateNameController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Candidate Name',
                          labelStyle: TextStyle(color: Colors.tealAccent),
                          prefixIcon: Icon(Icons.person, color: Colors.tealAccent),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.tealAccent),
                          ),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.tealAccent),
                          ),
                        
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: jobTitleController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Job Title',
                          labelStyle: TextStyle(color: Colors.tealAccent),
                          prefixIcon: Icon(Icons.work, color: Colors.tealAccent),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.tealAccent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.tealAccent),
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: experience,
                        dropdownColor: Colors.grey[900],
                        items: experienceOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            experience = newValue!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Experience',
                          labelStyle: TextStyle(color: Colors.tealAccent),
                          prefixIcon: Icon(Icons.timeline, color: Colors.tealAccent),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.tealAccent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.tealAccent),
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: roleDescriptionController,
                        style: TextStyle(color: Colors.white),
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Role Description',
                          labelStyle: TextStyle(color: Colors.tealAccent),
                          prefixIcon: Icon(Icons.description, color: Colors.tealAccent),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.tealAccent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.tealAccent),
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Proceed Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: goToInterviewScreen,
                  child: Text('Proceed to Interview', style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
