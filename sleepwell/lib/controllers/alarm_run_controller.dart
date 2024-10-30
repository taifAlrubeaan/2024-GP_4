import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/alarm_data.dart';

class AlarmRunController extends GetxController {
  static Map<String, AlarmData> alarms = {};

  // Load alarms from SharedPreferences
  Future<void> loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString("alarms");

    if (jsonData != null) {
      final Map<String, dynamic> alarmMap = jsonDecode(jsonData);
      alarms = alarmMap
          .map((key, value) => MapEntry(key, AlarmData.fromJson(value)));
    }
  }

  // Save alarm
  Future<void> saveAlarm(String userId, AlarmData alarmData) async {
    alarms[userId] = alarmData;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("alarms",
        jsonEncode(alarms.map((key, value) => MapEntry(key, value.toJson()))));
  }

  // Get an alarm by userId
  AlarmData? getAlarm(String userId) {
    return alarms[userId];
  }

  // Delete an alarm by userId
  Future<void> deleteAlarm(String userId) async {
    alarms.remove(userId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("alarms",
        jsonEncode(alarms.map((key, value) => MapEntry(key, value.toJson()))));
  }
}
