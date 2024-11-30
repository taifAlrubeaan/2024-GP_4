import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AlarmController extends GetxController {
  bool isAlarmAdded = false;
  String printedBedtime = '';
  String printedWakeUpTime = '';
  int numOfCycles = 0;
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    checkIfAlarmAddedToday();
  }

  int calculateSleepCycles(String bedtime, String wakeTime) {
    try {
      final bedtimeDate = DateFormat("hh:mm a").parse(bedtime);
      final wakeTimeDate = DateFormat("hh:mm a").parse(wakeTime);

      // Convert times into minutes since midnight
      final bedtimeInMinutes = bedtimeDate.hour * 60 + bedtimeDate.minute;
      final wakeTimeInMinutes = wakeTimeDate.hour * 60 + wakeTimeDate.minute;

      // Calculate duration in minutes (handling overnight scenarios)
      final durationInMinutes = (wakeTimeInMinutes >= bedtimeInMinutes)
          ? wakeTimeInMinutes - bedtimeInMinutes
          : (1440 - bedtimeInMinutes) + wakeTimeInMinutes;

      // Calculate the number of 90-minute sleep cycles
      final cycles = durationInMinutes ~/ 90;

      return cycles; // Return the number of cycles as an integer
    } catch (e) {
      print("Error in calculateSleepCycles: $e");
      return 0; // Return -1 to indicate an error
    }
  }

  void checkIfAlarmAddedToday() async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart
          .add(const Duration(days: 1))
          .subtract(const Duration(seconds: 1));

      String formattedEndDayOfWakeup =
          DateFormat('hh:mm a').format(DateTime.now());

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('alarms')
          .where('uid', isEqualTo: userId)
          .where('isForBeneficiary', isEqualTo: true)
          .where('timestamp', isGreaterThanOrEqualTo: todayStart)
          .where('timestamp', isLessThanOrEqualTo: todayEnd)
          .where('wakeup_time', isGreaterThanOrEqualTo: formattedEndDayOfWakeup)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var alarmData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        isAlarmAdded = true;
        printedBedtime = alarmData['bedtime'] ?? '';
        printedWakeUpTime = alarmData['wakeup_time'] ?? '';
        numOfCycles = calculateSleepCycles(printedBedtime, printedWakeUpTime);
        log('numOfCycles $numOfCycles');
      } else {
        isAlarmAdded = false;
      }

      update();
    } catch (e) {
      debugPrint('Error fetching alarm: $e');
    }
  }

  Future<void> deleteAlarm() async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart
          .add(const Duration(days: 1))
          .subtract(const Duration(seconds: 1));

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('alarms')
          .where('uid', isEqualTo: userId)
          .where('isForBeneficiary', isEqualTo: true)
          .where('timestamp', isGreaterThanOrEqualTo: todayStart)
          .where('timestamp', isLessThanOrEqualTo: todayEnd)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String documentID = querySnapshot.docs.first.id;
        Map<String, dynamic> alarmData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;
        int alarmId = alarmData['alarmId'];

        await FirebaseFirestore.instance
            .collection('alarms')
            .doc(documentID)
            .delete();

        final prefs = await SharedPreferences.getInstance();
        String? jsonData = prefs.getString("alarms");

        if (jsonData != null && jsonData.isNotEmpty) {
          List<dynamic> alarmList = jsonDecode(jsonData);
          alarmList.removeWhere((alarm) => alarm['alarmId'] == alarmId);
          prefs.setString("alarms", jsonEncode(alarmList));
        }

        isAlarmAdded = false;
        printedBedtime = '';
        printedWakeUpTime = '';
        numOfCycles = 0;

        update();
      }
    } catch (e) {
      debugPrint('Error deleting alarm: $e');
    }
  }
}
