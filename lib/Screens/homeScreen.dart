import 'package:flutter/material.dart';
import 'package:job_apply_hub/Screens/Sections/HomeSection.dart';
import 'package:job_apply_hub/Screens/Sections/jobPortal/jobPortalSection.dart';
import 'package:job_apply_hub/Screens/Sections/TechNews/techNewsSection.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  final int? redirectToIndex; // Accept index for redirection (nullable)

  const HomeScreen({super.key, this.redirectToIndex});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeSection(),
    JobScreen(),
    TechNewsSection(),
  ];

  @override
  void initState() {
    super.initState();

    // Redirect to the specific tab if `redirectToIndex` is provided
    if (widget.redirectToIndex != null) {
      _currentIndex = widget.redirectToIndex!;
    }
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Set background color based on the current index
    Color backgroundColor;
    switch (_currentIndex) {
      case 0:
        backgroundColor = Colors.purple[50]!; // Light purple for Home
        break;
      case 1:
        backgroundColor = Colors.blue[50]!; // Light blue for Job Portal
        break;
      case 2:
        backgroundColor = Colors.red[50]!; // Light red for News
        break;
      default:
        backgroundColor = Colors.white; // Default color
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: _screens[_currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
        child: SalomonBottomBar(
          backgroundColor: backgroundColor, // Apply dynamic background color
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: [
            /// Home
            SalomonBottomBarItem(
              icon: Icon(Icons.home),
              title: Text("Home"),
              selectedColor: Colors.purple,
            ),

            /// Job Portal
            SalomonBottomBarItem(
              icon: Icon(Icons.work),
              title: Text("Job Portal"),
              selectedColor: Colors.blue,
            ),

            /// News
            SalomonBottomBarItem(
              icon: Icon(Icons.newspaper),
              title: Text("News"),
              selectedColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
