import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/alarm/alarm_list__controller.dart';
import '../../models/alarm_data.dart';
import '../../push_notification_service.dart';
import '../feedback/feedback_page.dart';
import '../home_screen.dart';
// alarm_ring_screen.dart

class AlarmRingScreen extends StatefulWidget {
  final AlarmSettings alarmSettings;
  final AlarmData alarmsData;
  AlarmRingScreen(
      {Key? key, required this.alarmSettings, required this.alarmsData})
      : super(key: key);

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen> {
  late String name;
  late bool userType;
  Timer? _reminderTimer;
  bool _showFeedbackDialog = true;

  @override
  void dispose() {
    _reminderTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // final Map<String, dynamic> alarmsData = Get.arguments ?? {};
    name = widget.alarmsData.name;
    userType = widget.alarmsData.isForBeneficiary;
  }

  @override
  Widget build(BuildContext context) {
    final AlarmListController controller = Get.put(AlarmListController());

    final String title = "Ringing...\nOptimal time to WAKE UP\n for $name";
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Text("🔔", style: TextStyle(fontSize: 50)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    DateTime now = DateTime.now();
                    Alarm.set(
                      alarmSettings: widget.alarmSettings.copyWith(
                        dateTime: now.add(const Duration(minutes: 2)),
                      ),
                    ).then((_) => Navigator.pop(context));
                  },
                  child: const Text("Snooze"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_showFeedbackDialog && userType) {
                      final shouldShowFeedbackDialog = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Daily Feedback'),
                            content: const Text(
                                'Do you want to give your feedback now?'),
                            actions: [
                              TextButton(
                                child: const Text('Remind me later'),
                                onPressed: () async {
                                  await Alarm.stop(widget.alarmSettings.id)
                                      .then(
                                          (_) => Navigator.pop(context, false));
                                  controller
                                      .deleteAlarm(widget.alarmSettings.id);

                                  await PushNotificationService
                                      .showNotification(
                                    title: 'Daily Feedback',
                                    body: 'You must  given your feedback now',
                                    schedule: true,
                                    interval: 3600,
                                    actionButtons: [
                                      NotificationActionButton(
                                          key: 'FeedBak',
                                          label: 'Go To Feedback Now')
                                    ],
                                  );
                                  Get.back(result: false);
                                  _showFeedbackDialog = false;
                                  // _startReminderTimer();
                                },
                              ),
                              TextButton(
                                child: const Text('Yes'),
                                onPressed: () async {
                                  await Alarm.stop(widget.alarmSettings.id)
                                      .then(
                                          (_) => Navigator.pop(context, false));
                                  Get.back(result: true);
                                  Get.offAll(() => const FeedbackPage());
                                },
                              ),
                            ],
                          );
                        },
                      );

                      if (shouldShowFeedbackDialog ?? false) {
                        Get.to(() => const FeedbackPage());
                      }
                    } else {
                      await Alarm.stop(widget.alarmSettings.id)
                          .then((_) => Navigator.pop(context, false));
                      controller.deleteAlarm(widget.alarmSettings.id);

                      Get.offAll(() => const HomeScreen());
                    }
                  },
                  child: const Text("Stop"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _startReminderTimer() {
    _reminderTimer = Timer(const Duration(minutes: 3), () {
      if (_showFeedbackDialog) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Daily Feedback Reminder'),
              content: const Text('Do you want to give your feedback now?'),
              actions: [
                TextButton(
                  child: const Text('Remind me later'),
                  onPressed: () {
                    Get.back(result: false);
                    _showFeedbackDialog = false;
                    _startReminderTimer();
                  },
                ),
                TextButton(
                  child: const Text('Yes'),
                  onPressed: () {
                    Get.back();
                    Get.to(() => const FeedbackPage());
                  },
                ),
              ],
            );
          },
        );
      }
    });
  }
}
