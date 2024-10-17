import 'dart:async';
import 'dart:developer';
import 'package:alarm/alarm.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // استيراد مكتبة intl لتحليل الوقت
import 'package:sleepwell/main.dart';
import 'package:sleepwell/push_notification_service.dart';

import '../../controllers/beneficiary_controller.dart';
import '../feedback/feedback_page.dart';
import '../home_screen.dart';

class AlarmRingScreen extends StatefulWidget {
  final AlarmSettings alarmSettings;

  const AlarmRingScreen({
    super.key,
    required this.alarmSettings,
  });

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen> {
  String beneficiaryName = 'Unknown'; // تعيين قيمة افتراضية
  final BeneficiaryController controller = Get.find();
  late RxString beneficiaryId = ''.obs;
  String? selectedBeneficiaryId;
  bool? isForBeneficiary = true;

  @override
  void initState() {
    super.initState();

    selectedBeneficiaryId = controller.selectedBeneficiaryId.value;

    if (selectedBeneficiaryId != null && selectedBeneficiaryId!.isNotEmpty) {
      isForBeneficiary = false;
      beneficiaryId.value = selectedBeneficiaryId!;
      getBeneficiariesName(beneficiaryId.value);
    }

    log('beneficiaryId: $selectedBeneficiaryId');
  }

  // دالة لتحليل الوقت بشكل صحيح باستخدام intl
  DateTime? parseTimeString(String timeString) {
    try {
      DateFormat format = DateFormat.jm(); // تحليل صيغة "5:24 PM"
      return format.parse(timeString);
    } catch (e) {
      print('Error parsing time string: $e');
      return null;
    }
  }

  Future<void> getBeneficiariesName(String beneficiaryId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('beneficiaries')
          .doc(beneficiaryId)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          beneficiaryName = docSnapshot['name'] ??
              'No Name'; // تعيين قيمة افتراضية إذا لم يوجد الاسم
        });
        log('Beneficiary Name: $beneficiaryName');
      } else {
        log('No beneficiary found for ID: $beneficiaryId');
      }
    } catch (e) {
      log('Error fetching beneficiary name: $e');
    }
  }

  // دالة لإعادة تعيين القيم إلى الافتراضية بعد رنين المنبه
  void resetBeneficiaryInfo() {
    setState(() {
      beneficiaryName = 'Unknown';
      beneficiaryId.value = '';
      selectedBeneficiaryId = null;
      isForBeneficiary = true; // إعادة تعيين حالة المستفيد
    });
    log('Beneficiary info has been reset');
  }

  @override
  Widget build(BuildContext context) {
    final String title = isForBeneficiary!
        ? "Ringing...\nOptimal time to WAKE UP for Yourself"
        : "Ringing...\nOptimal time to WAKE UP for $beneficiaryName";

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Text("🔔", style: TextStyle(fontSize: 50)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RawMaterialButton(
                  onPressed: () {
                    final now = DateTime.now();
                    int snooze = prefs.getInt("snooze") ?? 1;
                    Alarm.set(
                      alarmSettings: widget.alarmSettings.copyWith(
                        dateTime: now.add(Duration(minutes: snooze)),
                      ),
                    ).then((_) => Navigator.pop(context));
                  },
                  child: Text(
                    "Snooze",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                RawMaterialButton(
                  onPressed: () async {
                    if (isForBeneficiary!) {
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
                                  Alarm.stop(widget.alarmSettings.id).then(
                                      (_) => Navigator.pop(context, false));
                                  await PushNotificationService
                                      .showNotification(
                                    title: 'Daily Feedback',
                                    body: 'You must give your feedback now',
                                    schedule: true,
                                    interval: 3600,
                                    actionButtons: [
                                      NotificationActionButton(
                                          key: 'Feedback',
                                          label: 'Go To Feedback Now')
                                    ],
                                  );
                                },
                              ),
                              TextButton(
                                child: const Text('Yes'),
                                onPressed: () {
                                  Alarm.stop(widget.alarmSettings.id).then(
                                      (_) => Navigator.pop(context, true));
                                },
                              ),
                            ],
                          );
                        },
                      );

                      if (shouldShowFeedbackDialog ?? false) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const FeedbackPage()),
                        );
                      }
                    } else {
                      Alarm.stop(widget.alarmSettings.id).then((_) {
                        resetBeneficiaryInfo(); // إعادة تعيين بيانات المستفيد
                        Get.delete<
                            BeneficiaryController>(); // حذف controller من الذاكرة
                        Get.offAll(const HomeScreen());
                      });
                    }
                  },
                  child: Text(
                    "Stop",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
