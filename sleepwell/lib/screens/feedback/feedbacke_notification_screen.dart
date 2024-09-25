import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
          ],
        ),
      ),
    );
  }
}
