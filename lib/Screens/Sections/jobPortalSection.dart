import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

// Job class with Timestamp for postedAt and formatted date display
class Job {
  final String image;
  final String title;
  final String companyInfo;
  final String jobSummary;
  final String salary;
  final String employmentType;
  final String applyLink;
  final String location;
  final Timestamp postedAt; // Timestamp instead of String

  Job({
    required this.image,
    required this.title,
    required this.companyInfo,
    required this.jobSummary,
    required this.salary,
    required this.employmentType,
    required this.applyLink,
    required this.location,
    required this.postedAt, // Timestamp passed here
  });

  // Factory constructor to create a Job from Firestore document
  factory Job.fromFirestore(DocumentSnapshot doc) {
    return Job(
      image: doc['image'],
      title: doc['title'],
      companyInfo: doc['companyInfo'],
      jobSummary: doc['jobSummary'],
      salary: doc['salary'],
      employmentType: doc['employmentType'],
      applyLink: doc['applyLink'],
      location: doc['location'],
      postedAt: doc['postedAt'], // Firestore Timestamp
    );
  }

  // Utility method to format the Timestamp to a readable date-time string
  String formattedPostedAt() {
    // Format postedAt (which is a Timestamp) to a readable string
    DateTime dateTime = postedAt.toDate(); // Convert Timestamp to DateTime
    return DateFormat('MMMM dd, yyyy, h:mm a').format(dateTime); // Example: November 17, 2024, 10:00 AM
  }
}

// JobPortalSection UI
class JobPortalSection extends StatefulWidget {
  @override
  _JobPortalSectionState createState() => _JobPortalSectionState();
}
class _JobPortalSectionState extends State<JobPortalSection> {
  final Set<Job> savedJobs = {}; // Stores saved jobs
  final TextEditingController searchController = TextEditingController(); // Controller for search input
  String searchQuery = ''; // Current search query

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(width: 10),
            Text(
              'Job Finder',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    
      body:Column(
  children: [
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Flexible(
        child: TextField(
          controller: searchController,
          onChanged: (value) {
            setState(() {
              searchQuery = value.trim().toLowerCase(); // Update search query
            });
          },
          decoration: InputDecoration(
            hintText: 'Search for jobs...',
            prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
            filled: true,
            fillColor: Colors.deepPurple.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    ),
    Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .orderBy('postedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoader(); // Show shimmer while loading
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No jobs available',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // Filter jobs based on the search query
          final jobs = snapshot.data!.docs
              .map((doc) => Job.fromFirestore(doc))
              .where((job) => _matchesSearchQuery(job))
              .toList();

          if (jobs.isEmpty) {
            return Center(
              child: Text(
                'No matching jobs found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: jobs.length,
            controller: PageController(viewportFraction: 0.775, initialPage: 0),
            itemBuilder: (context, index) {
              final job = jobs[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: JobCard(
                  job: job,
                  isSaved: savedJobs.contains(job),
                  onSaveToggle: () {
                    setState(() {
                      if (savedJobs.contains(job)) {
                        savedJobs.remove(job);
                      } else {
                        savedJobs.add(job);
                      }
                    });
                  },
                ),
              );
            },
          );
        },
      ),
    ),
  ],
),

    );
  }

  // Helper method to filter jobs based on the search query
  bool _matchesSearchQuery(Job job) {
    return job.title.toLowerCase().contains(searchQuery) ||
        job.companyInfo.toLowerCase().contains(searchQuery) ||
        job.jobSummary.toLowerCase().contains(searchQuery) ||
        job.salary.toLowerCase().contains(searchQuery) ||
        job.employmentType.toLowerCase().contains(searchQuery) ||
        job.applyLink.toLowerCase().contains(searchQuery) ||
        job.location.toLowerCase().contains(searchQuery);
  }

  Widget _buildShimmerLoader() {
    return ListView.builder(
      itemCount: 6, // Number of shimmer items
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 250, // Approximate height of a job card
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        );
      },
    );
  }
}

class JobCard extends StatelessWidget {
  final Job job;
  final bool isSaved;
  final VoidCallback onSaveToggle;

  const JobCard({
    Key? key,
    required this.job,
    required this.isSaved,
    required this.onSaveToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Image.network(
                job.image,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 150,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
                  );
                },
              ),
            ),
                
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Text(
                    job.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        job.companyInfo,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: Colors.deepPurple,
                        ),
                        onPressed: onSaveToggle,
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoBadge(
                        icon: Icons.attach_money,
                        text: job.salary,
                        color: Colors.green,
                      ),
                      _buildInfoBadge(
                        icon: Icons.location_on,
                        text: job.location,
                        color: Colors.blue,
                      ),
                      _buildInfoBadge(
                        icon: Icons.work,
                        text: job.employmentType,
                        color: Colors.purple,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    job.jobSummary,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 18, color: Colors.grey),
                          SizedBox(width: 5),
                          Text(
                            job.formattedPostedAt(), // Display formatted date and time
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () async {
                          await EasyLauncher.url(
                            url: job.applyLink,
                            mode: Mode.externalApp,
                          );
                        },
                        child: Text('Apply Now', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge({required IconData icon, required String text, required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

}
