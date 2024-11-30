import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/notifications/feedbacke_notification_controllerl.dart';
import '../../../widget/feedbacke_notification_widget.dart';

class FeedbackNotificationDailyScreen extends StatefulWidget {
  const FeedbackNotificationDailyScreen({super.key});

  @override
  State<FeedbackNotificationDailyScreen> createState() =>
      _FeedbackNotificationDailyScreenState();
}

class _FeedbackNotificationDailyScreenState
    extends State<FeedbackNotificationDailyScreen> {
  final notificationsController = Get.put(FeedbackeNotificationController());
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
    notificationsController.fetchNotifications(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF004AAD),
        elevation: 50,
        title: const Text(
          'Notifications Daily',
          style: TextStyle(color: Colors.white),
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
        child: GetBuilder<FeedbackeNotificationController>(
          init: FeedbackeNotificationController(),
          builder: (controller) {
            controller.fetchNotifications(userId);
            // if (controller.isLoading.value) {
            //   controller.fetchNotifications(userId);
            //   return const Center(child: CircularProgressIndicator());
            // }
            // Show loading indicator if notifications list is empty
            if (controller.notifications.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => controller.fetchNotifications(userId),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    height: MediaQuery.of(context).size.height -
                        AppBar().preferredSize.height -
                        Get.mediaQuery.padding.top,
                    alignment: Alignment.center,
                    child: const Text(
                      "No notifications found, \n or you have no internet connection.",
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }

            // Display list of notifications
            return RefreshIndicator(
              onRefresh: () => controller.fetchNotifications(userId),
              child: ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemBuilder: (context, index) {
                  final notification = controller.notifications[index];
                  return FeedbackNotificationWidget(
                    notification: notification,
                    docId:
                        notification.id, // Ensure `id` is the correct property
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 15),
                itemCount: controller.notifications.length,
              ),
            );
          },
        ),
      ),
    );
  }
}
