import 'dart:convert';
import 'package:alarm/alarm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleepwell/firebase_options.dart';
import 'package:sleepwell/screens/dashboard_screen.dart';
import 'package:sleepwell/screens/splash_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:http/http.dart' as http;

import 'local_notification_service.dart';
import 'public_classes.dart';
// import 'screens/alarm_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

late SharedPreferences prefs;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  tz.initializeTimeZones();

  // initialize  FirebaseMessaging

  requestNotificationPermission();
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // GetX local storege
  //await GetStorage.init();
  prefs = await SharedPreferences.getInstance();
  // initialize  Alarm
  await Alarm.init(showDebugLogs: true);
  runApp(const MainAppScreen());
}

// You may set the permission requests to "provisional" which allows the user to choose what type
// of notifications they would like to receive once the user receives a notification.
Future<void> requestNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');
}

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getToken();
    runNotificationListening();
    if (AppNotifications.isUserSubscribeToPublicNotification == null) {
      AppNotifications.subscribeToPublicNotification();
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    bool loginStatus = prefs.getBool("isLogin") ?? false;
    return GetMaterialApp(
      title: 'SleepWell',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: loginStatus ? DashboardScreen() : const SplashScreen(),
      // home: DashboardScreen(),
    );
  }
}

void runNotificationListening() {
  final localNotification = LocalNotificationService.instance;
  localNotification.initialize();
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print(
        "========================== Get a message =============================");
    if (message.notification != null) {
      print('::::::::::::Get a message notification in the foreground!');
      localNotification.showLocalNotification(
        message.hashCode,
        message.notification!.title ?? "",
        message.notification!.body ?? "",
      );
    }
    print("=======================================================");
  });
  
  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   print('Got a message whilst in the foreground!');
  //   print('Message data: ${message.data}');

  //   if (message.notification != null) {
  //     print('Message also contained a notification: ${message.notification}');
  //   }
  // });
}

Future<void> getToken() async {
  final token = await FirebaseMessaging.instance.getToken();
  print("=======================================================");
  print(token);
  print("=======================================================");
}

Future<void> sendNotification(String title, String message) async {
  var headersList = {
    'Accept': '*/*',
    'Content-Type': 'application/json',
    'Authorization':
        'key=AAAAtoni7cA:APA91bG8smrjGMaG3Z5_t9gMdyE9HHIT8x190zBaCfRQOsDYiCxiCOEEoyc7_dKnOPzJ95q4A1LdkP2shvAlu7sJiUL-xIMlngfEOTRkdtoG24bRZjAziwSd09L7BEW2GQyRXwOGGIUw'
  };
  var url = Uri.parse('https://fcm.googleapis.com/fcm/send');

  var body = {
    "to":
        "f56BBhPGRl-akiM3KwnnaY:APA91bHMcYDBbIxcY7zYpAp6a9D33-3pw8l_y2hNH7swZ55pW5aZo5UYaAw2gTlUWFdcCrPYr463H5Ti-1IbX_uS-fMKHNZBTvPIsyFuRZ3Fm1gBgBQw5OgNfpiFwzptANqQuTO4dWzj",
    "notification": {
      "title": "Check this Mobile (title)",
      "body": "Rich Notification testing (body)",
      "mutable_content": true,
      "sound": "Tri-tone"
    },
  };

  var req = http.Request('POST', url);
  req.headers.addAll(headersList);
  req.body = json.encode(body);

  var res = await req.send();
  final resBody = await res.stream.bytesToString();

  if (res.statusCode >= 200 && res.statusCode < 300) {
    print(resBody);
  } else {
    print(res.reasonPhrase);
  }
}
