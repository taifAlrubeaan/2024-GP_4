import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleepwell/screens/alarm/alarm_setup_screen.dart';
import 'package:sleepwell/screens/feedback/feedback_page.dart';
import 'package:sleepwell/screens/feedback/notifications/feedback_notification_daily_screen.dart';
import 'package:sleepwell/screens/feedback/notifications/feedback_notification_weekly_screen.dart';

import 'screens/home_screen.dart';

class PushNotificationService {
  static Future<void> initializeNotifications() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'hight_basic_channel',
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          onlyAlertOnce: true,
          playSound: true,
          criticalAlerts: true,
        )
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'hight_basic_channel',
          channelGroupName: 'Group1',
        )
      ],
      debug: true,
    );

    await AwesomeNotifications().isNotificationAllowed().then(
      (isAllowed) async {
        if (!isAllowed) {
          await AwesomeNotifications().requestPermissionToSendNotifications();
        }
      },
    );
    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
    );
  }

  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // debugPrint('onActionReceivedMethod');
    final payload = receivedAction.payload ?? {};
    if (payload["navigate"] == true) {
      Get.to(AlarmSetupScreen());
    }
    if (receivedAction.buttonKeyPressed == 'FeedBak') {
      Get.offAll(const FeedbackPage());
    } else if (receivedAction.buttonKeyPressed == 'DailyNotification') {
      Get.to(const FeedbackNotificationDailyScreen());
    } else if (receivedAction.buttonKeyPressed == 'WeeklyNotification') {
      Get.to(const FeedbackNotificationWeeklyScreen());
    } else {
      // Navigate or perform some action
      Get.to(const HomeScreen()); // Example of navigation
    }
  }

  static Future<void> onDismissActionReceivedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('onDismissActionReceivedMethod');
  }

  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('onNotificationCreatedMethod');
  }

  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('onNotificationDisplayedMethod');
  }

  static Future<void> showNotification({
    required final String title,
    required final String body,
    final String? summary,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout notificationLayout = NotificationLayout.Default,
    final NotificationCategory? category,
    final String? bigPicture,
    final List<NotificationActionButton>? actionButtons,
    final bool schedule = false, // Set default to false
    final int? interval,
  }) async {
    int? actualInterval = interval;
    if (schedule && actualInterval == null) {
      actualInterval = 60; // Default interval value in seconds
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: -1,
        channelKey: 'basic_channel',
        title: title,
        body: body,
        actionType: actionType,
        notificationLayout: notificationLayout,
        summary: summary,
        category: category,
        payload: payload,
        bigPicture: bigPicture,
      ),
      actionButtons: actionButtons,
      schedule: schedule
          ? NotificationInterval(
              interval: (actualInterval! + 10 > 5)
                  ? actualInterval + 10
                  : 6, // Set a default minimum value
              timeZone:
                  await AwesomeNotifications().getLocalTimeZoneIdentifier(),
              preciseAlarm: true,
            )
          : null,
    );
  }

  static Future<void> showNotificationWithReasonsAndRecommendations({
    required final String title,
    // required final String body,
    required final List<String> reasons,
    required final List<String> recommendations,
    final String? summary,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout notificationLayout = NotificationLayout.Default,
    final NotificationCategory? category,
    final String? bigPicture,
    final List<NotificationActionButton>? actionButton,
    final bool schedule = false,
    final int? interval,
  }) async {
    // تنسيق الأسباب والنصائح
    String reasonsText = reasons.isNotEmpty
        ? "\nYour sleep was not good, it could be due to the following reasons:\n${reasons.map((reason) => "- $reason").join("\n")}"
        : '';

    String recommendationsText = recommendations.isNotEmpty
        ? "\nHere are some tips to consider for better sleep:\n${recommendations.map((recommendation) => "- $recommendation").join("\n")}"
        : '';

    // دمج النصوص لعرضها داخل الإشعار
    // String completeBody = body + reasonsText + recommendationsText;
    String completeBody = reasonsText + recommendationsText;

    // عرض الإشعار
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: -1,
        channelKey: 'basic_channel',
        title: title,
        body: completeBody,
        actionType: actionType,
        notificationLayout: notificationLayout,
        summary: summary,
        category: category,
        payload: payload,
        bigPicture: bigPicture,
      ),
      actionButtons: actionButton,
      schedule: schedule
          ? NotificationInterval(
              interval: interval ?? 60,
              timeZone:
                  await AwesomeNotifications().getLocalTimeZoneIdentifier(),
              preciseAlarm: true,
            )
          : null,
    );
  }

  static Future<void> scheduleBedtimeNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final int? hour = prefs.getInt('bedtime_hour');
    final int? minute = prefs.getInt('bedtime_minute');
    if (hour != null && minute != null) {
      final now = DateTime.now();
      final bedtime = DateTime(now.year, now.month, now.day, hour, minute);
      final interval = bedtime.difference(now).inSeconds;

      await PushNotificationService.showNotification(
        title: 'Bed Time Reminder',
        body: 'It\'s time to go to bed',
        schedule: true,
        interval: interval > 0
            ? interval
            : interval + 86400, // 86400 seconds in a day
        // actionButtons: [
        //   NotificationActionButton(
        //     key: 'MARK_DONE',
        //     label: 'Mark as Done',
        //     // Add other properties if needed, like autoDismissible
        //   ),
        // ],
      );
    }
  }
}
