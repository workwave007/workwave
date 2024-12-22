import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:job_apply_hub/Screens/Sections/jobPortal/jobPortalSection.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  FocusNode _focusNode = FocusNode();

  // Method to listen for changes in the search field
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  Stream<List<Job>> _getFilteredJobs() {
    final query = FirebaseFirestore.instance.collection('jobs');

    // Perform an initial query for all jobs (no filtering yet)
    var filteredQuery = query;

    return filteredQuery.snapshots().map((snapshot) {
      // Filter the results locally on the client side after fetching all jobs
      final allJobs = snapshot.docs.map((doc) {
        return Job(
          image: doc['image'],
          title: doc['title'],
          companyInfo: doc['companyInfo'],
          jobSummary: doc['jobSummary'],
          salary: doc['salary'],
          employmentType: doc['employmentType'],
          applyLink: doc['applyLink'],
          location: doc['location'],
          postedAt: doc['postedAt'],
        );
      }).toList();

      // Filter jobs based on the search query (case insensitive)
      return allJobs.where((job) {
        final titleLower = job.title.toLowerCase();
        final companyLower = job.companyInfo.toLowerCase();
        return titleLower.contains(_searchQuery) || companyLower.contains(_searchQuery);
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    Future.delayed(Duration.zero, () {
      FocusScope.of(context).requestFocus(_focusNode);  // Request focus after the widget is built
    }); // Listen for changes in the search field
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged); // Clean up listener when the widget is disposed
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        title: Text('Job Search'),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.blue[100],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                
                decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(color: Colors.grey),
                                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // Shadow color with opacity
                    spreadRadius: 1, // Spread of the shadow
                    blurRadius: 5, // Blur radius of the shadow
                    offset: Offset(1, 1), // Position of the shadow (x, y offset)
                  ),
                ],
             ),
         child: TextField(
  controller: _searchController,
  focusNode: _focusNode,
  decoration: InputDecoration(
    hintText: 'Search by Title or Company', // Placeholder text
    border: InputBorder.none, // No border
    enabledBorder: InputBorder.none, // No border when not focused
    focusedBorder: InputBorder.none, // No border when focused
    suffixIcon: Icon(Icons.search), // Search icon
    contentPadding: EdgeInsets.all(16.0), // Add padding for better appearance
  ),
),
              ),
            ),
          ),
          // Job List (Real-time results as user types)
          Expanded(
            child: StreamBuilder<List<Job>>(
              stream: _getFilteredJobs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No jobs found.'));
                }

                final jobs = snapshot.data!;
                return ListView.builder(
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return JobCard(job: job);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
