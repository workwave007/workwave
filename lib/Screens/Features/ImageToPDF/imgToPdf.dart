import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class ImageToPDFPage extends StatefulWidget {
  @override
  _ImageToPDFPageState createState() => _ImageToPDFPageState();
}

class _ImageToPDFPageState extends State<ImageToPDFPage> {
  final ImagePicker _picker = ImagePicker();
  File? _pdfFile;
  List<File> _images = [];

  // Pick multiple images
  void _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  // Convert images to PDF
  void _convertToPDF() async {
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select at least one image.")),
      );
      return;
    }

    // Prompt user for a name before converting
    String? appName = await _showNameDialog();
    if (appName == null || appName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please provide a valid name.")),
      );
      return;
    }

    try {
      final pdf = pw.Document();

      // Add images to the PDF
      for (var imageFile in _images) {
        final image = pw.MemoryImage(File(imageFile.path).readAsBytesSync());
        pdf.addPage(pw.Page(build: (pw.Context context) {
          return pw.Center(child: pw.Image(image));
        }));
      }

      // Save the PDF
      final outputDir = await getApplicationDocumentsDirectory();
      final pdfFile = File("${outputDir.path}/$appName.pdf");
      await pdfFile.writeAsBytes(await pdf.save());

      setState(() {
        _pdfFile = pdfFile;
      });

      // Navigate to the next page with the name and PDF icon
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewPage(pdfFile: _pdfFile!, appName: appName),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // Show a dialog to get the app name from the user
  Future<String?> _showNameDialog() async {
    TextEditingController nameController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter a name for your PDF"),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: "Enter name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, nameController.text);
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Delete an image
  void _deleteImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Image to PDF Converter")),
      body: Column(
        children: [
          // Display images in a reorderable grid with delete functionality and indices
          Expanded(
            child: ReorderableGridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return Card(
                  key: ValueKey(_images[index]),
                  child: Stack(
                    children: [
                      // Display image
                      Positioned.fill(
                        child: Image.file(
                          _images[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Display index
                      Positioned(
                        top: 5,
                        left: 5,
                        child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            "${index + 1}",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // Delete button
                      Positioned(
                        top: 5,
                        right: 5,
                        child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteImage(index),
                        ),
                      ),
                    ],
                  ),
                );
              },
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  final element = _images.removeAt(oldIndex);
                  _images.insert(newIndex, element);
                });
              },
            ),
          ),
          ElevatedButton(
            onPressed: _pickImages,
            child: Text("Pick Images"),
          ),
          ElevatedButton(
            onPressed: _convertToPDF,
            child: Text("Convert to PDF"),
          ),
        ],
      ),
    );
  }
}

class PDFViewPage extends StatelessWidget {
  final File pdfFile;
  final String appName;

  PDFViewPage({required this.pdfFile, required this.appName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appName)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("PDF: $appName"),
            IconButton(
              icon: Icon(Icons.picture_as_pdf, size: 50),
              onPressed: () {
                OpenFilex.open(pdfFile.path);
              },
            ),
            ElevatedButton(
            onPressed: (){OpenFilex.open(pdfFile.path);},
            child: Text("Open Pdf"),
          ),

          ],
        ),
      ),
    );
  }
}
