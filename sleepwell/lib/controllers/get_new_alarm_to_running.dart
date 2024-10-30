import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/alarm_model.dart';

class GetNewAlarmToRunning {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<AlarmModelData>> fetchTodayAlarms(String userId) async {
    final now = DateTime.now();
    final DateTime todayStart = DateTime(now.year, now.month, now.day);
    final DateTime todayEnd = todayStart
        .add(const Duration(days: 1))
        .subtract(const Duration(seconds: 1));

    QuerySnapshot querySnapshot = await firestore
        .collection('alarms')
        .where('uid', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: todayStart)
        .where('timestamp', isLessThanOrEqualTo: todayEnd)
        .get();

    print(
        "---- Alarms for Today (${todayStart.toLocal()} to ${todayEnd.toLocal()}) ----");

    querySnapshot.docs.forEach((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = data['timestamp']
          ?.toDate(); // Assuming 'timestamp' is a Timestamp object from Firestore
      if (timestamp != null) {
        print('Document ID: ${doc.id}');
        print('Data: $data');
        print('Timestamp: $timestamp');
        print('---------------------------------------------');
      }
    });

    return querySnapshot.docs
        .map((doc) =>
            AlarmModelData.fromFirestore(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
