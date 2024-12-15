import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  

  /// Saves the FCM token to Firestore
  static Future<void> saveTokenToFirestore(String userId, String? token) async {
    if (token == null) return;

    try {
      // Reference the user's document in Firestore
      final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

      // Set the FCM token with merge: true to prevent overwriting existing data
      await userDoc.set({'fcmToken': token}, SetOptions(merge: true));

      print("FCM Token saved to Firestore for user: $userId");
    } catch (e) {
      print("Error saving FCM Token to Firestore: $e");
    }
  }

  /// Initializes Firebase Cloud Messaging and saves token
  static Future<void> initialize(BuildContext context) async {
    // Request notification permissions
    await _requestPermission();

    // Initialize local notifications
    await _initializeLocalNotifications(context);

    // Get the current user ID from Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("No user signed in");
      return;
    }

    // Get the FCM Token
    String? token = await _messaging.getToken();
    print("FCM Token: $token");

    // Save the FCM token to Firestore
    await saveTokenToFirestore(user.uid, token);

    // Listen for token refresh and update it in Firestore
    _messaging.onTokenRefresh.listen((newToken) async {
      print("New FCM Token: $newToken");
      await saveTokenToFirestore(user.uid, newToken);
    });
  }

  /// Pre-creates the user document in Firestore if it doesn't exist
  static Future<void> createUserDocument(String userId, String email) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      await userDoc.set({
        'email': email,
        'fcmToken': null, // Will be updated later
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Ensures no overwriting if the doc exists

      print("User document created/updated for user: $userId");
    } catch (e) {
      print("Error creating user document: $e");
    }
  }

  /// Requests notification permissions from the user
  static Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User granted notification permissions.");
    } else {
      print("User declined notification permissions.");
    }
  }

  /// Initializes local notifications
  /// Initializes local notifications
static Future<void> _initializeLocalNotifications(BuildContext context) async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings settings = InitializationSettings(
    android: androidSettings,
  );

  await _localNotifications.initialize(
    settings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Parse the payload (custom data sent with the notification)
      if (response.payload != null) {
        final Map<String, dynamic> payloadData = _parsePayload(response.payload!);

        // Check the notification type and handle redirection
        final String? type = payloadData['type'];
        if (type == 'job') {
          print("Redirecting to Job page.");
          // Navigate to Job Page
          // _navigateToJobPage(context);
          
        } else if (type == 'news') {
          print("Redirecting to News page.");
          // Navigate to News Page
          _navigateToNewsPage(context);
        } else {
          print("Unknown notification type: $type");
          // Handle other types or fallback
          _navigateToDefaultPage(context);
        }
      } else {
        print("Notification clicked with no payload.");
      }
    },
  );
}

/// Parse the payload into a Map
static Map<String, dynamic> _parsePayload(String payload) {
  try {
    return Map<String, dynamic>.from(jsonDecode(payload));
  } catch (e) {
    print("Error parsing payload: $e");
    return {};
  }
}

/// Navigate to Job Page
static void _navigateToJobPage(BuildContext context) {
  // Example: Add your navigation logic here
   Navigator.pushNamed(context, '/jobPortal');
  print("Navigating to Job Page...");
}

/// Navigate to News Page
static void _navigateToNewsPage(BuildContext context) {
  // Example: Add your navigation logic here
   Navigator.pushNamed(context, '/newsPage');
  print("Navigating to News Page...");
}

/// Navigate to Default Page
static void _navigateToDefaultPage(BuildContext context) {
  // Example: Add your fallback navigation logic here
   Navigator.pushNamed(context, '/home');
  print("Navigating to Default Page...");
}


  /// Shows a local notification
  static Future<void> _showNotification(String? title, String? body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      channelDescription: 'This is the default channel for notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      0, // Notification ID
      title,
      body,
      details,
    );
  }
}
