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

  // Dropdown filter variables
  String? _selectedLocation;
  String? _selectedEmploymentType;
  String? _selectedSalaryRange;

  // Dropdown options
  final List<String> _locations = ['Remote', 'Pune', 'Bangalore', 'Hyderabad', 'Chennai', 'Mumbai'];
  final List<String> _employmentTypes = ['Full-Time', 'Part-Time', 'Internship'];
  final List<String> _salaryRanges = ['<3LPA', '3-10LPA', '>10LPA'];

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = "";
      _selectedLocation = null;
      _selectedEmploymentType = null;
      _selectedSalaryRange = null;
    });
  }

  Stream<List<Job>> _getFilteredJobs() {
    final query = FirebaseFirestore.instance.collection('jobs');
    var filteredQuery = query;

    return filteredQuery.snapshots().map((snapshot) {
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

      // Filter jobs based on search query and dropdown filters
      return allJobs.where((job) {
        final titleLower = job.title.toLowerCase();
        final companyLower = job.companyInfo.toLowerCase();
        final matchesQuery = titleLower.contains(_searchQuery) || companyLower.contains(_searchQuery);

        final matchesLocation = _selectedLocation == null || job.location == _selectedLocation;
        final matchesEmploymentType = _selectedEmploymentType == null || job.employmentType == _selectedEmploymentType;
        final matchesSalaryRange = _selectedSalaryRange == null || _matchesSalaryRange(job.salary);

        return matchesQuery && matchesLocation && matchesEmploymentType && matchesSalaryRange;
      }).toList();
    });
  }

  bool _matchesSalaryRange(String salary) {
    try {
      final sal = int.parse(salary.replaceAll(RegExp(r'\D'), '')); // Remove non-numeric characters
      if (_selectedSalaryRange == '<3LPA') return sal < 300000;
      if (_selectedSalaryRange == '3-10LPA') return sal >= 300000 && sal <= 1000000;
      if (_selectedSalaryRange == '>10LPA') return sal > 1000000;
    } catch (e) {
      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    Future.delayed(Duration.zero, () {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        title: Text('Job Search'),
        actions: [
          TextButton(
            onPressed: _clearFilters,
            child: Text(
              'Clear Filters',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
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
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Search by Title or Company',
                    border: InputBorder.none,
                    suffixIcon: Icon(Icons.search),
                    contentPadding: EdgeInsets.all(16.0),
                  ),
                ),
              ),
            ),
          ),

          // Dropdown filters and Clear Filters button
          Container(
            color: Colors.blue[100],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        value: _selectedLocation,
                        onChanged: (value) => setState(() => _selectedLocation = value),
                        items: _locations.map((location) {
                          return DropdownMenuItem(
                            value: location,
                            child: Text(location),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    SizedBox(
                      width: 150,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Employment Type',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        value: _selectedEmploymentType,
                        onChanged: (value) => setState(() => _selectedEmploymentType = value),
                        items: _employmentTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    SizedBox(
                      width: 150,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Salary Range',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        value: _selectedSalaryRange,
                        onChanged: (value) => setState(() => _selectedSalaryRange = value),
                        items: _salaryRanges.map((range) {
                          return DropdownMenuItem(
                            value: range,
                            child: Text(range),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          

          // Job List
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
                    return JobCard(job: job,);
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
