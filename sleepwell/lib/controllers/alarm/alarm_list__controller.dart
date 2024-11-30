import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/alarm_data.dart';

class AlarmListController extends GetxController {
  var alarms = <AlarmData>[].obs; // Reactive list for alarms
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    loadAlarms();

    log('Alarms loaded: ${alarms.length} alarms');
  }

  Future<void> printAllAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString("alarms");

    if (jsonData != null && jsonData.isNotEmpty) {
      try {
        List<dynamic> alarmList = jsonDecode(jsonData);
        List<AlarmData> alarmsData =
            alarmList.map((e) => AlarmData.fromJson(e)).toList();

        log("=====================printAllAlarms===========================");
        for (var alarm in alarmsData) {
          log(alarm.toJson().toString());
        }
      } catch (e) {
        log("Error decoding alarms: $e");
      }
    } else {
      log("No alarms data found in SharedPreferences.");
    }
  }

  Future<void> loadAlarmss() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? jsonData = prefs.getString("alarms");

      if (jsonData != null) {
        var decodedData = jsonDecode(jsonData);
        List<dynamic> alarmList =
            decodedData is List ? decodedData : [decodedData];

        alarms.value = alarmList
            .map((alarmJson) =>
                AlarmData.fromJson(alarmJson as Map<String, dynamic>))
            .where((alarm) {
              // Parse optimalWakeTime and compare it with the current time
              if (alarm.optimalWakeTime.isNotEmpty) {
                try {
                  // Attempt to parse the time using the custom format
                  DateTime now = DateTime.now();
                  DateTime parsedWakeTime = _parseTimeToDateTime(
                    alarm.optimalWakeTime,
                    now,
                  );
                  return parsedWakeTime.isAfter(DateTime.now());
                } catch (e) {
                  log("Error parsing optimalWakeTime: $e");
                  return false; // Skip invalid times
                }
              }
              return false; // Skip alarms with no wakeup time
            })
            .toList()
            .reversed
            .toList(); // Reverse list to show most recent alarms first

        log("Filtered Alarms loaded: ${alarms.length} alarms");
      }
    } catch (e) {
      debugPrint("Error loading alarms: $e");
      log("Error loading alarms: $e");
    }
  }

  DateTime _parseTimeToDateTime(String time, DateTime currentDate) {
    try {
      // Parse time in the format "hh:mm a" (e.g., "10:00 PM")
      final DateFormat timeFormat = DateFormat("hh:mm a");
      final DateTime parsedTime = timeFormat.parse(time);

      // Combine the parsed time with the current date
      return DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        parsedTime.hour,
        parsedTime.minute,
      );
    } catch (e) {
      log("Error in _parseTimeToDateTime: $e");
      throw FormatException("Invalid time format: $time");
    }
  }

  Future<void> loadAlarms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? jsonData = prefs.getString("alarms");

      if (jsonData != null) {
        var decodedData = jsonDecode(jsonData);
        List<dynamic> alarmList =
            decodedData is List ? decodedData : [decodedData];
        // log("Alarm List json: $alarmList \n");
        alarms.value = alarmList
            .map((alarmJson) =>
                AlarmData.fromJson(alarmJson as Map<String, dynamic>))
            .toList()
            .reversed
            .toList(); // Reverse the list to show recent alarms first
        log("Alarms loaded: ${alarms.length} alarms");
      }
    } catch (e) {
      debugPrint("Error loading alarms: $e");
      log("Error loading alarms: $e");
    }
  }

  Future<void> saveAlarms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      alarms.value = alarms.reversed.toList(); // Reverse back before saving
      await prefs.setString(
          "alarms", jsonEncode(alarms.map((e) => e.toJson()).toList()));
    } catch (e) {
      debugPrint("Error saving alarms: $e");
    }
  }

  void addAlarm(AlarmData newAlarm) {
    alarms.add(newAlarm);
    saveAlarms();
  }

  void deleteAlarm(int alarmId) {
    alarms.removeWhere((alarm) => alarm.alarmId == alarmId);
    // deleteAlarmFromFirebase(alarmId);
    saveAlarms();
  }

  void updateAlarm(int index, AlarmData updatedAlarm) {
    alarms[index] = updatedAlarm;
    saveAlarms();
    log("Alarms loaded: ${alarms.length} alarms");
  }

  void printAlarmsToConsole() {
    log("Alarms List:");
    for (var alarm in alarms) {
      log(alarm.toJson().toString());
    }
  }

  Future<void> deleteAlarmFromFirebase(int alarmId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('alarms')
          .where('uid', isEqualTo: userId)
          .where('alarmId', isEqualTo: alarmId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String documentID = querySnapshot.docs.first.id;
        await FirebaseFirestore.instance
            .collection('alarms')
            .doc(documentID)
            .delete();
      }
    } catch (e) {
      debugPrint('Error deleting alarm from Firebase: $e');
    }
  }
}
