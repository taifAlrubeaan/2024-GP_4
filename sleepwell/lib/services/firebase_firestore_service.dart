import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:sleepwell/services/firebase_auth_service.dart';
import 'update_optimal_bedtime_and_wakeuptime_alarm_service.dart';

class FirebaseFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UpdateOptimalBedtimeAndWakeAlarmService updateOptimalAlarm =
      UpdateOptimalBedtimeAndWakeAlarmService();
  // String? userId = FirebaseAuth.instance.currentUser?.uid;
  final FirebaseAuthService authService = FirebaseAuthService();
  String? userId;

  Future<void> saveAlarm(
      String bedtime,
      String wakeupTime,
      String cycles,
      String userId,
      String? beneficiaryId,
      bool isForBeneficiary,
      String sensorId,
      int alarmId) async {
    await _firestore.collection('alarms').add({
      'bedtime': bedtime,
      'wakeup_time': wakeupTime,
      'num_of_cycles': cycles,
      'added_day': DateTime.now().day,
      'added_month': DateTime.now().month,
      'added_year': DateTime.now().year,
      'timestamp': FieldValue.serverTimestamp(),
      'uid': userId,
      'beneficiaryId': beneficiaryId,
      'isForBeneficiary': isForBeneficiary,
      'sensorId': sensorId,
      'alarmId': alarmId
    });
  }

  Future<void> updateBedtime({
    required String newBedtime,
    required String newOptimalWakeUpTime,
    required int alarmId,
  }) async {
    try {
      userId = authService.getUserId() ?? '';

      QuerySnapshot snapshot = await _firestore
          .collection('alarms')
          .where('uid', isEqualTo: userId)
          .where('alarmId', isEqualTo: alarmId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // الحصول على ID الوثيقة
        String documentId = snapshot.docs.first.id;

        // تحديث البيانات
        await _firestore.collection('alarms').doc(documentId).update({
          'bedtime': newBedtime,
          'wakeup_time': newOptimalWakeUpTime,
          'num_of_cycles':
              calculateSleepDuration(newBedtime, newOptimalWakeUpTime),
          'timestamp': FieldValue.serverTimestamp(),
        });

        log('Bedtime updated successfully In Firebase for userId: $userId');
      } else {
        log('No matching document found for userId: $userId');
      }
    } catch (e) {
      log('Failed to update bedtime: $e');
    }
  }

  int calculateSleepDuration(String bedtime, String wakeUpTime) {
    // تحويل النصوص إلى DateTime
    DateFormat format = DateFormat('hh:mm a');
    DateTime bedtimeParsed = format.parse(bedtime);
    DateTime wakeUpTimeParsed = format.parse(wakeUpTime);

    // معالجة عبور منتصف الليل
    if (wakeUpTimeParsed.isBefore(bedtimeParsed)) {
      wakeUpTimeParsed = wakeUpTimeParsed.add(const Duration(days: 1));
    }

    // حساب الفرق بالدقائق
    int duration = wakeUpTimeParsed.difference(bedtimeParsed).inMinutes;
    int cycleDurationMinutes = 90; // طول الدورة بالنظام

    // حساب الساعات والدقائق
    int numOfCycles = duration ~/ cycleDurationMinutes;
    int remainingMinutes = duration % cycleDurationMinutes;

    // طباعة القيم
    print('Number of cycles: $numOfCycles');
    print('Remaining minutes: $remainingMinutes');

    return numOfCycles;
  }
}
