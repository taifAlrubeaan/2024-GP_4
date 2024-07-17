import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleepwell/models/list_of_music.dart';
import 'package:sleepwell/screens/alarm/alarm_ring_screen.dart';
import 'package:sleepwell/screens/alarm/alarm_ring_with_equation_screen.dart';

class AppAlarm {
  static StreamSubscription<AlarmSettings>? subscription;
  static String _selectedSoundPath = musicList[0].musicPath;
  static String _selectedMission = 'Default';
  static String _selectedMath = 'easy';

  static Future<void> initAlarms() async {
    if (Alarm.android) {
      checkAndroidNotificationPermission();
      checkAndroidScheduleExactAlarmPermission();
    }

    final prefs = await SharedPreferences.getInstance();
    _loadSettings(prefs);
    subscription ??= Alarm.ringStream.stream.listen(
      (alarmSettings) {
        if (_selectedMission == "Default") {
          Get.to(() => AlarmRingScreen(alarmSettings: alarmSettings));
        } else {
          Get.to(() => AlarmRingWithEquationScreen(
                alarmSettings: alarmSettings,
                showEasyEquation: _selectedMath == "easy",
              ));
        }
      },
    );
  }

  static void _loadSettings(SharedPreferences prefs) {
    _selectedSoundPath =
        prefs.getString("selectedSoundPath") ?? musicList[0].musicPath;
    _selectedMission = prefs.getString("selectedMission") ?? "Default";
    _selectedMath = prefs.getString("selectedMath") ?? "easy";
  }

  static Future<void> checkAndroidNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      alarmPrint('Requesting notification permission...');
      final res = await Permission.notification.request();
      alarmPrint(
        'Notification permission ${res.isGranted ? '' : 'not '}granted.',
      );
    }
  }

  static Future<void> checkAndroidScheduleExactAlarmPermission() async {
    final status = await Permission.scheduleExactAlarm.status;
    alarmPrint('Schedule exact alarm permission: $status.');
    if (status.isDenied) {
      alarmPrint('Requesting schedule exact alarm permission...');
      final res = await Permission.scheduleExactAlarm.request();
      alarmPrint(
        'Schedule exact alarm permission ${res.isGranted ? '' : 'not'} granted.',
      );
    }
  }

  static AlarmSettings buildAlarmSettings(DateTime date) {
    // final id = DateTime.now().millisecondsSinceEpoch % 100000;
    print(_selectedSoundPath);
    const id = 1000;
    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: date,
      loopAudio: true,
      vibrate: true,
      volume: 1,
      assetAudioPath: _selectedSoundPath,
      notificationTitle: 'Alarm',
      notificationBody: 'Optimal time to WAKE UP',
    );
    return alarmSettings;
  }

  static Future<void> saveAlarm(
      TimeOfDay bedtime, String optimalWakeTime) async {
    // find the date and time of bedtime
    DateTime bedtimeDate = DateFormat("yyyy-MM-dd hh:mm a").parse(
        "${DateTime.now().toString().split(' ')[0]} ${bedtime.format(Get.context!)}");

    // find the date and time of optimal wake-up
    DateTime optimalWakeUpDate = DateFormat("yyyy-MM-dd hh:mm a")
        .parse("${DateTime.now().toString().split(' ')[0]} $optimalWakeTime");
    print("::::::::::::::: bedtimeDate == $bedtimeDate");
    print("::::::::::::::: optimalWakeUpDate == $optimalWakeUpDate");

    // update optimal wake-up date to tomorrow if it is before bedtime
    if (optimalWakeUpDate.isBefore(bedtimeDate)) {
      optimalWakeUpDate = optimalWakeUpDate.add(const Duration(days: 1));
      print("============= update optimal date to == $optimalWakeUpDate");
    }

    // save the alarms
    await Alarm.set(alarmSettings: buildAlarmSettings(optimalWakeUpDate));
  }

  static getAlarms() {
    Alarm.getAlarms().forEach((element) {
      print("-- ${element.dateTime}");
    });
  }

  static updateStoredWakeUpAlarmSound() {
    AlarmSettings? alarmSettings = Alarm.getAlarm(1000);
    if (alarmSettings != null) {
      alarmSettings =
          alarmSettings.copyWith(assetAudioPath: _selectedSoundPath);
      Alarm.set(alarmSettings: alarmSettings);
    }
  }
}
