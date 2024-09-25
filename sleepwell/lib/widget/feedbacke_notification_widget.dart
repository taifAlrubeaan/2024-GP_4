import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/feedbacke_notification_model.dart';

class FeedbackNotificationWidget extends StatefulWidget {
  final FeedbackeNotificationModel notification;

  const FeedbackNotificationWidget({super.key, required this.notification});

  @override
  State<FeedbackNotificationWidget> createState() =>
      _FeedbackNotificationWidgetState();
}

class _FeedbackNotificationWidgetState
    extends State<FeedbackNotificationWidget> {
  RxBool isExpanded = false.obs;

  @override
  Widget build(BuildContext context) {
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
              if (widget.notification.sleepQality.isNotEmpty)
                Text("Sleep Quality IS: ${widget.notification.sleepQality}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),

              // more details
              Obx(
                () => isExpanded.value
                    ? Column(
                        children: [
                          const Divider(),
                          if (widget.notification.sleepQality == "Poor" ||
                              widget.notification.sleepQality == "Average")
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "There are reasons for your sleep:",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 92, 221, 169)),
                                ),

                                // Reasons
                                if (widget.notification.reasons.isNotEmpty)
                                  ...widget.notification.reasons.map(
                                    (reason) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text("• "),
                                          Expanded(child: Text(reason)),
                                        ],
                                      ),
                                    ),
                                  ),
                                const Divider(
                                    color: Color.fromRGBO(9, 238, 13, 1)),
                                // Recommendations
                                const Text(
                                  "Recommendations for improvement:",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 92, 221, 169)),
                                ),
                                if (widget
                                    .notification.recommendations.isNotEmpty)
                                  ...widget.notification.recommendations.map(
                                    (recommendation) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text("• "),
                                          Expanded(child: Text(recommendation)),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              const Divider(color: Color.fromRGBO(9, 238, 13, 1)),

              // bottom buttons
              const SizedBox(height: 5),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Divider(thickness: 0.4, height: 2),
              ),

              SizedBox(
                height: 35,
                child: Row(
                  children: [
                    // show/hide details button
                    Icon(Icons.access_time, size: 22, color: Colors.grey[600]),
                    const SizedBox(width: 10),
                    Text(
                        "Timestamp: ${widget.notification.timestamp.toDate()}"),

                    Obx(
                      () => Card(
                        elevation: 1.8,
                        child: IconButton(
                          tooltip: "Show more details",
                          style: IconButton.styleFrom(padding: EdgeInsets.zero),
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
                    ),
                  ],
                ),
              ),

              // const Divider(color: Color.fromRGBO(9, 238, 13, 1)),

              // bottom buttons
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}
