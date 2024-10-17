 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AlarmModelData {
  final String bedtime;
  final String wakeupTime;
  final String numOfCycles;
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
    return AlarmModelData(
      bedtime: data['bedtime'],
      wakeupTime: data['wakeup_time'],
      numOfCycles: data['num_of_cycles'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isForBeneficiary: data['isForBeneficiary'],
    );
  }

  // حساب مدة النوم بناءً على وقت النوم ووقت الاستيقاظ
  // Duration get sleepDuration {
  //   final sleepTime = DateTime.parse(bedtime);
  //   final wakeTime = DateTime.parse(wakeupTime);
  //   return wakeTime.difference(sleepTime);
  // }
  Duration get sleepDuration {
    // Assuming a default date for both times (like '1970-01-01')
    DateFormat timeFormat = DateFormat('h:mm a');

    // Parsing the times into DateTime objects with a default date
    final sleepTime = timeFormat.parse(bedtime); // Example: '4:30 AM'
    final wakeTime = timeFormat.parse(wakeupTime); // Example: '6:30 AM'

    // Set a default date to compare times
    DateTime sleepDateTime =
        DateTime(1970, 1, 1, sleepTime.hour, sleepTime.minute);
    DateTime wakeDateTime =
        DateTime(1970, 1, 1, wakeTime.hour, wakeTime.minute);

    // If wakeup time is before sleep time, assume it is the next day
    if (wakeDateTime.isBefore(sleepDateTime)) {
      wakeDateTime = wakeDateTime.add(const Duration(days: 1));
    }

    return wakeDateTime.difference(sleepDateTime);
  }

  // الحصول على دورات النوم كرقم بدلاً من String
  double get sleepCycles {
    return double.tryParse(numOfCycles) ?? 0.0;
  }
}
