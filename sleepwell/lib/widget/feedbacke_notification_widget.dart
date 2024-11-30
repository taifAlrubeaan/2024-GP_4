 import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../models/feedbacke_notification_model.dart';
import '../controllers/notifications/feedbacke_notification_controllerl.dart';
 
class FeedbackNotificationWidget extends StatelessWidget {
  final FeedbackeNotificationModel notification;
  final String docId;

  FeedbackNotificationWidget({
    super.key,
    required this.notification,
    required this.docId,
  });

  final RxBool isExpanded = false.obs;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FeedbackeNotificationController>();

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.only(top: 16, right: 16, left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (notification.sleepQality.isNotEmpty)
                Text(
                  "Sleep Quality: ${notification.sleepQality}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              Obx(
                () => isExpanded.value
                    ? Column(
                        children: [
                          const Divider(),
                          if (notification.sleepQality == "Poor" ||
                              notification.sleepQality == "Average")
                            _buildReasonsAndRecommendations(),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              const Divider(color: Colors.green),
              Row(
                children: [
                  Icon(Icons.access_time, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      "Timestamp: ${DateFormat('yyyy-MM-dd hh:mm a').format(notification.timestamp.toDate())}",
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Obx(
                    () => IconButton(
                      tooltip: "Show more details",
                      onPressed: () {
                        isExpanded.value = !isExpanded.value;
                      },
                      icon: Icon(
                        isExpanded.value
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: "Delete notification",
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteConfirmation(controller, docId);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReasonsAndRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Reasons for your sleep quality:",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        if (notification.reasons.isNotEmpty)
          ...notification.reasons.map(
            (reason) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("• "),
                  Expanded(child: Text(reason)),
                ],
              ),
            ),
          ),
        const Divider(color: Colors.green),
        const Text(
          "Recommendations for improvement:",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        if (notification.recommendations.isNotEmpty)
          ...notification.recommendations.map(
            (recommendation) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("• "),
                  Expanded(child: Text(recommendation)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showDeleteConfirmation(
      FeedbackeNotificationController controller, String docId) {
    Get.defaultDialog(
      title: "Delete Notification",
      middleText: "Are you sure you want to delete this notification?",
      textCancel: "Cancel",
      textConfirm: "Delete",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        await controller.deleteNotification(docId);
      },
    );
  }
}
