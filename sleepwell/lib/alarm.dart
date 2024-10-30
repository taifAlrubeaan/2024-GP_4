import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:alarm/alarm.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleepwell/models/alarm_data.dart';

import 'package:sleepwell/models/list_of_music.dart';
import 'package:sleepwell/screens/alarm/alarm_ring_screen.dart';
import 'package:sleepwell/screens/alarm/alarm_ring_with_equation_screen.dart';

class AppAlarm {
  static StreamSubscription<AlarmSettings>? subscription;
  static String _selectedSoundPath = musicList[0].musicPath;
  static String _selectedMission = 'Default';
  static String _selectedMath = 'easy';
  static late AlarmData alarmsData;

  // Initialize alarms and check permissions
  static Future<void> initAlarms() async {
    if (Alarm.android) {
      await checkAndroidNotificationPermission();
      await checkAndroidScheduleExactAlarmPermission();
    }

    final prefs = await SharedPreferences.getInstance();
    _loadSettings(prefs);
    String? jsonData = prefs.getString("alarms");
    if (jsonData != null) {
      Map<String, dynamic> rawData = jsonDecode(jsonData);
      alarmsData = AlarmData.fromJson(rawData);
      // rawData.map((key, value) => MapEntry(key, AlarmData.fromJson(value)));
    }

    subscription ??= Alarm.ringStream.stream.listen((alarmSettings) {
      log("Alarm triggered for: ${alarmSettings.id}");
      if (_selectedMission == "Default") {
        Get.to(
            () => AlarmRingScreen(
                  alarmSettings: alarmSettings,
                  alarmsData: alarmsData,
                ),
            arguments: alarmsData);
      } else {
        Get.to(
            () => AlarmRingWithEquationScreen(
                  alarmSettings: alarmSettings,
                  showEasyEquation: _selectedMath == "easy",
                  alarmsData: alarmsData,
                ),
            arguments: alarmsData);
      }
    });
  }

  static void _loadSettings(SharedPreferences prefs) {
    _selectedSoundPath =
        prefs.getString("selectedSoundPath") ?? musicList[0].musicPath;
    _selectedMission = prefs.getString("selectedMission") ?? "Default";
    _selectedMath = prefs.getString("selectedMath") ?? "easy";
  }

  // Request permissions for Android notifications
  static Future<void> checkAndroidNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  // Request permissions for exact alarm scheduling
  static Future<void> checkAndroidScheduleExactAlarmPermission() async {
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  static AlarmSettings buildAlarmSettings(DateTime date) {
    const id = 1000;
    return AlarmSettings(
      id: id,
      dateTime: date,
      loopAudio: true,
      vibrate: true,
      volume: 1,
      assetAudioPath: _selectedSoundPath,
      notificationTitle: 'Alarm',
      notificationBody: 'Optimal time to WAKE UP',
    );
  }

  // Save a new or updated alarm
  static Future<void> saveAlarm({
    required String userId,
    required String bedtime,
    required String optimalWakeTime,
    required String name,
    bool usertype = false,
    required String sensorId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Update alarm data for the user
    alarmsData = AlarmData(
      userId: userId,
      bedtime: bedtime,
      optimalWakeTime: optimalWakeTime,
      name: name,
      usertype: usertype,
      sensorId: sensorId,
    );

    // Save the updated alarms data back to shared preferences
    await prefs.setString("alarms", jsonEncode(alarmsData.toJson()));

    DateTime now = DateTime.now();
    DateTime bedtimeDate = DateFormat("HH:mm").parse(bedtime);
    bedtimeDate = DateTime(
        now.year, now.month, now.day, bedtimeDate.hour, bedtimeDate.minute);

    DateTime optimalWakeUpDate = DateFormat("yyyy-MM-dd hh:mm a")
        .parse("${DateTime.now().toString().split(' ')[0]} $optimalWakeTime");

    if (optimalWakeUpDate.isBefore(bedtimeDate)) {
      optimalWakeUpDate = optimalWakeUpDate.add(const Duration(days: 1));
    }

    final alarmSettings = buildAlarmSettings(optimalWakeUpDate);
    await Alarm.set(alarmSettings: alarmSettings);
  }

  static updateStoredWakeUpAlarmSound() {
    AlarmSettings? alarmSettings = Alarm.getAlarm(1000);
    if (alarmSettings != null) {
      alarmSettings =
          alarmSettings.copyWith(assetAudioPath: _selectedSoundPath);
      Alarm.set(alarmSettings: alarmSettings);
      log("Alarm sound updated for Alarm ID: ${alarmSettings.id}");
    }
  }

  // Load and update a user's alarm
  static Future<void> loadAndUpdateAlarm({
    required String userId,
    String? newBedtime,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Check if alarm data for the user exists and update bedtime
    if (alarmsData.userId == userId && newBedtime != null) {
      alarmsData.bedtime = newBedtime;

      await prefs.setString("alarms", jsonEncode(alarmsData.toJson()));

      String optimalWakeTime = alarmsData.optimalWakeTime;
      String name = alarmsData.name;
      bool usertype = alarmsData.usertype;
      String sensorId = alarmsData.sensorId;
      await saveAlarm(
        userId: userId,
        bedtime: newBedtime,
        optimalWakeTime: optimalWakeTime,
        name: name,
        usertype: usertype,
        sensorId: sensorId,
        // sensorId: sensorService.selectedSensor.value,
      );
    } else {
      log("No alarm data found for userId $userId.");
    }
  }

  // Fetch all existing alarms
  static Future<void> getAlarms() async {
    var alarms = await Alarm.getAlarms();
    for (var alarm in alarms) {
      log("Alarm ID: ${alarm.id}, Time: ${alarm.dateTime}");
    }
  }

  // Clear all existing alarms
  static Future<void> clearExistingAlarm() async {
    var alarms = await Alarm.getAlarms();
    for (var alarm in alarms) {
      await Alarm.stop(alarm.id);
      log("Stopped alarm with ID: ${alarm.id}");
    }
  }

  // Print all saved alarms
  static Future<void> printAllAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString("alarms");

    alarmsData = AlarmData.fromJson(jsonDecode(jsonData!));
    log(alarmsData.toJson().toString());
  }
}
