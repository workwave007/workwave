import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:job_apply_hub/Screens/Features/ImageToPDF/imgToPdf.dart';
import 'package:job_apply_hub/Screens/Features/Resume/ResumeHomeScreen.dart';
import 'package:job_apply_hub/Screens/Sections/jobPortal/jobPortalSection.dart';
import 'package:job_apply_hub/Screens/Sections/TechNews/techNewsSection.dart';
import 'package:job_apply_hub/Screens/homeScreen.dart';
import 'package:job_apply_hub/Screens/on_boading_screen.dart';
import 'package:job_apply_hub/Screens/splash_screen.dart';
import 'package:job_apply_hub/service/fcm_service.dart';
import 'package:job_apply_hub/widgets/global_navigator_key.dart';
import 'Screens/sign_in_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  MobileAds.instance.initialize();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FcmService _fcmService = FcmService();
  await _fcmService.createNotificationChannel();
  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FcmService _fcmService = FcmService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fcmService.requestNotificationPermission();
    _fcmService.subscribeToTopics();
    _fcmService.getDeviceToken().then((value){
     print('Device Token');
     print(value);
    });
    _fcmService.firebaseInit(context);
  }



  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'JobApplyHub',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SplashScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/login': (context) => SignInScreen(),
          '/onboarding': (context) => OnboardingScreen(),
          '/jobPortal': (context) => JobScreen(),
          '/newsSection': (context) => TechNewsSection(),
          '/resumeBuilder': (context) => HtmlStringLoader(),
          '/imgToPdf': (context) => ImageToPDFPage(),
        },
      ),
    );
  }
}


