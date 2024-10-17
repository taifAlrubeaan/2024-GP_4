import 'dart:async';
import 'dart:developer';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleepwell/models/list_of_music.dart';
import 'package:sleepwell/screens/alarm/alarm_ring_screen.dart';
import 'package:sleepwell/screens/alarm/alarm_ring_with_equation_screen.dart';

import 'controllers/beneficiary_controller.dart';
import 'main.dart';

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
        // beneficiaryId = selectedBeneficiaryId!;
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

  final BeneficiaryController controller = Get.find();
  late RxString beneficiaryId = ''.obs;
  String? selectedBeneficiaryId;
  bool? isForBeneficiary = true;

  static Future<void> saveAlarm(
    TimeOfDay bedtime,
    String optimalWakeTime,
    String beneficiaryId, // نقبل null إذا كان المنبه للمستخدم نفسه
  ) async {
    // تحديد تاريخ ووقت النوم
    DateTime bedtimeDate = DateFormat("yyyy-MM-dd hh:mm a").parse(
      "${DateTime.now().toString().split(' ')[0]} ${bedtime.format(Get.context!)}",
    );

    // تحديد تاريخ ووقت الاستيقاظ المثالي
    DateTime optimalWakeUpDate = DateFormat("yyyy-MM-dd hh:mm a").parse(
      "${DateTime.now().toString().split(' ')[0]} $optimalWakeTime",
    );

    // تعديل تاريخ الاستيقاظ ليكون في اليوم التالي إذا كان وقت الاستيقاظ قبل وقت النوم
    if (optimalWakeUpDate.isBefore(bedtimeDate)) {
      optimalWakeUpDate = optimalWakeUpDate.add(const Duration(days: 1));
    }

    // إعداد المنبه باستخدام إعدادات التنبيه
    final alarmSettings = buildAlarmSettings(optimalWakeUpDate);
    await Alarm.set(alarmSettings: alarmSettings);

    // التوجيه إلى شاشة رنين المنبه بناءً على المستفيد أو المستخدم
    Get.to(() => AlarmRingScreen(
          alarmSettings: alarmSettings,
          // beneficiaryId: isForBeneficiary
          //     ? beneficiaryId
          //     : null, // تمرير معرف المستفيد أو null
        ));

    // طباعة معلومات لأغراض تتبع التصحيح
    log("Alarm For------------------------------------------------");
    log("Beneficiary ID: ${beneficiaryId ?? 'None (User)'}");
    beneficiaryId = beneficiaryId;
    log("Is for Beneficiary: $beneficiaryId");
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
