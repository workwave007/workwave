import 'package:flutter/material.dart';
import 'package:job_apply_hub/Screens/Sections/jobPortal/jobPortalSection.dart';
import 'package:job_apply_hub/Screens/Sections/jobPortal/saveJobWidget.dart';
 // Import the SavedJobCard widget

class SavedJobsScreen extends StatefulWidget {
  @override
  _SavedJobsScreenState createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  late Future<List<Job>> savedJobsFuture;

  @override
  void initState() {
    super.initState();
    savedJobsFuture = SavedJobsManager.fetchSavedJobs();
  }

  // Function to reload the saved jobs after a job is deleted
  void _reloadSavedJobs() {
    setState(() {
      savedJobsFuture = SavedJobsManager.fetchSavedJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Saved Jobs')),
      body: FutureBuilder<List<Job>>(
        future: savedJobsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading saved jobs'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No saved jobs'));
          }

          List<Job> savedJobs = snapshot.data!;

          return ListView.builder(
            itemCount: savedJobs.length,
            itemBuilder: (context, index) {
              return SavedJobCard(
                job: savedJobs[index],
                onDelete: _reloadSavedJobs, // Pass the refresh function
              );
            },
          );
        },
      ),
    );
  }
}
