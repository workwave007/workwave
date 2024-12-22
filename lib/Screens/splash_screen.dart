import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:job_apply_hub/Screens/homeScreen.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatelessWidget {
  final String? notificationType; // Add notificationType parameter

  const SplashScreen({super.key, this.notificationType});

  Future<void> _navigate(BuildContext context) async {
    // Check if the user is already logged in
    final User? currentUser = FirebaseAuth.instance.currentUser;

    // Check if onboarding has been seen
    final prefs = await SharedPreferences.getInstance();
    final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

    // Determine where to navigate based on notification type
    int index = 0; // Default to home if no notification type
    if (notificationType != null) {
      if (notificationType == 'job') {
        index = 1; // Job portal (index 1)
      } else if (notificationType == 'news') {
        index = 2; // Tech news (index 2)
      }
    }

    // Decide navigation based on user authentication and first-time status
    if (currentUser != null) {
      // User is logged in, navigate to home screen with the redirection index
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(redirectToIndex: index),
        ),
      );
    } else if (isFirstTime) {
      // Show onboarding if it's the first time
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else {
      // Navigate to login if not logged in and onboarding is done
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Trigger the navigation after the splash screen animation
    Future.delayed(const Duration(seconds: 2), () {
      _navigate(context);
    });

    return Scaffold(
      body: Center(
        child: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Lottie.asset(
            'assets/splashScreen/SplashScreenAnimation.json', // Your Lottie file path
            fit: BoxFit.fill, // Ensures the animation covers the entire screen
          ),
        ),
      ),
    );
  }
}
