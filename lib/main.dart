import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:job_apply_hub/Screens/Features/ImageToPDF/imgToPdf.dart';
import 'package:job_apply_hub/Screens/Features/Resume/ResumeHomeScreen.dart';
import 'package:job_apply_hub/Screens/Sections/jobPortalSection.dart';
import 'package:job_apply_hub/Screens/Sections/techNewsSection.dart';
import 'package:job_apply_hub/Screens/homeScreen.dart';
import 'package:job_apply_hub/Screens/on_boading_screen.dart';
import 'package:job_apply_hub/Screens/splash_screen.dart';
import 'package:job_apply_hub/service/fcm_service.dart';
import 'Screens/sign_in_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  MobileAds.instance.initialize(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // Adding a named 'key' parameter to the constructor.
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize FCMService with context after dependencies are initialized
    FCMService.initialize(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JobApplyHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/login': (context) => SignInScreen(),
        '/onboarding': (context) => OnboardingScreen(),
        '/jobPortal': (context) => JobPortalSection(),
        '/newsSection': (context) => TechNewsSection(),
        '/resumeBuilder': (context) => HtmlStringLoader(),
        '/imgToPdf': (context) => ImageToPDFPage(), // Route for Home screen
      },
    );
  }
}
