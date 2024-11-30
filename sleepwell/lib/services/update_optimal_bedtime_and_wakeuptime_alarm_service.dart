import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UpdateOptimalBedtimeAndWakeAlarmService {
  Future<String> getWakeupTimeForAlarm(int alarmId) async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        log("Error: No user is logged in.");
        return '';
      }

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('alarms')
          .where('uid', isEqualTo: userId)
          .where('alarmId', isEqualTo: alarmId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        log("No alarm found for alarmId: $alarmId");
        return '';
      }

      var alarmData = querySnapshot.docs.first.data() as Map<String, dynamic>;

      if (alarmData.containsKey('optimalWakeTime')) {
        return alarmData['optimalWakeTime'] ?? '';
      } else {
        log("No optimalWakeTime found in alarm data for alarmId: $alarmId");
        return '';
      }
    } catch (e) {
      log("Error retrieving wake-up time for alarmId $alarmId: $e");
      return '';
    }
  }

  Future<int> findAlarmBySensor(String sensorId) async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        log("Error: No user is logged in.");
        return -1;
      }

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('alarms')
          .where('uid', isEqualTo: userId)
          .where('sensorId', isEqualTo: sensorId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        log("No alarm found for sensorId: $sensorId");
        return -1;
      }

      var alarmData = querySnapshot.docs.first.data() as Map<String, dynamic>;

      return alarmData['alarmId'] ?? -1;
    } catch (e) {
      log("Error finding alarm by sensorId $sensorId: $e");
      return -1;
    }
  }

//   String calculateOptimalWakeUpTime(String? bedtime, String? wakeUpTime) {
//     const int sleepCycleMinutes = 90;

//     if (bedtime == null ||
//         bedtime.isEmpty ||
//         wakeUpTime == null ||
//         wakeUpTime.isEmpty) {
//       throw ArgumentError("Bedtime or wakeUpTime is missing or null.");
//     }

//     log("Calculating with bedtime: $bedtime and wakeUpTime: $wakeUpTime");

//     try {
//       final bedtimeParsed = _parse12HourTime(bedtime);
//       final wakeUpTimeParsed = _parse12HourTime(wakeUpTime);

//       int bedtimeMinutes =
//           bedtimeParsed['hour']! * 60 + bedtimeParsed['minute']!;
//       int wakeUpTimeMinutes =
//           wakeUpTimeParsed['hour']! * 60 + wakeUpTimeParsed['minute']!;

//       if (wakeUpTimeMinutes < bedtimeMinutes) {
//         wakeUpTimeMinutes += 24 * 60;
//       }

//       int totalSleepTimeMinutes = wakeUpTimeMinutes - bedtimeMinutes;
//       int numberOfCycles = totalSleepTimeMinutes ~/ sleepCycleMinutes;
//       int optimalWakeUpMinutes =
//           bedtimeMinutes + (numberOfCycles * sleepCycleMinutes);

//       if (optimalWakeUpMinutes >= 24 * 60) {
//         optimalWakeUpMinutes -= 24 * 60;
//       }

//       return _format12HourTime(optimalWakeUpMinutes);
//     } catch (e) {
//       log("Error calculating optimal wake-up time: $e");
//       rethrow;
//     }
//   }

//   Map<String, int> _parse12HourTime(String time) {
//     // Example input: "10:30 PM"
//     final parts = time.split(RegExp(r'[: ]')); // Split by colon and space
//     int hour = int.parse(parts[0]);
//     int minute = int.parse(parts[1]);
//     String period = parts[2].toUpperCase();

//     // Convert to 24-hour format for calculations
//     if (period == 'PM' && hour != 12) {
//       hour += 12;
//     } else if (period == 'AM' && hour == 12) {
//       hour = 0;
//     }

//     return {'hour': hour, 'minute': minute};
//   }

//   String _format12HourTime(int totalMinutes) {
//     // Convert total minutes to hours and minutes
//     int hour = totalMinutes ~/ 60;
//     int minute = totalMinutes % 60;

//     // Determine AM/PM and adjust to 12-hour format
//     String period = (hour < 12) ? 'AM' : 'PM';
//     if (hour > 12) hour -= 12;
//     if (hour == 0) hour = 12;

//     // Format as "hh:mm AM/PM"
//     return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
//   }

  String calculateOptimalWakeUpTime(String? bedtime, String? wakeUpTime) {
    const int sleepCycleMinutes = 90;
    const int additionalMinutes = 15; // Quarter of an hour

    if (bedtime == null ||
        bedtime.isEmpty ||
        wakeUpTime == null ||
        wakeUpTime.isEmpty) {
      throw ArgumentError("Bedtime or wakeUpTime is missing or null.");
    }

    log("Calculating with bedtime: $bedtime and wakeUpTime: $wakeUpTime");

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
      int numberOfCycles = totalSleepTimeMinutes ~/ sleepCycleMinutes;
      int optimalWakeUpMinutes =
          bedtimeMinutes + (numberOfCycles * sleepCycleMinutes);

      if (optimalWakeUpMinutes >= 24 * 60) {
        optimalWakeUpMinutes -= 24 * 60;
      }

      // Add a quarter of an hour
      int adjustedWakeUpMinutes = optimalWakeUpMinutes + additionalMinutes;

      // Ensure it doesn't exceed the default wake-up time
      if (adjustedWakeUpMinutes > wakeUpTimeMinutes) {
        adjustedWakeUpMinutes = wakeUpTimeMinutes;
      }

      return _format12HourTime(adjustedWakeUpMinutes);
    } catch (e) {
      log("Error calculating optimal wake-up time: $e");
      rethrow;
    }
  }

  Map<String, int> _parse12HourTime(String time) {
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

  String _format12HourTime(int totalMinutes) {
    int hour = totalMinutes ~/ 60;
    int minute = totalMinutes % 60;

    String period = (hour < 12) ? 'AM' : 'PM';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;

    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
}
