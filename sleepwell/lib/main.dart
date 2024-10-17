import 'package:alarm/alarm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleepwell/controllers/beneficiary_controller.dart';
import 'package:sleepwell/firebase_options.dart';
import 'package:sleepwell/screens/home_screen.dart';
import 'package:sleepwell/screens/splash_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:sleepwell/push_notification_service.dart';
import 'locale/app_translation.dart';
import 'locale/local_controller.dart';

// fcm_token
// too1423too@gmail.com
late SharedPreferences prefs;
String? selectedBeneficiaryId;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  tz.initializeTimeZones();
  PushNotificationService.initializeNotifications();
  // FeedbackNotificationService.sendWeeklyNotification();
  // GetX local storege
  //await GetStorage.init();
  // Get.put(BeneficiaryController());
  prefs = await SharedPreferences.getInstance();
  // initialize  Alarm
  await Alarm.init(showDebugLogs: true);
  runApp(const MainAppScreen());
}

Future<void> getToken() async {
  final token = await FirebaseMessaging.instance.getToken();
  print("=======================================================");
  print(token);
  print("=======================================================");
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
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => AppLocalelcontroller(), fenix: true);
    final AppLocalelcontroller locallcontroller = Get.find();
    bool loginStatus = prefs.getBool("isLogin") ?? false;
    return GetMaterialApp(
      title: 'SleepWell',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false, translations: AppTranslation(),
      locale: locallcontroller.language,
      home: loginStatus ? const HomeScreen() : const SplashScreen(),
      // home: const SplashScreen(),
    );
  }
}
