// FCM_SERVICE.DART

// import 'dart:convert';
// import 'dart:math';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:job_apply_hub/Screens/splash_screen.dart';
// import 'package:job_apply_hub/widgets/global_navigator_key.dart';

// class FCMService {
//   static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
//   static final FlutterLocalNotificationsPlugin _localNotifications =
//       FlutterLocalNotificationsPlugin();
//   static final GoogleSignIn _googleSignIn = GoogleSignIn();

//   /// Initializes Firebase Cloud Messaging and handles notification redirection
//   static Future<void> initialize(BuildContext context) async {
//     await _requestPermission();
//     await _initializeLocalNotifications(context);

//     // Get the current user
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       print("No user signed in");
//       return;
//     }

//     // Subscribe to topics
//     await _subscribeToTopics();
    
//     // Handle notification when the app is in the background or terminated
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       _handleNotificationClick(context, message);
//     });

//     // Handle initial notification when the app is launched from a terminated state
//     RemoteMessage? initialMessage = await _messaging.getInitialMessage();
//     if (initialMessage != null) {
//       _handleNotificationClick(context, initialMessage);
//     }
//   }

//   /// Subscribes the device to topics like 'news' and 'job'
//   static Future<void> _subscribeToTopics() async {
//     try {
//       await _messaging.subscribeToTopic('news');
//       await _messaging.subscribeToTopic('job');
//       print("Subscribed to 'news' and 'job' topics successfully.");
//     } catch (e) {
//       print("Error subscribing to topics: $e");
//     }
//   }

//   /// Requests notification permissions from the user
//   static Future<void> _requestPermission() async {
//     NotificationSettings settings = await _messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print("User granted notification permissions.");
//     } else {
//       print("User declined notification permissions.");
//     }
//   }

//   /// Initializes local notifications
//   static Future<void> _initializeLocalNotifications(BuildContext context) async {
//     const AndroidInitializationSettings androidSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const InitializationSettings settings = InitializationSettings(
//       android: androidSettings,
//     );

//     await _localNotifications.initialize(
//       settings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) {
//         if (response.payload != null) {
//           final Map<String, dynamic> payloadData = _parsePayload(response.payload!);
//           _handleNotificationClick(context, payloadData as RemoteMessage);
//         }
//       },
//     );
//   }

//   /// Handles notification click and redirects based on type
//   static void _handleNotificationClick(BuildContext context, RemoteMessage message) {
//     final String? notificationType = message.data['type'];
//     _navigateToSplashScreen(context, notificationType);
//   }

//   /// Redirects to the SplashScreen and passes the notification type
//   static void _navigateToSplashScreen(BuildContext context, String? notificationType) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       navigatorKey.currentState?.pushReplacement(
//         MaterialPageRoute(
//           builder: (context) => SplashScreen(notificationType: notificationType),
//         ),
//       );
//     });
//   }

//   /// Parses the payload into a Map
//   static Map<String, dynamic> _parsePayload(String payload) {
//     try {
//       return Map<String, dynamic>.from(jsonDecode(payload));
//     } catch (e) {
//       print("Error parsing payload: $e");
//       return {};
//     }
//   }

//   /// Shows a local notification
//   static Future<void> showNotification(String? title, String? body) async {
  
//    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   // Create a new notification channel with a unique ID and name
//   final AndroidNotificationChannel channel = AndroidNotificationChannel(
//     Random.secure().nextInt(1000000).toString(), // Unique ID
//     'High Importance Notification', // Name of the channel
//     importance: Importance.max,
//   );

//   // Register the channel with the flutterLocalNotificationsPlugin
//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);

//   // Create the Android notification details using the created channel
//   final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//     channel.id.toString(), // Use the channel ID you assigned above
//     channel.name.toString(), // Use the channel name you assigned above
//     channelDescription: 'This is the default channel for notifications',
//     importance: Importance.max, // Maximum importance for heads-up notifications
//     priority: Priority.high, // High priority
//     playSound: true, // Ensure sound plays
//     enableVibration: true, // Enable vibration
//     channelShowBadge: true, // Show the badge for the app
//     visibility: NotificationVisibility.public, // Ensure it's visible over other apps
//     fullScreenIntent: true, // Make it a heads-up notification
//   );


//     NotificationDetails details = NotificationDetails(
//       android: androidDetails,
//     );

//     await _localNotifications.show(
//       0, // Notification ID
//       title,
//       body,
//       details,
//     );
//   }
// }
