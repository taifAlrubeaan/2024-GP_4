import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AlarmModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  Future<Map<String, dynamic>> fetchAlarmData(
      DateTime weekStart, DateTime weekEnd) async {
    try {
      final snapshot = await _firestore
          .collection('alarms')
          .where('uid', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: weekStart)
          .where('timestamp', isLessThanOrEqualTo: weekEnd)
          .get();
      print(userId);
      print("::::::::::::::::");
      List<double> sleepHours = [];
      List<double> sleepCycles = [];

      for (var alarm in snapshot.docs) {
        String bedtimeString = alarm['bedtime'];
        String wakeupTimeString = alarm['wakeup_time'];
        String cyclesString = alarm['num_of_cycles'];

        DateTime bedtime = DateFormat('HH:mm').parse(bedtimeString);
        DateTime wakeupTime = DateFormat('HH:mm').parse(wakeupTimeString);

        if (wakeupTime.isBefore(bedtime)) {
          wakeupTime = wakeupTime.add(const Duration(days: 1));
        }

        double sleepDuration =
            wakeupTime.difference(bedtime).inHours.toDouble();
        num cycles = int.tryParse(cyclesString) ?? 0;

        sleepHours.add(sleepDuration);
        sleepCycles.add(cycles.toDouble());
      }

      double averageSleepHours = sleepHours.isNotEmpty
          ? sleepHours.reduce((a, b) => a + b) / sleepHours.length
          : 0.0;

      return {
        'sleepHours': sleepHours,
        'sleepCycles': sleepCycles,
        'averageSleepHours': averageSleepHours,
      };
    } catch (e) {
      print('Error fetching data: $e');
      return {};
    }
  }
}
