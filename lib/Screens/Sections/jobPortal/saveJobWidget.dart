import 'package:flutter/material.dart';
import 'package:job_apply_hub/Screens/Sections/jobPortal/jobDetails.dart';
import 'package:job_apply_hub/Screens/Sections/jobPortal/jobPortalSection.dart';
// Assuming you have a Job model

class SavedJobCard extends StatelessWidget {
  final Job job;
  final Function onDelete;

  const SavedJobCard({
    Key? key,
    required this.job,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailsPage(
              image: job.image,
              title: job.title,
              companyInfo: job.companyInfo,
              jobSummary: job.jobSummary,
              salary: job.salary,
              employmentType: job.employmentType,
              applyLink: job.applyLink,
              location: job.location,
              postedAt: job.postedAt,
            ),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.03), // Responsive padding
        child: Container(
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
                            child: Icon(Icons.broken_image,
                                size: 60, color: Colors.grey),
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
                          colors: [
                            Colors.black.withOpacity(0.5),
                            Colors.transparent
                          ],
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
                          fontSize: screenWidth * 0.05, // Responsive font size
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis, // Prevent overflow
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              job.companyInfo,
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () async{
                             await SavedJobsManager.deleteJob(job);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Job removed from bookmarks')),
                        );
                        onDelete();
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.03),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoBadge(
                            icon: Icons.currency_rupee,
                            text: job.salary,
                            color: Colors.green,
                            screenWidth: screenWidth,
                          ),
                          _buildInfoBadge(
                            icon: Icons.location_on,
                            text: job.location,
                            color: Colors.blue,
                            screenWidth: screenWidth,
                          ),
                          _buildInfoBadge(
                            icon: Icons.work,
                            text: job.employmentType,
                            color: Colors.purple,
                            screenWidth: screenWidth,
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.03),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.access_time,
                                  size: screenWidth * 0.04, color: Colors.grey),
                              SizedBox(width: 5),
                              Text(
                                job.formattedPostedAt(),
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: Colors.grey,
                                ),
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
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => JobDetailsPage(
                                    image: job.image,
                                    title: job.title,
                                    companyInfo: job.companyInfo,
                                    jobSummary: job.jobSummary,
                                    salary: job.salary,
                                    employmentType: job.employmentType,
                                    applyLink: job.applyLink,
                                    location: job.location,
                                    postedAt: job.postedAt,
                                  ),
                                ),
                              );
                            },
                            child: Text('Apply Now',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.04)),
                          ),
                        ],
                      ),
                    ],
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

Widget _buildInfoBadge({
  required IconData icon,
  required String text,
  required Color color,
  required double screenWidth, // Pass screenWidth for responsiveness
}) {
  return Container(
    padding: EdgeInsets.symmetric(
      vertical: screenWidth * 0.02, // Dynamic vertical padding
      horizontal: screenWidth * 0.03, // Dynamic horizontal padding
    ),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: color,
        width: 1,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min, // Shrink to fit content
      children: [
        Icon(
          icon,
          color: color,
          size: screenWidth * 0.045, // Responsive icon size
        ),
        SizedBox(width: screenWidth * 0.01), // Responsive spacing
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: screenWidth * 0.035, // Responsive font size
              color: color,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1, // Prevent overflow
            overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
          ),
        ),
      ],
    ),
  );
}

