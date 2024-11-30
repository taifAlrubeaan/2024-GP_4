import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackeNotificationModel {
  final String id;
  final String userId;
  final String sleepQality;
  final List<String> reasons;
  final List<String> answers;
  final List<String> recommendations;
  final Timestamp timestamp;

  FeedbackeNotificationModel({
    required this.id,
    required this.userId,
    required this.sleepQality,
    required this.answers,
    required this.reasons,
    required this.recommendations,
    required this.timestamp,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'UserId': userId,
      'sleepQuality': sleepQality,
      'answers': answers,
      'reasons': reasons,
      'recommendations': recommendations,
      'timestamp': timestamp,
    };
  }

  // Factory constructor to create from Firebase data
  factory FeedbackeNotificationModel.fromMap(
      Map<String, dynamic> map, String docId) {
    // print('Map data: $map');
    return FeedbackeNotificationModel(
      id: docId,
      userId: map['UserId'] ?? '',
      sleepQality: map['sleepQuality'] ?? '',
      answers: List<String>.from(map['answers'] ?? []),
      reasons: List<String>.from(map['reasons'] ?? []),
      recommendations: List<String>.from(map['recommendations'] ?? []),
      timestamp: map['timestamp'] ?? Timestamp.now(),
    );
  }

  @override
  String toString() {
    return 'FeedbackeNotificationModel(id: $id, userId: $userId, sleepQality: $sleepQality, answers: $answers, reasons: $reasons, recommendations: $recommendations, timestamp: $timestamp)';
  }
}
