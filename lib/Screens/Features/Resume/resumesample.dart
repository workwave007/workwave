import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';

class ResumePreviewPage extends StatefulWidget {
  @override
  _ResumePreviewPageState createState() => _ResumePreviewPageState();
}

class _ResumePreviewPageState extends State<ResumePreviewPage> {
  late pw.Document pdf;

  @override
  void initState() {
    super.initState();
    pdf = pw.Document();
  }

  // Generate Resume PDF with manual conversion
  void generateResumePDF() {
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Title
                pw.Center(
                  child: pw.Text(
                    'John Doe',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue,
                    ),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    'Flutter Developer | UI/UX Designer',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                ),
                pw.SizedBox(height: 16),

                // Summary Section
                pw.Container(
                  color: PdfColors.blue,
                  padding: const pw.EdgeInsets.all(8.0),
                  child: pw.Text(
                    'Brief Summary',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8.0),
                  child: pw.Text(
                    "A dedicated software developer with 5 years of experience specializing in Flutter and mobile app development.",
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
                pw.SizedBox(height: 16),

                // Skills Section
                pw.Container(
                  color: PdfColors.blue,
                  padding: const pw.EdgeInsets.all(8.0),
                  child: pw.Text(
                    'Key Expertise',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8.0),
                  child: pw.Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: ['Flutter', 'Dart', 'Firebase', 'UI/UX Design', 'Problem Solving']
                        .map((skill) => pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.grey300,
                                borderRadius: pw.BorderRadius.circular(10),
                              ),
                              child: pw.Text(
                                skill,
                                style: const pw.TextStyle(fontSize: 12),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                pw.SizedBox(height: 16),

                // Education Section
                pw.Text(
                  'Education',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Bullet(
                    text:
                        'Master of Computer Science - XYZ University (2018-2020)'),
                pw.Bullet(
                    text:
                        'Bachelor of Information Technology - ABC College (2014-2018)'),
                pw.SizedBox(height: 16),

                // Experience Section
                pw.Text(
                  'Experience',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Bullet(
                    text:
                        'Frontend Developer - TechCorp (2020-Present): Developed responsive web applications using React and Bootstrap.'),
                pw.Bullet(
                    text:
                        'Intern Web Developer - WebSolutions (2018-2020): Assisted in designing and maintaining client websites.'),
                pw.SizedBox(height: 16),

                // Projects Section
                pw.Text(
                  'Projects',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Bullet(
                    text:
                        'Portfolio Website: Designed a personal portfolio using HTML, CSS, and JavaScript.'),
                pw.Bullet(
                    text:
                        'E-commerce Platform: Built a full-stack e-commerce site with a focus on UI/UX design.'),
              ],
            ),
          );
        },
      ),
    );
  }

  // Save PDF to local storage
  Future<File> savePDF() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/resume.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // Open PDF
  void openPDF(File file) {
    OpenFilex.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Preview'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SummarySection(
                  summary:
                      "A dedicated software developer with 5 years of experience specializing in Flutter and mobile app development."),
              SkillsSection(
                skills: ['Flutter', 'Dart', 'Firebase', 'UI/UX Design', 'Problem Solving'],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          generateResumePDF(); // Generate the PDF content
          final file = await savePDF(); // Save to storage
          openPDF(file); // Open the saved PDF
        },
        child: const Icon(Icons.save),
        tooltip: 'Save and Open PDF',
      ),
    );
  }
}



class SummarySection extends StatelessWidget {
  final String summary;

  const SummarySection({Key? key, required this.summary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header with blue background
        Container(
          color: Colors.blue,
          padding: const EdgeInsets.all(12.0),
          child: const Text(
            'Brief Summary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Summary content
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            summary,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}


class SkillsSection extends StatelessWidget {
  final List<String> skills;

  const SkillsSection({Key? key, required this.skills}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header with blue background
        Container(
          color: Colors.blue,
          padding: const EdgeInsets.all(12.0),
          child: const Text(
            'Key Expertise',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Skills list
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Wrap(
            spacing: 8.0, // Space between each skill horizontally
            runSpacing: 8.0, // Space between each row
            children: skills.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  skill,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}


