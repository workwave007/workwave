import 'dart:convert';

import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:job_apply_hub/Screens/Sections/jobPortal/jobDetails.dart';
import 'package:job_apply_hub/Screens/Sections/jobPortal/jobSearch.dart';
import 'package:job_apply_hub/Screens/Sections/jobPortal/savedJob.dart';
import 'package:job_apply_hub/Screens/ads/bannerAdWidget.dart';
import 'package:job_apply_hub/Screens/ads/interstitialAdWidget.dart';
import 'package:job_apply_hub/Screens/ads/nativeAdWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final Timestamp postedAt;

  Job({
    required this.image,
    required this.title,
    required this.companyInfo,
    required this.jobSummary,
    required this.salary,
    required this.employmentType,
    required this.applyLink,
    required this.location,
    required this.postedAt,
  });

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
      postedAt: doc['postedAt'],
    );
  }

  // Convert Job object to Map (for saving in shared_preferences)
  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'title': title,
      'companyInfo': companyInfo,
      'jobSummary': jobSummary,
      'salary': salary,
      'employmentType': employmentType,
      'applyLink': applyLink,
      'location': location,
      'postedAt': postedAt.toDate().toIso8601String(), // Convert Timestamp to String
    };
  }

  // Convert Map to Job object
  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      image: map['image'],
      title: map['title'],
      companyInfo: map['companyInfo'],
      jobSummary: map['jobSummary'],
      salary: map['salary'],
      employmentType: map['employmentType'],
      applyLink: map['applyLink'],
      location: map['location'],
      postedAt: Timestamp.fromDate(DateTime.parse(map['postedAt'])),
    );
  }

  String formattedPostedAt() {
    DateTime dateTime = postedAt.toDate();
    return DateFormat('MMMM dd, yyyy, h:mm a').format(dateTime);
  }
}


class JobScreen extends StatefulWidget {
  const JobScreen({super.key});

  @override
  _JobScreenState createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // Set the number of tabs
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue[50],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Job Portal',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.bookmark_border, color: Colors.black),
                  onPressed: () {
                     Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SavedJobsScreen()),
        );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.blue[50],
            child: Column(
              children: [
                Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: (){
                    Navigator.push(context,
                         MaterialPageRoute(
                         builder: (context) => SearchScreen(),
                        ),
                      );

                  },
                  child: Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width*0.9,
                              height: MediaQuery.of(context).size.width*0.15,
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
                      child: Row(
                                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(Icons.search, color: Colors.grey),
                  ),
                  Expanded(
                    
                      child: Text(
                        'Search for jobs and company',
                        style: TextStyle(color: Colors.grey),
                    
                    ),
                  ),
                        ],
                      ),
                    )
                  ),
                ),
                
              ],
            ),
          ),
          const SizedBox(height: 10),
          ButtonsTabBar(
            controller: _tabController,
            backgroundColor: Colors.blue,
            unselectedBackgroundColor: Colors.blue[100],
            unselectedLabelStyle: TextStyle(color: Colors.black),
            contentPadding: EdgeInsets.all(10),
            height: 50,
            radius: 20,
            borderColor: Colors.black,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Java Developer'),
              Tab(text: 'Python Developer'),
              Tab(text: 'Data Analyst')
            ]),
            SizedBox(height: 10,)
              ],
            ),
          ),
          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                JobList(jobTitle: 'All'), // For 'All'
                JobList(jobTitle: 'Java Developer'), // For 'Java Developer'
                JobList(jobTitle: 'Python Developer'), // For 'Python Developer'
                JobList(jobTitle: 'Data Analyst'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class JobList extends StatefulWidget {
  final String jobTitle;

  const JobList({super.key, required this.jobTitle});

  @override
  _JobListState createState() => _JobListState();
}

class _JobListState extends State<JobList> {
  List<Job> jobs = [];
  DocumentSnapshot? lastDocument;
  bool isLoading = false;
  bool hasMore = true;
  final int pageSize = 10;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _fetchJobs();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchJobs() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    Query query = FirebaseFirestore.instance
        .collection('jobs')
        .orderBy('postedAt', descending: true)
        .limit(pageSize);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }

    if (widget.jobTitle != 'All') {
      query = query.where('title', isEqualTo: widget.jobTitle);
    }

    try {
      QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last; // Update the last fetched document
        jobs.addAll(snapshot.docs.map((doc) => Job.fromFirestore(doc)).toList());
        if (snapshot.docs.length < pageSize) {
          hasMore = false; // No more jobs to fetch
        }
      } else {
        hasMore = false; // No more jobs to fetch
      }
    } catch (error) {
      print('Error fetching jobs: $error');
    }

    setState(() {
      isLoading = false;
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        hasMore &&
        !isLoading) {
      _fetchJobs(); // Fetch the next page of jobs
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: jobs.length + 1, // Add 1 for the loading indicator
      itemBuilder: (context, index) {
        if (index < jobs.length) {
          if (index % 3 == 2) {
            return NativeAdWidget(); // Show an ad every third job
          } else {
            return JobCard(job: jobs[index]);
          }
        } else {
          // Show a loading indicator at the end
          return hasMore
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  ),
                )
              : const SizedBox(); // Empty widget if no more jobs
        }
      },
    );
  }
}


