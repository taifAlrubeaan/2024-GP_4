import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sleepwell/main.dart';

// class UserTypeClass {
//   static String? get userType => prefs.getString('userType');

//   static set userType(String? type) =>
//       prefs.setString('userType', type ?? 'Guest');

//   static void deleteUserType() => prefs.remove('userType');
// }

class AppNotifications {
  static const _publicTopic = "public_notification";
  static void subscribeToPublicNotification() {
    prefs.setBool('subscribe_public_notification', true);
    FirebaseMessaging.instance.subscribeToTopic(_publicTopic);
  }

  static void unsubscribeToPublicNotification() {
    prefs.setBool('subscribe_public_notification', false);
    FirebaseMessaging.instance.unsubscribeFromTopic(_publicTopic);
  }

  static bool? get isUserSubscribeToPublicNotification =>
      prefs.getBool('subscribe_public_notification');
}
