import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AlarmModelData {
  final String? bedtime;
  final String? wakeupTime;
  final int numOfCycles;
  final DateTime timestamp;
  final bool isForBeneficiary;

  AlarmModelData({
    required this.bedtime,
    required this.wakeupTime,
    required this.numOfCycles,
    required this.timestamp,
    required this.isForBeneficiary,
  });

  // تحويل البيانات من Firestore DocumentSnapshot إلى Alarm object
  factory AlarmModelData.fromFirestore(Map<String, dynamic> data) {
    // log(data.toString());
    String? bedtime = data['bedtime'];
    String? wakeupTime = data['wakeup_time'];

    // حساب عدد الدورات بناءً على وقت النوم ووقت الاستيقاظ
    int calculatedCycles = 0;
    if (bedtime != null && wakeupTime != null) {
      calculatedCycles = _calculateSleepCycles(bedtime, wakeupTime);
    }

    return AlarmModelData(
      bedtime: bedtime,
      wakeupTime: wakeupTime,
      numOfCycles: calculatedCycles,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isForBeneficiary: data['isForBeneficiary'],
    );
  }
  Duration get sleepDuration {
    try {
      DateTime now = DateTime.now();
      DateTime bedtimeDate = DateFormat("HH:mm a").parse(bedtime!);
      bedtimeDate = DateTime(
          now.year, now.month, now.day, bedtimeDate.hour, bedtimeDate.minute);

      DateTime optimalWakeUpDate = DateFormat("hh:mm a").parse(wakeupTime!);
      optimalWakeUpDate = DateTime(now.year, now.month, now.day,
          optimalWakeUpDate.hour, optimalWakeUpDate.minute);

      if (optimalWakeUpDate.isBefore(bedtimeDate)) {
        optimalWakeUpDate = optimalWakeUpDate.add(const Duration(days: 1));
      }

      // حساب الفرق بين وقت النوم ووقت الاستيقاظ
      return optimalWakeUpDate.difference(bedtimeDate);
    } catch (e) {
      print('Error parsing sleep duration: $e');
      return Duration.zero; // إرجاع صفر في حال حدوث خطأ
    }
  }

  double get sleepCycles {
    return double.parse(numOfCycles.toString()) ?? 0.0;
  }

  static int _calculateSleepCycles(String bedtime, String wakeUpTime) {
    const int sleepCycleMinutes = 90;

    try {
      final bedtimeParsed = _parse12HourTime(bedtime);
      final wakeUpTimeParsed = _parse12HourTime(wakeUpTime);

      int bedtimeMinutes =
          bedtimeParsed['hour']! * 60 + bedtimeParsed['minute']!;
      int wakeUpTimeMinutes =
          wakeUpTimeParsed['hour']! * 60 + wakeUpTimeParsed['minute']!;

      if (wakeUpTimeMinutes < bedtimeMinutes) {
        wakeUpTimeMinutes += 24 * 60;
      }

      int totalSleepTimeMinutes = wakeUpTimeMinutes - bedtimeMinutes;
      return totalSleepTimeMinutes ~/ sleepCycleMinutes;
    } catch (e) {
      log("Error calculating sleep cycles: $e");
      return 0;
    }
  }

  static Map<String, int> _parse12HourTime(String time) {
    // Example input: "10:30 PM"
    final parts = time.split(RegExp(r'[: ]')); // Split by colon and space
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    String period = parts[2].toUpperCase();

    // Convert to 24-hour format for calculations
    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return {'hour': hour, 'minute': minute};
  }
}
