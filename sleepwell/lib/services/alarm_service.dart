import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleepwell/services/firebase_auth_service.dart';
import '../alarm.dart';
import '../models/alarm_data.dart';

class AlarmService {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuthService authService = FirebaseAuthService();
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  Future<AlarmService> init() async {
    if (userId != null) {
      log("Alarm Service Initialized for user ID: $userId");
      try {
        await Future.wait([
          startAlarmService(userId!),
          getAlarmsStream(userId!).listen((alarms) {
            log("Alarms fetched: ${alarms.length}");
            for (var alarm in alarms) {
              log("====================== Upcoming Alarm ===========================");
              log('Upcoming Alarm - Bedtime: ${alarm.bedtime}, Optimal Wake Time: ${alarm.optimalWakeTime},'
                  ' User ID: ${alarm.userId}, Beneficiary ID: ${alarm.beneficiaryId},'
                  ' User Type: ${alarm.isForBeneficiary}, Name: ${alarm.name}, Sensor ID: ${alarm.sensorId}\n\n');
              log("====================== Upcoming Alarm ===========================");
              log("====================== AppAlarm.printAllAlarms ===========================");
              log("====================== AppAlarm.printAllAlarms ===========================");
              log("====================== AppAlarm.printAllAlarms ===========================");
              AppAlarm.printAllAlarms();
              log("====================== AppAlarm.printAllAlarms ===========================");
              log("====================== AppAlarm.printAllAlarms ===========================");
              log("====================== AppAlarm.printAllAlarms ===========================");
            }
          }).asFuture()
        ]);
      } catch (e) {
        log("Error: $e");
      }
    } else {
      log("Error: User ID not found.");
    }
    return this;
  }

  static Stream<List<AlarmData>> getAlarmsStream(String userId) =>
      Stream.periodic(const Duration(minutes: 1), (_) async {
        List<AlarmData> alarms = await fetchTodayAlarms(userId);
        // log("Fetched Alarms:");

        // for (var alarm in alarms) {
        //   log('Fetched Alarm - Bedtime: ${alarm.bedtime}, Optimal Wake Time: ${alarm.optimalWakeTime},'
        //       ' User ID: ${alarm.userId}, Beneficiary ID: ${alarm.beneficiaryId},'
        //       ' User Type: ${alarm.isForBeneficiary}, Name: ${alarm.name}, Sensor ID: ${alarm.sensorId}');
        // }

        return alarms;
      }).asyncMap((event) => event);
  static Future<List<AlarmData>> fetchTodayAlarms(String userId) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart
        .add(const Duration(days: 1))
        .subtract(const Duration(seconds: 1));

    String formattedendDayOfWackup =
        DateFormat('hh:mm a').format(DateTime.now());
    log(formattedendDayOfWackup.toString());
    log('-----------------------------------');
    QuerySnapshot querySnapshot = await firestore
        .collection('alarms')
        .where('uid', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: todayStart)
        .where('timestamp', isLessThanOrEqualTo: todayEnd)
        .where('wakeup_time',
            isGreaterThanOrEqualTo: formattedendDayOfWackup.toString())
        .orderBy('timestamp', descending: true)
        .get();

    List<AlarmData> alarms = [];
    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      var alarm = AlarmData.fromJson(data);

      if (alarm.userId == "0") {
        log('Skipping alarm with invalid userId');
        continue;
      }

      if (alarm.isForBeneficiary) {
        alarm.name = "Yourself";
      } else {
        alarm.name = await fetchBeneficiaryName(alarm.userId);
      }

      alarms.add(alarm);
    }

    return alarms;
  }

  static Future<String> fetchBeneficiaryName(String beneficiaryId) async {
    try {
      QuerySnapshot snapshot = await firestore
          .collection('beneficiaries')
          .where('userid', isEqualTo: beneficiaryId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var beneficiaryData =
            snapshot.docs.first.data() as Map<String, dynamic>;
        return beneficiaryData['name'];
      } else {
        log('No beneficiaries found for beneficiaryId: $beneficiaryId');
        return 'Unknown Beneficiary';
      }
    } catch (e) {
      log('Error fetching beneficiary name: $e');
      return 'Error fetching name';
    }
  }

  static Future<void> startAlarmService(String userId) async {
    log("====================== AppAlarm.printAllAlarms ===========================");
    await AppAlarm.printAllAlarms();
    log("====================== AppAlarm.printAllAlarms ===========================");

    await for (var alarms in getAlarmsStream(userId)) {
      for (var alarm in alarms) {
        DateTime now = DateTime.now();

        // Parse and calculate the exact time for the alarm
        DateTime alarmTime;
        try {
          alarmTime = DateFormat('hh:mm a').parse(alarm.optimalWakeTime);
          alarmTime = DateTime(
              now.year, now.month, now.day, alarmTime.hour, alarmTime.minute);
        } catch (e) {
          log("Error parsing alarm time: $e");
          continue;
        }

        // Check if this alarm already exists in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        String? jsonData = prefs.getString("alarms");
        bool alarmExists = false;

        if (jsonData != null) {
          List<dynamic> alarmList = jsonDecode(jsonData);
          alarmExists = alarmList.any((storedAlarmJson) {
            var storedAlarm = AlarmData.fromJson(storedAlarmJson);
            return storedAlarm.beneficiaryId == alarm.userId &&
                storedAlarm.optimalWakeTime == alarm.optimalWakeTime;
          });
        }

        // Only save the alarm if it doesn't already exist
        if (!alarmExists) {
          await AppAlarm.saveAlarm(
            alarmId: alarm.alarmId,
            bedtime: alarm.bedtime,
            optimalWakeTime: alarm.optimalWakeTime,
            userId: alarm.userId,
            usertype: alarm.isForBeneficiary,
            name: alarm.name,
            sensorId: alarm.sensorId,
          );
          log("====================== New Alarm Added ===========================");
          log('New Alarm - Bedtime: ${alarm.bedtime}, Optimal Wake Time: ${alarm.optimalWakeTime},'
              ' User ID: ${alarm.userId}, Beneficiary ID: ${alarm.beneficiaryId},'
              ' User Type: ${alarm.isForBeneficiary}, Name: ${alarm.name}, Sensor ID: ${alarm.sensorId}');
          log("====================== New Alarm Added ===========================");
        } else {
          log("Alarm for user ${alarm.userId} at ${alarm.optimalWakeTime} already exists. Skipping.");
        }
      }
    }
  }
}
