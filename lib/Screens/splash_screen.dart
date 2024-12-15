import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatelessWidget {
  Future<void> _navigate(BuildContext context) async {
    // Check if the user is already logged in
    final User? currentUser = FirebaseAuth.instance.currentUser;

    // Check if onboarding has been seen
    final prefs = await SharedPreferences.getInstance();
    final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

    if (currentUser != null) {
      // User is logged in, navigate to home
      Navigator.pushReplacementNamed(context, '/home');
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
  Future.delayed(Duration(seconds: 2), () {
    _navigate(context);
  });

  return Scaffold(
      body: Center(
        child: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Lottie.asset(
            'assets/splashScreen/SplashScreenAnimation.json', // Replace with your Lottie file path
            fit: BoxFit.fill, // Ensures the animation covers the entire screen
          ),
        ),
      ),
    );
}

}
