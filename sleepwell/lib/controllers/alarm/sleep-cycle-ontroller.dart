import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sleepwell/main.dart';
import 'package:sleepwell/screens/alarm_screen.dart';
import '../../alarm.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/firebase_firestore_service.dart';
import '../../services/sensor_service.dart';
import 'alarm_list__controller.dart';

class SleepCycleController extends GetxController {
  var bedtime = DateTime.now().obs;
  var wakeUpTime = DateTime.now().obs;
  var numOfCycles = 2.obs; // Default number of sleep cycles
  var remainingMinutes = 0.obs;
  var loading = false.obs;
  final AlarmListController listController = Get.put(AlarmListController());

  final FirebaseAuthService authService = FirebaseAuthService();
  final FirebaseFirestoreService firestoreService = FirebaseFirestoreService();
  late TextEditingController bedtimeController;
  late TextEditingController wakeUpTimeController;

  String printedNumOfCycles = '';
  RxString userId = ''.obs;
  RxString selectedBeneficiaryId = ''.obs;
  RxString selectedBeneficiaryName = ''.obs;
  // final sensorService = Get.find<SensorService>();

  @override
  void onInit() {
    super.onInit();
    bedtimeController = TextEditingController();
    wakeUpTimeController = TextEditingController();
    userId.value = getUserId() ?? '';
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? get currentUser => _firebaseAuth.currentUser;

  String? getUserId() {
    return currentUser?.uid;
  }

  void setBedtime(DateTime selectedTime) {
    bedtime.value = selectedTime;
  }

  void setWakeUpTime(DateTime selectedTime) {
    wakeUpTime.value = selectedTime;
  }

  void setBeneficiary(String id, String name) {
    selectedBeneficiaryId.value = id;
    selectedBeneficiaryName.value = name;
  }

  int calculateSleepDuration() {
    // Handle crossing midnight by adding a day to wakeUpTime if it's earlier than bedtime
    DateTime adjustedWakeUpTime = wakeUpTime.value;
    if (wakeUpTime.value.isBefore(bedtime.value)) {
      adjustedWakeUpTime = wakeUpTime.value.add(const Duration(days: 1));
    }

    int duration = adjustedWakeUpTime.difference(bedtime.value).inMinutes;
    int cycleDurationMinutes = 90;

    int hours = duration ~/ 60;
    int minutes = duration % 60;

    numOfCycles.value = duration ~/ cycleDurationMinutes;
    remainingMinutes.value = duration % cycleDurationMinutes;

    print('$hours hours and $minutes minutes');
    print('Number of cycles: ${numOfCycles.value}');
    print('Remaining minutes: $remainingMinutes');

    return numOfCycles.value;
  }

  /// Generates a unique alarm ID
  static int generateUniqueAlarmId() {
    return DateTime.now().millisecondsSinceEpoch % 10000;
  }

  // List<SensorService> runningServices = [];

  Future<void> saveTimes() async {
    try {
      loading.value = true;
      numOfCycles.value = calculateSleepDuration();
      int alarmId = generateUniqueAlarmId();
      // Create a new SensorService object for the operation
      final newSensorService = SensorService();
      await newSensorService
          .init(); // Initialize the sensor service (e.g., set up communication)
      final SensorService sensorService =
          Get.put(SensorService(), tag: newSensorService.selectedSensor.value);

      // Optionally, configure it with specific settings
      newSensorService.selectedSensor.value =
          sensorService.selectedSensor.value;

      // Add it to the list of running services
      runningServices.add(newSensorService);

      // Save alarm to Firestore
      await firestoreService.saveAlarm(
        DateFormat('hh:mm a').format(bedtime.value),
        DateFormat('hh:mm a').format(wakeUpTime.value),
        numOfCycles.value.toString(),
        userId.value,
        selectedBeneficiaryId.value,
        userId.value == selectedBeneficiaryId.value,
        newSensorService
            .selectedSensor.value, // Pass the sensor from the new instance
        alarmId,
      );

      // Save alarm locally
      await AppAlarm.saveAlarm(
        alarmId: alarmId,
        bedtime: DateFormat('hh:mm a').format(bedtime.value).toString(),
        optimalWakeTime: DateFormat('hh:mm a').format(wakeUpTime.value),
        userId: selectedBeneficiaryId.value,
        usertype: userId.value == selectedBeneficiaryId.value,
        name: selectedBeneficiaryName.value,
        sensorId: newSensorService
            .selectedSensor.value, // Use the new sensor instance
      );

      // Perform additional operations with the new sensor instance
      newSensorService.isSensorReading(newSensorService.selectedSensor.value);
      newSensorService
          .listenToSensorChanges(sensorService.selectedSensor.value);
      // Update UI and clean up
      loading.value = false;
      Future.delayed(const Duration(seconds: 1), () {
        Get.back();
      });

      listController.loadAlarms();
    } catch (e) {
      print("Error saving times: $e");
      loading.value = false;
    }

    // Navigate to AlarmScreen
    Get.back();
    Get.off(const AlarmScreen());
  }

  void resetSleepCycle() {
    bedtime.value = DateTime.now();
    wakeUpTime.value = DateTime.now();
    numOfCycles.value = 2;
  }

  Future<bool> checkIfHaveAlarms() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart
        .add(const Duration(days: 1))
        .subtract(const Duration(seconds: 1));

    String formattedendDayOfWackup =
        DateFormat('hh:mm a').format(DateTime.now());

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('alarms')
          .where('uid', isEqualTo: userId)
          .where('beneficiaryId', isEqualTo: selectedBeneficiaryId.value)
          .where('timestamp', isGreaterThanOrEqualTo: todayStart)
          .where('timestamp', isLessThanOrEqualTo: todayEnd)
          .where('wakeup_time',
              isGreaterThanOrEqualTo: formattedendDayOfWackup.toString())
          .orderBy('timestamp', descending: true)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error checking alarms: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAlarmDataForTodayBySensorId(
      String sensorId, DateTime userTime) async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart
          .add(const Duration(days: 1))
          .subtract(const Duration(seconds: 1));

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('alarms')
          .where('uid', isEqualTo: userId.value)
          .where('sensorId', isEqualTo: sensorId)
          .where('timestamp', isGreaterThanOrEqualTo: todayStart)
          .where('timestamp', isLessThanOrEqualTo: todayEnd)
          .get();

      List<Map<String, dynamic>> data = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> alarmData = doc.data() as Map<String, dynamic>;

        // Parsing wakeup_time and bed_time from the document
        DateTime wakeupTime =
            DateFormat('hh:mm a').parse(alarmData['wakeup_time']);
        DateTime bedTime = DateFormat('hh:mm a').parse(alarmData['bedtime']);

        // Check if userTime is between bedTime and wakeupTime
        if (userTime.isAfter(bedTime) && userTime.isBefore(wakeupTime)) {
          data.add(alarmData);
        }
      }

      print(' :::::::::::-----------Data for today: ${todayStart} ${todayEnd}');
      return data;
    } catch (e) {
      print(":::::::::::::::::-----------Error fetching data for today: $e");
      return [];
    }
  }
}
