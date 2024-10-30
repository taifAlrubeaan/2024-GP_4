import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AlarmModelData {
  var bedtime;
  var wakeupTime;
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
    print(data);
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
    try {
      // استخراج الوقت فقط من `bedtime` و `wakeupTime`
      DateFormat fullDateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
      DateFormat timeOnlyFormat = DateFormat('h:mm a');

      // تحويل `bedtime` و `wakeupTime` إلى `DateTime` وقراءة الوقت فقط
      DateTime sleepDateTime = fullDateTimeFormat.parse(bedtime);
      DateTime wakeDateTime = fullDateTimeFormat.parse(wakeupTime);

      // تحويل التاريخ إلى صيغة الوقت فقط، باستخدام تاريخ افتراضي
      DateTime sleepTime =
          DateTime(1970, 1, 1, sleepDateTime.hour, sleepDateTime.minute);
      DateTime wakeTime =
          DateTime(1970, 1, 1, wakeDateTime.hour, wakeDateTime.minute);

      // إذا كان وقت الاستيقاظ قبل وقت النوم، نعتبره في اليوم التالي
      if (wakeTime.isBefore(sleepTime)) {
        wakeTime = wakeTime.add(const Duration(days: 1));
      }

      return wakeTime.difference(sleepTime);
    } catch (e) {
      print('Error parsing sleep duration: $e');
      return Duration.zero; // إرجاع صفر في حال حدوث خطأ
    }
  }

  // الحصول على دورات النوم كرقم بدلاً من String
  double get sleepCycles {
    return double.tryParse(numOfCycles) ?? 0.0;
  }
}
