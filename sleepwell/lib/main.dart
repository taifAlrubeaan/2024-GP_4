import 'dart:developer';
import 'package:alarm/alarm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleepwell/firebase_options.dart';
import 'package:sleepwell/screens/home_screen.dart';
import 'package:sleepwell/screens/splash_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:sleepwell/push_notification_service.dart';
import 'services/firebase_auth_service.dart';
import 'services/sensor_service.dart';
import 'package:intl/date_symbol_data_local.dart';

// too1423too@gmail.com taif1111
late SharedPreferences prefs;
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

bool loginStatus = prefs.getBool("isLogin") ?? false;
List<SensorService> runningServices = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Get.putAsync<SensorService>(() => SensorService().init(),
      permanent: true);
  FirebaseAuthService authService = FirebaseAuthService();
  await authService.setUserId();
// Add Alarm Schdualer List Of Alarm And Settings Of Sensors
  // Example: Initialize and add a sensor service to runningServices
  final sensorService = await SensorService().init();
  runningServices.add(sensorService);
  log('runningServices::::::::::::::::::::::::::::::::::::::::::::::');
  log(runningServices.toString());
  log('runningServices::::::::::::::::::::::::::::::::::::::::::::::');
  // for (var service in runningServices) {
  //   service.isSensorReading();
  // }

  // await Get.putAsync<AlarmService>(() => AlarmService().init(),
  //     permanent: true);
  // AlarmService().init();

  tz.initializeTimeZones();
  PushNotificationService.initializeNotifications();
  await initializeDateFormatting('ar', null);
  requestNotificationPermission();
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  await FirebaseMessaging.instance.subscribeToTopic("topic");
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.notification?.title}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });

  prefs = await SharedPreferences.getInstance();
  // initialize  Alarm
  await Alarm.init(showDebugLogs: true);
  // await AppAlarm.initAlarms();

  runApp(const MainAppScreen());
}

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
  print("=======================================================");
  print('Notification permission granted: ${settings.authorizationStatus}');
  print("=======================================================");
}

Future<String?> getToken() async {
  final token = await FirebaseMessaging.instance.getToken();

  print("=======================================================");
  print(token);
  print("=======================================================");
  // print(selectedBeneficiaryId);
  print("=======================================================");
  return token;
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
    runNotificationListening();

    getToken();
    FirebaseMessaging.instance
        .getToken()
        .then((token) => print("Firebase Messaging Token: $token"));

    // استماع للإشعارات أثناء فتح التطبيق
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
          'Received a message: ${message.notification?.title}, ${message.notification?.body}');
    });

    // استماع للإشعارات عند فتح التطبيق من الإشعار
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Get.lazyPut(() => AppLocalelcontroller(), fenix: false);
    // final AppLocalelcontroller locallcontroller = Get.find();
    // bool loginStatus = prefs.getBool("isLogin") ?? false;
    return GetMaterialApp(
      title: 'SleepWell',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      //  translations: AppTranslation(),
      // locale: locallcontroller.language,
      home: loginStatus ? const HomeScreen() : const SplashScreen(),
      // home: const SplashScreen(),
    );
  }
}

void runNotificationListening() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print(
        "========================== Get a message =============================");
    if (message.notification != null) {
      print('::::::::::::Get a message notification in the foreground!');
      PushNotificationService.showNotification(
        title: message.notification!.title ?? "",
        body: message.notification!.body ?? "",
        summary: 'Hellow Aimn',
      );
    }
    print("=======================================================");
  });
}
