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
  // final SleepCycleController controller = Get.put(SleepCycleController());
  static late List<AlarmData> alarmsData = [];
  static Future<void> saveDefaultSettings({
    required String soundPath,
    required String mission,
    required String mathDifficulty,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, String> defaultSettings = {
      'soundPath': soundPath,
      'mission': mission,
      'mathDifficulty': mathDifficulty,
    };
    await prefs.setString('defaultSettings', jsonEncode(defaultSettings));
    log("Default settings saved: $defaultSettings");
  }

  static Future<Map<String, String>> getDefaultSettings() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonSettings = prefs.getString('defaultSettings');
    if (jsonSettings != null && jsonSettings.isNotEmpty) {
      try {
        Map<String, dynamic> settings = jsonDecode(jsonSettings);
        return settings.map((key, value) => MapEntry(key, value.toString()));
      } catch (e) {
        log("Error parsing default settings: $e");
      }
    }
    // Return some sensible defaults if none are set
    return {
      'soundPath': musicList[0].musicPath,
      'mission': 'Default',
      'mathDifficulty': 'easy',
    };
  }

  // static bool isInitialized() {
  //   return alarmsData.isNotEmpty;
  // }
  /// Check if alarms are initialized.
  static bool isInitialized() => alarmsData.isNotEmpty;

  /// Initialize alarms from saved data and set up the alarm listener.
  static Future<void> initAlarms() async {
    try {
      if (Alarm.android) {
        await checkAndroidNotificationPermission();
        await checkAndroidScheduleExactAlarmPermission();
      }

      final prefs = await SharedPreferences.getInstance();
      String? jsonData = prefs.getString("alarms");

      if (jsonData != null && jsonData.isNotEmpty) {
        List<dynamic> alarmList = jsonDecode(jsonData);
        alarmsData = alarmList.map((e) => AlarmData.fromJson(e)).toList();
        log("Initialized alarms: $alarmsData");
      }

      subscription ??= Alarm.ringStream.stream.listen((alarmSettings) {
        _handleAlarmRing(alarmSettings);
      });
    } catch (e) {
      log("Error initializing alarms: $e");
    }
  }

  /// Handle an alarm ring event.
  static void _handleAlarmRing(AlarmSettings alarmSettings) {
    log("Alarm triggered: ${alarmSettings.id}");
    AlarmData? currentAlarm = _getAlarmDataById(alarmSettings.id.toString());

    if (currentAlarm != null) {
      if (currentAlarm.selectedMission == "Default") {
        Get.to(() => AlarmRingScreen(
              alarmSettings: alarmSettings,
              alarmsData: currentAlarm,
            ));
      } else {
        Get.to(() => AlarmRingWithEquationScreen(
              alarmSettings: alarmSettings,
              showEasyEquation: currentAlarm.selectedMath == "easy",
              alarmsData: currentAlarm,
            ));
      }
    } else {
      log("No matching alarm found for ID: ${alarmSettings.id}");
      Alarm.stop(alarmSettings.id);
    }
  }

  /// Retrieve alarm data by ID.
  static AlarmData? _getAlarmDataById(String alarmId) {
    try {
      return alarmsData
          .firstWhere((alarm) => alarm.alarmId.toString() == alarmId);
    } catch (e) {
      log("Error retrieving alarm by ID: $e");
      return null;
    }
  }

  static AlarmData? getAlarmBySensorId(String sensorId) {
    try {
      log("Searching for alarm by sensor ID: $sensorId");

      String currentTimeFormatted =
          DateFormat('hh:mm a').format(DateTime.now());

      // Convert current time to a comparable DateTime object
      DateTime currentTime = _parse12HourTime(currentTimeFormatted);

      return alarmsData.firstWhere(
        (alarm) {
          if (alarm.sensorId == sensorId && alarm.optimalWakeTime != null) {
            DateTime alarmWakeTime = _parse12HourTime(alarm.optimalWakeTime!);
            return alarmWakeTime.isAfter(currentTime);
          }
          return false;
        },
        // orElse: () {
        //   log("No matching alarm found for sensor ID: $sensorId");
        //   // return ;
        // },
      );
    } catch (e) {
      log('Error retrieving alarm by sensor ID: $e');
      return null;
    }
  }

