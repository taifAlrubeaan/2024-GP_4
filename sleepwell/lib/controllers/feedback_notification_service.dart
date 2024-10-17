// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sleepwell/push_notification_service.dart';
import 'package:sleepwell/models/feedbacke_notification_model.dart';

class FeedbackNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<FeedbackeNotificationModel>> fetchWeeklyNotifications(
      String userId) async {
    DateTime now = DateTime.now();
    DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));

    QuerySnapshot feedbackSnapshot = await _firestore
        .collection('feedback')
        .where('UserId', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: sevenDaysAgo)
        .get();

    return feedbackSnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return FeedbackeNotificationModel.fromMap(data);
    }).toList();
  }

// تعديل دالة التخزين لتشمل الأسباب المتكررة والتوصيات الخاصة بها
  Future<void> _storeWeeklyNotification({
    required String userId,
    required DateTime date,
    required Map<String, int> reasons,
    required List<Map<String, String>>
        repeatedReasonsWithRecommendations, // قائمة جديدة
  }) async {
    await _firestore.collection('weeklyNotifications').add({
      'userId': userId,
      'date': date,
      'reasons': reasons, // تخزين كل سبب وعدد مرات تكراره
      'repeatedReasonsWithRecommendations':
          repeatedReasonsWithRecommendations, // تخزين الأسباب والتوصيات
    });
  }

// التعديل على دالة sendWeeklyNotification لتخزين القيم المتكررة مع التوصيات
  Future<void> sendWeeklyNotification(String userId) async {
    // جلب البيانات من Firebase للأيام السبعة الماضية
    DateTime now = DateTime.now();
    DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));

    QuerySnapshot feedbackSnapshot = await _firestore
        .collection('feedback')
        .where('UserId', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: sevenDaysAgo)
        .get();

    List<DocumentSnapshot> feedbackDocs = feedbackSnapshot.docs;

    // التحقق من تكرار الأسباب للأيام السبعة الماضية
    Map<String, int> reasonCount = {
      'Caffeine': 0,
      'Stress': 0,
      'Nicotine': 0,
      'Blue light': 0,
      'Noise': 0,
      'Extreme Temp': 0,
      'Eating': 0,
    };

    // تحليل البيانات
    for (var doc in feedbackDocs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String sleepQuality = data['sleepQuality'];

      // التحقق إذا كانت جودة النوم Poor أو Average
      if (sleepQuality == 'Poor' || sleepQuality == 'Average') {
        List<String> answers = List<String>.from(data['answers']);

        // التحقق من إجابات المستخدم وإحصاء التكرار
        if (answers[0] == 'Yes') {
          reasonCount['Stress'] = (reasonCount['Stress'] ?? 0) + 1;
        }
        if (answers[1] == 'Yes') {
          reasonCount['Nicotine'] = (reasonCount['Nicotine'] ?? 0) + 1;
        }
        if (answers[2] == 'Yes') {
          reasonCount['Blue light'] = (reasonCount['Blue light'] ?? 0) + 1;
        }
        if (answers[3] == 'Noisy') {
          reasonCount['Noise'] = (reasonCount['Noise'] ?? 0) + 1;
        }
        if (answers[4] == 'Hot' || answers[4] == 'Cold') {
          reasonCount['Extreme Temp'] = (reasonCount['Extreme Temp'] ?? 0) + 1;
        }
        if (answers[5] == 'Yes') {
          reasonCount['Caffeine'] = (reasonCount['Caffeine'] ?? 0) + 1;
        }
        if (answers[6] == 'Yes') {
          reasonCount['Eating'] = (reasonCount['Eating'] ?? 0) + 1;
        }
      }
    }

    // جمع الأسباب التي تكررت 3 مرات أو أكثر مع التوصيات
    List<Map<String, String>> repeatedReasonsWithRecommendations = [];
    reasonCount.forEach((reason, count) {
      if (count >= 3) {
        String recommendation = _getRecommendationMessage(reason);
        repeatedReasonsWithRecommendations.add({
          'reason': reason,
          'recommendation': recommendation,
        });
      }
    });

    // إرسال إشعار بناءً على الأسباب المتكررة
    if (repeatedReasonsWithRecommendations.isNotEmpty) {
      String reasonsMessage =
          'A set of factors that may be causing your sleep disturbance:\n';

      for (var entry in repeatedReasonsWithRecommendations) {
        reasonsMessage += '- ${entry['reason']}: ${entry['recommendation']}\n';
      }

      await _sendNotification(reasonsMessage);

      // تخزين الإشعار في Firebase
      await _storeWeeklyNotification(
        userId: userId,
        date: now,
        reasons: reasonCount,
        repeatedReasonsWithRecommendations:
            repeatedReasonsWithRecommendations, // تخزين الأسباب المتكررة مع التوصيات
      );
    }
  }

  // دالة توليد رسالة التوصية بناءً على السبب المتكرر
  String _getRecommendationMessage(String reason) {
    switch (reason) {
      case 'Caffeine':
        return 'We’ve noticed that in the last week you’ve been consuming caffeine before bedtime which affects the quality of your sleep. Try to avoid it for more healthy sleep!';
      case 'Stress':
        return 'In the last week, you\'ve been under stress. Try to relax before bedtime and take some time to unwind with a calming activity.';
      case 'Nicotine':
        return 'During the week, you consumed nicotine. Try to set specific limits for yourself and consider incorporating breaks to give your body a rest.';
      case 'Blue light':
        return 'During the week, you were exposed to blue light from screens, so it\'s important to take steps to reduce its impact on your health.';
      case 'Noise':
        return 'During the week, you experienced noise and an unquiet environment. It\'s essential to find ways to manage it for your well-being.';
      case 'Extreme Temp':
        return 'During the week, you experienced extreme temperatures, whether hot or cold, which can disrupt your sleep.';
      case 'Eating':
        return 'During the week, you ate food right before bedtime, which can negatively impact your sleep.';
      default:
        return '';
    }
  }

  // دالة إرسال الإشعار
  Future<void> _sendNotification(String message) async {
    await PushNotificationService.showNotification(
      title: 'Weekly Sleep Feedback',
      body: message,
      schedule: true,
      interval: 60,
      actionButtons: [
        NotificationActionButton(
            key: 'WeeklyNotification',
            label: 'Go To Weekly Notification Screen')
      ],
    );
  }
}
