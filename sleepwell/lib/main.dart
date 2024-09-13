// import 'dart:convert';
import 'package:alarm/alarm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleepwell/firebase_options.dart';
import 'package:sleepwell/screens/dashboard_screen.dart';
import 'package:sleepwell/screens/home_screen.dart';
import 'package:sleepwell/screens/splash_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:sleepwell/push_notification_service.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");

  //call awesomenotification to how the push notification.
  AwesomeNotifications().createNotificationFromJsonData(message.data);
}

late SharedPreferences prefs;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  tz.initializeTimeZones();
  PushNotificationService.initializeNotifications();

  // GetX local storege
  //await GetStorage.init();
  prefs = await SharedPreferences.getInstance();
  // initialize  Alarm
  await Alarm.init(showDebugLogs: true);
  runApp(const MainAppScreen());
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
    // getToken();
    // runNotificationListening();
    // if (AppNotifications.isUserSubscribeToPublicNotification == null) {
    //   AppNotifications.subscribeToPublicNotification();
    // }

    //  AwesomeNotifications().isNotificationAllowed().then(isAllowed);
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
      home: loginStatus ? const HomeScreen() : const SplashScreen(),
      // home: DashboardScreen(),
      // home: HomeScreen(),
      // sleep@gmail.com
      // S1234567
    );
  }
}
