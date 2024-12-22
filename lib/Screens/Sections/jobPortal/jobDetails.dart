import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting Timestamp to date

class JobDetailsPage extends StatelessWidget {
  final String image;
  final String title;
  final String companyInfo;
  final String jobSummary;
  final String salary;
  final String employmentType;
  final String applyLink;
  final String location;
  final Timestamp postedAt;

  const JobDetailsPage({
    Key? key,
    required this.image,
    required this.title,
    required this.companyInfo,
    required this.jobSummary,
    required this.salary,
    required this.employmentType,
    required this.applyLink,
    required this.location,
    required this.postedAt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      body: SingleChildScrollView(
        
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stack to overlay the back button and the title container over the image
            Stack(
              children: [
                // Job Image
                Container(
                  padding: EdgeInsets.only(),
                  height: MediaQuery.of(context).size.height / 3, // 1/3 of screen height
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: Image.network(
                      image,
                      height: double.infinity,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height / 3,
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.4), // Adjust opacity here (0.0 to 1.0)
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30,left: 20),
                  child: Positioned(
                    top: 16,
                    left: 16,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Company Info
            Text(
              companyInfo,
              style: TextStyle(color: Colors.grey[700], fontSize: 24),
            ),
            const SizedBox(height: 16),

            // Location and Posted Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 18, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      location,
                    ),
                  ],
                ),
                Text(
                  'Posted: ${DateFormat.yMMMd().format(postedAt.toDate())}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            const Divider(height: 32),

            // Job Summary
            Text(
              'Job Summary',
            ),
            const SizedBox(height: 8),
            Text(
              jobSummary,
            ),
            const Divider(height: 32),

            // Salary & Employment Type
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.currency_rupee, size: 18, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      salary,
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.work_outline, size: 18, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      employmentType,
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 32),

            // Apply Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Open apply link
                  if (applyLink.isNotEmpty) {
                    launchURL(applyLink);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Apply Now',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void launchURL(String url) {
    EasyLauncher.url(
      url: url,
      mode: Mode.externalApp,
    );
  }
}