class SavedJobsManager {
  // Save a job to shared_preferences
  static Future<void> saveJob(Job job) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedJobsJson = prefs.getStringList('savedJobs') ?? [];

    // Convert job to a Map and then to a JSON string
    String jobJson = json.encode(job.toMap());

    // Add job to the list and save it back
    savedJobsJson.add(jobJson);
    await prefs.setStringList('savedJobs', savedJobsJson);
  }

  // Fetch saved jobs from shared_preferences
  static Future<List<Job>> fetchSavedJobs() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedJobsJson = prefs.getStringList('savedJobs') ?? [];

    return savedJobsJson
        .map((jobJson) => Job.fromMap(json.decode(jobJson)))
        .toList();
  }

  // Remove a job from saved jobs list
  static Future<void> deleteJob(Job job) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedJobsJson = prefs.getStringList('savedJobs') ?? [];

    // Remove the job from the list
    savedJobsJson.removeWhere((jobJson) => json.encode(job.toMap()) == jobJson);

    // Save the updated list back to shared_preferences
    await prefs.setStringList('savedJobs', savedJobsJson);
  }
}



List<Color> colorScheme = [
  const Color(0xFFB0DDF2), // Light blue
  const Color(0xFFFFEDBB), // Light yellow
  const Color(0xFFFFC6C6), // Light pink
  const Color(0xFFE8FFC6), // Light green
  const Color(0xFFFFCDF7), // Light purple
];
class JobCard extends StatefulWidget {
  final Job job;

  const JobCard({Key? key, required this.job}) : super(key: key);

  @override
  _JobCardState createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _bannerAd = _createBannerAd();
    Interstitialadwidget.loadInterstitialAd(); // Create the ad when the card is initialized
  }

  

  // Create BannerAd and pre-load it
  BannerAd _createBannerAd() {
    return BannerAd(
      adUnitId: 'ca-app-pub-6846718920811344/7291118535', // Replace with your Banner Ad Unit ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true; // Mark ad as loaded
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('Ad failed to load: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    // Dispose of the ad when the widget is disposed
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
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
                      widget.job.image,
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
                        colors: [
                          Colors.black.withOpacity(0.5),
                          Colors.transparent,
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
                      widget.job.title,
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                            widget.job.companyInfo,
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
                          icon: Icon(Icons.bookmark_border, color: Colors.deepPurple),
                          onPressed: () async {
                            await SavedJobsManager.saveJob(widget.job);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Job saved to bookmarks')),
                            );
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
                          text: widget.job.salary,
                          color: Colors.green,
                          screenWidth: screenWidth,
                        ),
                        _buildInfoBadge(
                          icon: Icons.location_on,
                          text: widget.job.location,
                          color: Colors.blue,
                          screenWidth: screenWidth,
                        ),
                        _buildInfoBadge(
                          icon: Icons.work,
                          text: widget.job.employmentType,
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
                            Icon(Icons.access_time, size: screenWidth * 0.04, color: Colors.grey),
                            SizedBox(width: 5),
                            Text(
                              widget.job.formattedPostedAt(),
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

                            Interstitialadwidget.showInterstitialAd();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => JobDetailsPage(
                                  image: widget.job.image,
                                  title: widget.job.title,
                                  companyInfo: widget.job.companyInfo,
                                  jobSummary: widget.job.jobSummary,
                                  salary: widget.job.salary,
                                  employmentType: widget.job.employmentType,
                                  applyLink: widget.job.applyLink,
                                  location: widget.job.location,
                                  postedAt: widget.job.postedAt,
                                ),
                              ),
                            );
                          },
                          child: Text('Apply Now', style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04)),
                        ),
                      ],
                    ),
                    BannerAdWidget(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
}