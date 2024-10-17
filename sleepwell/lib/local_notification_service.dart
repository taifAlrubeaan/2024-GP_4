// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class LocalNotificationService {
//   late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

//   LocalNotificationService._() {
//     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//   }

//   static LocalNotificationService? _instance;

//   // Getter to provide access to the single instance of the class
//   static LocalNotificationService get instance =>
//       _instance ??= LocalNotificationService._();

//   /// initialize the service. call this function just once in your app
//   Future<void> initialize([String? defaultIcon]) async {
//     print("::::::::::::::::::::: initialize Local Notification Service");

//     AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings(defaultIcon ?? '@mipmap/ic_launcher');

//     InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);

//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }

//   /// function to show notification
//   void showLocalNotification(int uniqueId, String title, String body) {
//     print("::::::::::::::::::::: show Local Notification");

//     const AndroidNotificationDetails androidNotificationDetails =
//         AndroidNotificationDetails(
//       'public volunteer channel',
//       'Volunteer app notification',
//       channelDescription: 'This channel is used for important notifications.',
//       importance: Importance.max,
//       priority: Priority.high,
//       ticker: 'ticker',
//       enableVibration: true,
//       playSound: true,
//       // if true the user can't delete the notification unless click on it
//       ongoing: false,
//     );

//     flutterLocalNotificationsPlugin.show(
//       uniqueId,
//       title,
//       body,
//       const NotificationDetails(android: androidNotificationDetails),
//     );
//   }
// }
