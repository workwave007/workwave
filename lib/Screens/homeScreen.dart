import 'package:flutter/material.dart';
import 'package:job_apply_hub/Screens/Sections/HomeSection.dart';
import 'package:job_apply_hub/Screens/Sections/jobPortalSection.dart';
import 'package:job_apply_hub/Screens/Sections/techNewsSection.dart';
import 'package:job_apply_hub/service/fcm_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeSection(),
    JobPortalSection(),
    TechNewsSection(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Job Portal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'Tech News',
          ),
        ],
      ),
    );
  }
}



// class JobPortalSection extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         'Job Portal Section',
//         style: TextStyle(fontSize: 24),
//       ),
//     );
//   }
// }


