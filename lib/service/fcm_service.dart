import 'dart:io';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:job_apply_hub/Screens/splash_screen.dart';
import 'package:job_apply_hub/widgets/global_navigator_key.dart';

class FcmService {
  FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =FlutterLocalNotificationsPlugin();

  void requestNotificationPermission()async{

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true
    );

    if(settings.authorizationStatus == AuthorizationStatus.authorized ){
      print('User Granted Permission');
    }else if(settings.authorizationStatus == AuthorizationStatus.provisional){

    }else{

      AppSettings.openAppSettings(type: AppSettingsType.notification);
    }
  }
/// Subscribes the device to topics like 'news' and 'job'
   Future<void> subscribeToTopics() async {
    try {
      await _messaging.subscribeToTopic('news');
      await _messaging.subscribeToTopic('job');
      print("Subscribed to 'news' and 'job' topics successfully.");
    } catch (e) {
      print("Error subscribing to topics: $e");
    }
  }

 void initLocalNotification(BuildContext context,RemoteMessage message)async{
  var androidInitializationSettings =AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(
    android: androidInitializationSettings
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
    onDidReceiveNotificationResponse: (payload){
       
    }
    );
 }

  void firebaseInit(BuildContext context) async{
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleMessage(context, message);
    });

    // Handle initial notification when the app is launched from a terminated state
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      handleMessage(context, initialMessage);
    }
    FirebaseMessaging.onMessage.listen((message) {

      if (Platform.isAndroid) {
        initLocalNotification(context, message);
        showNotification(message);
      }
    });
  } 

  Future<void> showNotification(RemoteMessage message)async{
  await createNotificationChannel();
AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Channel',
  importance: Importance.max,

   
   );
AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
  channel.id,
   channel.name.toString(),
   channelDescription: 'your channel description',
   importance: Importance.high,
   priority: Priority.high,
   ticker: 'ticker'
   );

   NotificationDetails notificationDetails = NotificationDetails(
    android: androidNotificationDetails
   );
   Future.delayed(Duration.zero,(){_flutterLocalNotificationsPlugin.show(
    0,
    message.notification!.title.toString(),
    message.notification!.body.toString(),
    notificationDetails);
    });
  }

 Future<String> getDeviceToken()async{
  String? token  = await  _messaging.getToken();
  return token!;
 }
  
  void handleMessage(BuildContext context,RemoteMessage message){
final String? notificationType = message.data['type'];
    _navigateToSplashScreen(context, notificationType);

  }

  static void _navigateToSplashScreen(BuildContext context, String? notificationType) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(
          builder: (context) => SplashScreen(notificationType: notificationType),
        ),
      );
    });
  }


  Future<void> createNotificationChannel() async {
  if (Platform.isAndroid) {
    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // This must match the ID defined in the manifest
      'High Importance Channel',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    // Register the channel with the system
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
}

}