import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackeNotificationModel {
  final String userId;
  final String sleepQality;
  final List<String> reasons;
  final List<String> answers;
  final List<String> recommendations;
  final Timestamp timestamp;

  FeedbackeNotificationModel({
    required this.userId,
    required this.sleepQality,
    required this.answers,
    required this.reasons,
    required this.recommendations,
    required this.timestamp,
  });

  // تحويل كائن إلى Map لتخزينه في فايربيس
  Map<String, dynamic> toMap() {
    return {
      'UserId': userId,
      'sleepQuality': sleepQality,
      'answers': answers,
      'reasons': reasons,
      'recommendations': recommendations,
      'timestamp': timestamp,
    };
  }

  // إنشاء كائن من Map عند استرجاع البيانات من فايربيس
  factory FeedbackeNotificationModel.fromMap(Map<String, dynamic> map) {
    return FeedbackeNotificationModel(
      userId: map['UserId'] ?? '', // تأكد من أن الحقل مطابق للفايربيس
      sleepQality: map['sleepQuality'] ?? '',
      answers: List<String>.from(
          map['answers'] ?? []), // تحويل List<dynamic> إلى List<String>
      reasons: List<String>.from(map['reasons'] ?? []),
      recommendations: List<String>.from(map['recommendations'] ?? []),
      timestamp: map['timestamp'] ?? Timestamp.now(),
    );
  }

  @override
  String toString() {
    return 'FeedbackeNotificationModel(userId: $userId, sleepQality: $sleepQality, answers: $answers, reasons: $reasons, recommendations: $recommendations, timestamp: $timestamp)';
  }
}
