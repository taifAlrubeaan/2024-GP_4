import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sleepwell/local_notification_service.dart';
import 'package:sleepwell/main.dart';
import 'package:sleepwell/screens/feedback/notifications/feedback_notification_daily_screen.dart';
import '../../controllers/feedback_notification_service.dart';

 
import 'notifications/feedback_notification_weekly_screen.dart';

class FeedbackeNotificationsScreen extends StatefulWidget {
  const FeedbackeNotificationsScreen({super.key});

  @override
  State<FeedbackeNotificationsScreen> createState() =>
      _FeedbackeNotificationsScreenState();
}

class _FeedbackeNotificationsScreenState
    extends State<FeedbackeNotificationsScreen> {
  final FeedbackNotificationService _notificationService =
      FeedbackNotificationService();
  Future<void> fetchLastSevenDaysData(String userId) async {
    // احصل على التاريخ الذي يساوي سبعة أيام مضت
    DateTime now = DateTime.now();
    DateTime sevenDaysAgo = now.subtract(Duration(days: 7));

    try {
      // قم بإجراء الاستعلام لجلب البيانات
      QuerySnapshot feedbackSnapshot = await FirebaseFirestore.instance
          .collection('feedback')
          .where('UserId', isEqualTo: userId)
          .where('timestamp',
              isGreaterThanOrEqualTo: sevenDaysAgo.millisecondsSinceEpoch)
          .orderBy('timestamp')
          .get();

      // قم بمعالجة البيانات المسترجعة
      for (var doc in feedbackSnapshot.docs) {
        print(doc.data());
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void _sendWeeklyNotification() async {
    String? userId = FirebaseAuth
        .instance.currentUser?.uid; // الحصول على UserId من Firebase Auth
    // String userId = 'Fz74uTkiBpSqt7zdF3C3ZTPjbhu1';
    if (userId != null) {
      await _notificationService.sendWeeklyNotification(userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Weekly notification sent!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF004AAD),
        elevation: 50,
        title: const Text(
          'Notifications',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF004AAD), Color(0xFF040E3B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            ListTile(
              title: const Text(
                'Notifications Daily ',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
              leading: const Icon(Icons.notifications, color: Colors.white),
              trailing: const Icon(Icons.arrow_forward_ios,
                  color: Colors.white, size: 18),
              onTap: () =>
                  Get.to(() => const FeedbackNotificationDailyScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today,
                  size: 24, color: Colors.white),
              title: const Text(' Notifications Weekly',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              trailing: const Icon(Icons.arrow_forward_ios,
                  color: Colors.white, size: 18),
              onTap: () =>
                  Get.to(() => const FeedbackNotificationWeeklyScreen()),
            ),
            TextButton(
                onPressed: _sendWeeklyNotification,
                child: const Text(
                  "Send Notification ",
                  style: TextStyle(color: Colors.white, fontSize: 22),
                )),
            ElevatedButton(
              onPressed: () async {
                List<String> reasons = [
                  "Stress and anxiety can interfere with sleep.",
                  "Nicotine is a stimulant that can disrupt sleep.",
                  "Blue light from devices can suppress melatonin production.",
                  "Noise can disrupt sleep.",
                  "Extreme temperatures can interfere with sleep.",
                  "Caffeine is a stimulant that can interfere with sleep.",
                  "Eating close to bedtime can disrupt sleep.",
                ];
                List<String> recommendations = [
                  "Practice relaxation techniques before bed.",
                  "Avoid nicotine for at least 4-6 hours before bedtime.",
                  "Avoid devices 1-2 hours before bedtime.",
                  "Create a quiet sleep environment.",
                  "Maintain a warm bedroom temperature.",
                  "Avoid caffeine for at least 4-6 hours before bedtime.",
                  "Finish eating at least 2-3 hours before bedtime.",
                ];
                String deviceToken =
                    "eHt4wVoiR46JQ2DpCVyQ1j:APA91bFIWdKZ8TuebQXAtml1U8zsR_JmaqCHhfFpGE7m7nzVyM0W7H_pUvERL9WCnXuE9J6SEaTxQDYUIQxuISfsEirPh6ZIASOFam6aYDwIc2IwT-qYBjdgK7v_SIo0yep8oopWFFJH";
                String reasonsText = reasons.isNotEmpty
                    ? "\nYour sleep was not good, it could be due to the following reasons:\n${reasons.map((reason) => "- $reason").join("\n")}"
                    : '';

                String recommendationsText = recommendations.isNotEmpty
                    ? "\n Here are some tips to consider for better sleep:\n${recommendations.map((recommendation) => "- $recommendation").join("\n")}"
                    : '';

                String completeBody = reasonsText + recommendationsText;
                // final deviceTokens =
                //     await PushNotificationServices.getToken(); // Use await here

                // PushNotificationServices.sendNotificationToSelectorUser(
                //   deviceToken, // replace with actual deviceToken
                //   context,
                //   "Sleep Analysis",
                //   completeBody,
                //   reasons,
                //   recommendations,
                // );
                // sendNotification('sendNotification', 'sendNotification');
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.lightBlue[100]),
                foregroundColor: const MaterialStatePropertyAll(Colors.white),
              ),
              child: const Text("Send"),
            ),
            ElevatedButton(
              onPressed: () {
                List<String> reasons = [
                  "Stress and anxiety can interfere with sleep.",
                  "Nicotine is a stimulant that can disrupt sleep.",
                  "Blue light from devices can suppress melatonin production.",
                  "Noise can disrupt sleep.",
                  "Extreme temperatures can interfere with sleep.",
                  "Caffeine is a stimulant that can interfere with sleep.",
                  "Eating close to bedtime can disrupt sleep.",
                ];
                List<String> recommendations = [
                  "Practice relaxation techniques before bed.",
                  "Avoid nicotine for at least 4-6 hours before bedtime.",
                  "Avoid devices 1-2 hours before bedtime.",
                  "Create a quiet sleep environment.",
                  "Maintain a warm bedroom temperature.",
                  "Avoid caffeine for at least 4-6 hours before bedtime.",
                  "Finish eating at least 2-3 hours before bedtime.",
                ];
                // PushNotificationServices.sendNotificationToDevice(
                //   title: 'تنبيه',
                //   body: 'هذا هو نص الإشعار',
                //   reasons: reasons,
                //   recommendations: recommendations,
                // );
                // final localNotification = LocalNotificationService.instance;
                // localNotification.initialize();
                // var userId = FirebaseAuth.instance.currentUser?.uid;
                // localNotification.showLocalNotification(int.parse(userId!),
                //     reasons.toString(), recommendations.toString());
              },
              child: const Text('إرسال الإشعار'),
            ),
          ],
        ),
      ),
    );
  }
}
