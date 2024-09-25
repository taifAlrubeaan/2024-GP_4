import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/feedbacke_notification_controllerl.dart';
import '../../../models/feedbacke_notification_model.dart';
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
  String userid = 'Fz74uTkiBpSqt7zdF3C3ZTPjbhu1';

  @override
  void initState() {
    super.initState();
    // استدعاء البيانات مرة واحدة في initState
    notificationsController.fetchNotifications(userid);
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
        child: FutureBuilder(
          future: notificationsController.fetchNotifications(userid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.connectionState == ConnectionState.done &&
                notificationsController.notifications.isEmpty) {
              return RefreshIndicator(
                onRefresh: () =>
                    notificationsController.fetchNotifications(userid),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    height: Get.height - Get.mediaQuery.viewPadding.top - 150,
                    alignment: Alignment.center,
                    child: const Text(
                        "No notifications found, or you have no internet connection."),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  notificationsController.fetchNotifications(userid),
              child: Obx(
                () => ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    FeedbackeNotificationModel notification =
                        notificationsController.notifications[index];

                    return FeedbackNotificationWidget(
                        notification: notification);
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 15),
                  itemCount: notificationsController.notifications.length,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