// Helper function to parse 12-hour formatted time into a DateTime object
  static DateTime _parse12HourTime(String time) {
    try {
      return DateFormat('hh:mm a').parse(time);
    } catch (e) {
      log('Error parsing time "$time": $e');
      throw FormatException('Invalid time format: $time');
    }
  }

  /// Fetches AlarmData by ID
  static AlarmData? getAlarmDataById(int alarmId) {
    return alarmsData.firstWhere(
      (alarm) => alarm.alarmId == alarmId,
      orElse: () => AlarmData(
          alarmId: 1,
          userId: "",
          beneficiaryId: "",
          bedtime: "",
          optimalWakeTime: "",
          name: "",
          isForBeneficiary: false,
          sensorId: ""),
    );
  }

  /// Builds alarm settings for a new alarm
  static AlarmSettings buildAlarmSettings(DateTime date, AlarmData alarm) {
    return AlarmSettings(
      id: alarm.alarmId,
      dateTime: date,
      loopAudio: true,
      vibrate: true,
      volume: 1,
      assetAudioPath: alarm.selectedSoundPath,
      notificationTitle: 'Alarm',
      notificationBody: 'Optimal time to WAKE UP',
    );
  }

  static Future<void> saveAlarm({
    required String userId,
    required String bedtime,
    required String optimalWakeTime,
    required String name,
    bool usertype = false,
    required String sensorId,
    required int alarmId,
  }) async {
    log("Starting saveAlarm: userId=$userId, bedtime=$bedtime, wakeTime=$optimalWakeTime");

    final prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString("alarms");
    List<AlarmData> alarmsList = [];

    if (jsonData != null) {
      try {
        List<dynamic> alarmList = jsonDecode(jsonData);
        alarmsList = alarmList.map((e) => AlarmData.fromJson(e)).toList();
        log("Existing alarms: $alarmsList");
      } catch (e) {
        log("Error decoding existing alarms: $e");
      }
    }

    // Fetch default settings
    Map<String, String> defaultSettings = await getDefaultSettings();

    AlarmData newAlarm = AlarmData(
      alarmId: alarmId,
      userId: userId,
      beneficiaryId: userId,
      bedtime: bedtime,
      optimalWakeTime: optimalWakeTime,
      name: name,
      isForBeneficiary: usertype,
      sensorId: sensorId,
      selectedSoundPath: defaultSettings['soundPath'] ?? 'default_sound.mp3',
      selectedMission: defaultSettings['mission'] ?? 'Default',
      selectedMath: defaultSettings['mathDifficulty'] ?? 'easy',
    );

    alarmsList.add(newAlarm);
    await prefs.setString(
      "alarms",
      jsonEncode(alarmsList.map((e) => e.toJson()).toList()),
    );

    DateTime now = DateTime.now();
    DateTime optimalWakeUpDate = DateFormat("hh:mm a").parse(optimalWakeTime);
    optimalWakeUpDate = DateTime(now.year, now.month, now.day,
        optimalWakeUpDate.hour, optimalWakeUpDate.minute);

    final alarmSettings = buildAlarmSettings(optimalWakeUpDate, newAlarm);
    await Alarm.set(alarmSettings: alarmSettings);
    log("Alarm scheduled for userId: $userId at ${DateFormat('hh:mm a').format(optimalWakeUpDate)}");
    await getAlarms();
  }

  static Future<void> updateAlarmSettings({
    required int alarmId,
    String? soundPath,
    String? mission,
    String? mathDifficulty,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString("alarms");

    if (jsonData != null && jsonData.isNotEmpty) {
      try {
        List<dynamic> alarmList = jsonDecode(jsonData);
        List<AlarmData> alarmsList =
            alarmList.map((e) => AlarmData.fromJson(e)).toList();

        AlarmData? alarmToUpdate = alarmsList.firstWhere(
          (alarm) => alarm.alarmId == alarmId,
          orElse: () => AlarmData(
              alarmId: 2,
              userId: "",
              beneficiaryId: "",
              bedtime: "",
              optimalWakeTime: "",
              name: "",
              isForBeneficiary: false,
              sensorId: ""),
        );

        if (alarmToUpdate != null) {
          if (soundPath != null) alarmToUpdate.selectedSoundPath = soundPath;
          if (mission != null) alarmToUpdate.selectedMission = mission;
          if (mathDifficulty != null)
            alarmToUpdate.selectedMath = mathDifficulty;

          await prefs.setString(
            "alarms",
            jsonEncode(alarmsList.map((e) => e.toJson()).toList()),
          );
          AppAlarm.initAlarms();
          await AppAlarm.getAlarms();
          log("Updated alarm settings for alarmId: $alarmId");
        } else {
          log("No alarm found with ID: $alarmId");
        }
      } catch (e) {
        log("Error updating alarm settings: $e");
      }
    }
  }

  /// Fetches all alarms
  static Future<void> getAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString("alarms");

    if (jsonData != null && jsonData.isNotEmpty) {
      try {
        List<dynamic> alarmList = jsonDecode(jsonData);
        alarmsData = alarmList.map((e) => AlarmData.fromJson(e)).toList();
        log("Loaded alarms: $alarmsData");
      } catch (e) {
        log("Error decoding alarms: $e");
      }
    } else {
      log("No alarms data found in SharedPreferences.");
    }
  }

  /// Clears all existing alarms
  static Future<void> clearExistingAlarm() async {
    var alarms = await Alarm.getAlarms();
    for (var alarm in alarms) {
      await Alarm.stop(alarm.id);
      log("Stopped alarm with ID: ${alarm.id}");
    }
  }

  /// Checks notification permissions for Android
  static Future<void> checkAndroidNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
      log("Notification permission requested.");
    } else {
      log("Notification permission already granted.");
    }
  }

  /// Checks exact schedule permission for Android
  static Future<void> checkAndroidScheduleExactAlarmPermission() async {
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
      log("Schedule exact alarm permission requested.");
    } else {
      log("Schedule exact alarm permission already granted.");
    }
  }

  static void updateStoredWakeUpAlarmSound() {
    try {
      if (alarmsData.isEmpty) {
        // تحقق إذا كانت قائمة المنبهات فارغة
        log("alarmsData is empty. Skipping update.");
        return;
      }

      // تكرار على جميع المنبهات في القائمة
      for (var alarm in alarmsData) {
        // جلب إعدادات المنبه بواسطة معرّف المنبه
        AlarmSettings? alarmSettings = Alarm.getAlarm(alarm.alarmId);
        if (alarmSettings != null) {
          alarmSettings =
              alarmSettings.copyWith(assetAudioPath: alarm.selectedSoundPath);
          Alarm.set(alarmSettings: alarmSettings);

          log("Alarm sound updated for Alarm ID: ${alarmSettings.id}");
        } else {
          log("No alarm settings found for Alarm ID: ${alarm.alarmId}");
        }
      }
    } catch (e) {
      log("Error updating alarm sounds: $e");
    }
  }

  static Future<void> loadAndUpdateOptimalBedtimeAndWakeAlarm({
    required int alarmId,
    String? newBedtime,
    String? newWakeTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Load existing alarms
    String? jsonData = prefs.getString("alarms");

    if (jsonData != null && jsonData.isNotEmpty) {
      try {
        List<dynamic> alarmList = jsonDecode(jsonData);
        List<AlarmData> alarmsList =
            alarmList.map((e) => AlarmData.fromJson(e)).toList();

        // Find the alarm for the specified alarmId
        AlarmData? alarmToUpdate = alarmsList.firstWhere(
          (alarm) => alarm.alarmId == alarmId,
          orElse: () => AlarmData(
            alarmId: 0,
            userId: "",
            beneficiaryId: "",
            bedtime: "",
            optimalWakeTime: "",
            name: "",
            isForBeneficiary: false,
            sensorId: "",
          ),
        );

        if (alarmToUpdate.alarmId != 0) {
          // Update bedtime and/or wake time if provided
          if (newBedtime != null) {
            alarmToUpdate.bedtime = newBedtime;
          }
          if (newWakeTime != null) {
            alarmToUpdate.optimalWakeTime = newWakeTime;
          }

          // Save the updated list back to SharedPreferences
          await prefs.setString(
            "alarms",
            jsonEncode(alarmsList.map((e) => e.toJson()).toList()),
          );

          log("Updated alarm for alarmId: $alarmId with new data: ${alarmToUpdate.toJson()}");

          // Re-schedule the alarm with the updated wake time
          DateTime now = DateTime.now();
          DateTime? updatedWakeTime;
          try {
            updatedWakeTime =
                DateFormat("hh:mm a").parse(alarmToUpdate.optimalWakeTime);
          } catch (e) {
            log("Failed to parse wake time: ${alarmToUpdate.optimalWakeTime}");
          }

          if (updatedWakeTime != null) {
            updatedWakeTime = DateTime(
              now.year,
              now.month,
              now.day,
              updatedWakeTime.hour,
              updatedWakeTime.minute,
            );

            final updatedAlarmSettings = buildAlarmSettings(
              updatedWakeTime,
              alarmToUpdate,
            );
            await Alarm.set(alarmSettings: updatedAlarmSettings);
            log("Rescheduled alarm for alarmId: $alarmId at ${DateFormat('hh:mm a').format(updatedWakeTime)}");
          }
        } else {
          log("No alarm found for alarmId: $alarmId");
        }
      } catch (e) {
        log("Error updating alarm for alarmId $alarmId: $e");
      }
    } else {
      log("No alarms data found in SharedPreferences.");
    }
  }

  static Future<void> loadAndUpdateAlarm({
    required String userId,
    String? newBedtime,
    String? newWakeTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Load existing alarms
    String? jsonData = prefs.getString("alarms");

    if (jsonData != null && jsonData.isNotEmpty) {
      try {
        List<dynamic> alarmList = jsonDecode(jsonData);
        List<AlarmData> alarmsList =
            alarmList.map((e) => AlarmData.fromJson(e)).toList();

        // Find the alarm for the specified userId
        AlarmData? alarmToUpdate = alarmsList.firstWhere(
          (alarm) => alarm.userId == userId,
          orElse: () => AlarmData(
              alarmId: 0,
              userId: "",
              beneficiaryId: "",
              bedtime: "",
              optimalWakeTime: "",
              name: "",
              isForBeneficiary: false,
              sensorId: ""),
        );

        if (alarmToUpdate != null) {
          // Update bedtime and/or wake time if provided
          if (newBedtime != null) {
            alarmToUpdate.bedtime = newBedtime;
          }
          if (newWakeTime != null) {
            // alarmToUpdate.optimalWakeTime = controller.calculateOptimalWakeUpTime(newBedtime, newWakeTime);
            alarmToUpdate.optimalWakeTime = newWakeTime;
          }

          // Save the updated list back to SharedPreferences
          await prefs.setString(
            "alarms",
            jsonEncode(alarmsList.map((e) => e.toJson()).toList()),
          );

          log("Updated alarm for userId: $userId with new data: ${alarmToUpdate.toJson()}");

          // Re-schedule the alarm with the updated wake time
          DateTime now = DateTime.now();
          DateTime updatedWakeTime =
              DateFormat("hh:mm a").parse(alarmToUpdate.optimalWakeTime);
          updatedWakeTime = DateTime(
            now.year,
            now.month,
            now.day,
            updatedWakeTime.hour,
            updatedWakeTime.minute,
          );

          final updatedAlarmSettings = buildAlarmSettings(
            updatedWakeTime,
            alarmToUpdate,
          );
          await Alarm.set(alarmSettings: updatedAlarmSettings);
          log("Rescheduled alarm for userId: $userId at ${DateFormat('hh:mm a').format(updatedWakeTime)}");
        } else {
          log("No alarm found for userId: $userId");
        }
      } catch (e) {
        log("Error updating alarm for userId $userId: $e");
      }
    } else {
      log("No alarms data found in SharedPreferences.");
    }
  }

  static Future<void> printAllAlarms() async {
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
}
