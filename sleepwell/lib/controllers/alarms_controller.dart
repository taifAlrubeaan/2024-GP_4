import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:sleepwell/models/alarm_model.dart';

class AlarmsController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  // جلب بيانات آخر يوم
  Future<List<AlarmModelData>> fetchLastDayAlarms(String userId) async {
    final now = DateTime.now();
    final DateTime yesterdayStart = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 1)); // بداية يوم أمس
    final DateTime yesterdayEnd = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(seconds: 1)); // نهاية يوم أمس

    QuerySnapshot querySnapshot = await _firestore
        .collection('alarms')
        .where('uid', isEqualTo: userId)
        .where('isForBeneficiary', isEqualTo: true)
        .where('timestamp', isGreaterThanOrEqualTo: yesterdayStart)
        .where('timestamp', isLessThanOrEqualTo: yesterdayEnd)
        .get();
    print('dddddddddddddddddddddddddddddddddddddddddddd');
    querySnapshot.docs.forEach((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = data['timestamp']
          ?.toDate(); // Assuming 'timestamp' is a Timestamp object from Firestore
      if (timestamp != null) {
        print('Document ID: ${doc.id}');
        print('Data: $data');
        print('dddddddddddddddddddddddddddddddddddddddddddd');
        print('Timestamp: $timestamp\n');
      }
    });
    return querySnapshot.docs
        .map((doc) =>
            AlarmModelData.fromFirestore(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // جلب بيانات آخر أسبوع

  Future<List<AlarmModelData>> fetchLastWeekAlarms(String userId) async {
    DateTime now = DateTime.now();
    DateTime lastWeek = now.subtract(Duration(days: 7));
    final weekEnd = now.subtract(
        const Duration(days: 1)); // Today is the end of the 7-day period
    final weekStart = now.subtract(
        const Duration(days: 7)); // 6 days ago is the start of the 7-day period

    try {
      // طباعة معلومات التواريخ لأغراض التحقق
      print("Fetching alarms from $weekStart to $weekEnd for user: $userId");

      QuerySnapshot querySnapshot = await _firestore
          .collection('alarms')
          .where('uid', isEqualTo: userId)
          .where('isForBeneficiary', isEqualTo: true)
          .where('timestamp', isGreaterThanOrEqualTo: weekStart)
          .where('timestamp', isLessThanOrEqualTo: weekEnd)
          .get();

      // طباعة عدد النتائج المسترجعة
      print("Fetched ${querySnapshot.docs.length} alarms.");

      // تحويل البيانات
      List<AlarmModelData> alarms = querySnapshot.docs
          .map((doc) =>
              AlarmModelData.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();

      // طباعة تفاصيل البيانات المسترجعة
      alarms.forEach((alarm) {
        print(
            "Alarm: Bedtime: ${alarm.bedtime}, Wakeup Time: ${alarm.wakeupTime}, Num of Cycles: ${alarm.numOfCycles}, Timestamp: ${alarm.timestamp}, Is for Beneficiary: ${alarm.isForBeneficiary}");
      });

      return alarms;
    } catch (e) {
      // طباعة رسالة الخطأ في حالة حدوث مشكلة
      print("Error fetching alarms: $e");
      return [];
    }
  }

  // جلب بيانات الشهر السابق
  Future<List<AlarmModelData>> fetchPreviousMonthAlarms(
    String userId,
    // {required bool isForBeneficiary}
  ) async {
    DateTime now = DateTime.now();
    DateTime startOfCurrentMonth = DateTime(now.year, now.month, 1);
    DateTime startOfPreviousMonth = DateTime(now.year, now.month - 1, 1);

    QuerySnapshot querySnapshot = await _firestore
        .collection('alarms')
        .where('uid', isEqualTo: userId)
        .where('isForBeneficiary', isEqualTo: true)
        .where('timestamp', isGreaterThanOrEqualTo: startOfPreviousMonth)
        .where('timestamp', isLessThan: now)
        .get();

    return querySnapshot.docs
        .map((doc) =>
            AlarmModelData.fromFirestore(doc.data() as Map<String, dynamic>))
        .toList();
  } //

  // جلب بيانات آخر يوم المستفيدين
  Future<List<AlarmModelData>> fetchBeneficiaryAlarms(
      String beneficiaryId) async {
    final now = DateTime.now();
    final DateTime yesterdayStart = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 1)); // بداية يوم أمس
    final DateTime yesterdayEnd = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(seconds: 1)); // نهاية يوم أمس
    QuerySnapshot querySnapshot = await _firestore
        .collection('alarms')
        .where('beneficiaryId', isEqualTo: beneficiaryId)
        .where('isForBeneficiary', isEqualTo: false)
        .where('timestamp', isGreaterThanOrEqualTo: yesterdayStart)
        .where('timestamp', isLessThan: yesterdayEnd)
        .get();

    return querySnapshot.docs
        .map((doc) =>
            AlarmModelData.fromFirestore(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // جلب بيانات المستفيدين للأسبوع الأخير
  Future<List<AlarmModelData>> fetchBeneficiaryLastWeekAlarms(
      String beneficiaryId) async {
    DateTime now = DateTime.now();

    final weekEnd = now.subtract(
        const Duration(days: 1)); // Today is the end of the 7-day period
    final weekStart = now.subtract(
        const Duration(days: 7)); // 6 days ago is the start of the 7-day period
    print(weekStart);
    print(':::::::::::');
    print(weekEnd);
    QuerySnapshot querySnapshot = await _firestore
        .collection('alarms')
        .where('uid', isEqualTo: userId)
        .where('beneficiaryId', isEqualTo: beneficiaryId)
        .where('isForBeneficiary', isEqualTo: false)
        .where('timestamp', isGreaterThanOrEqualTo: weekStart)
        .where('timestamp', isLessThanOrEqualTo: weekEnd)
        .get();

    return querySnapshot.docs
        .map((doc) =>
            AlarmModelData.fromFirestore(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // جلب بيانات المستفيدين للشهر السابق

  Future<List<AlarmModelData>> fetchBeneficiaryLastMonthAlarms(
      String beneficiaryId) async {
    DateTime now = DateTime.now();
    DateTime startOfCurrentMonth = DateTime(now.year, now.month, 1);
    DateTime startOfPreviousMonth = DateTime(now.year, now.month - 1, 1);

    QuerySnapshot querySnapshot = await _firestore
        .collection('alarms')
        .where('uid', isEqualTo: userId)
        .where('beneficiaryId', isEqualTo: beneficiaryId)
        .where('isForBeneficiary', isEqualTo: false)
        .where('timestamp', isGreaterThanOrEqualTo: startOfPreviousMonth)
        .where('timestamp', isLessThan: now)
        .get();

    return querySnapshot.docs
        .map((doc) =>
            AlarmModelData.fromFirestore(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
