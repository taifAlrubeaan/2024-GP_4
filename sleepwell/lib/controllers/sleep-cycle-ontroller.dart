import 'dart:async';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../alarm.dart';
import '../services/firebase_auth_service.dart';
import '../services/firebase_firestore_service.dart';
import '../services/sensor_service.dart';

class SleepCycleController extends GetxController {
  // Observables for bedtime and wake-up time
  var bedtime = DateTime.now().obs;
  var wakeUpTime = DateTime.now().obs;
  var numOfCycles = 2.obs; // Default number of sleep cycles
  var remainingMinutes = 0.obs;
  //is loading state
  var loading = false.obs;

  //start
  final FirebaseAuthService authService = FirebaseAuthService();
  final FirebaseFirestoreService firestoreService = FirebaseFirestoreService();

  late TextEditingController bedtimeController;
  late TextEditingController wakeUpTimeController;
  // late TimeOfDay selectedBedtime;
  // late TimeOfDay selectedWakeUpTime;

  String printedNumOfCycles = '';
  RxString userId = ''.obs;
  RxString selectedBeneficiaryId = ''.obs; //end
  RxString selectedBeneficiaryName = ''.obs; //end
  final sensorService = Get.find<SensorService>();
  @override
  void onInit() {
    super.onInit();
    bedtimeController = TextEditingController();
    wakeUpTimeController = TextEditingController();

    userId.value = authService.getUserId() ?? '';

    update(); // Use GetX's update to trigger UI updates.
  }

  // Setters for bedtime and wake-up time
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

  // Function to calculate the number of cycles between bedtime and wake-up time

  int calculateSleepDuration() {
    // حساب الفرق بين وقت النوم ووقت الاستيقاظ بالدقائق
    int duration = wakeUpTime.value.difference(bedtime.value).inMinutes.abs();
    int cycleDurationMinutes = 90;

    // استخراج الساعات والدقائق من الفرق
    int hours = duration ~/ 60; // عدد الساعات
    int minutes = duration % 60; // عدد الدقائق

    // حساب عدد الدورات وتخزين الباقي
    numOfCycles.value = (duration ~/ cycleDurationMinutes);
    remainingMinutes.value = duration % cycleDurationMinutes;

    print('$hours hours and $minutes minutes');
    print('Number of cycles: ${numOfCycles.value}');
    print('Remaining minutes: $remainingMinutes');

    return numOfCycles.value;
  }

  int calculateremainingMinutes(bedtime, wakeUpTime) {
    // حساب الفرق بين وقت النوم ووقت الاستيقاظ بالدقائق
    int duration = wakeUpTime.value.difference(bedtime.value).inMinutes.abs();
    int cycleDurationMinutes = 90;

    // استخراج الساعات والدقائق من الفرق
    int hours = duration ~/ 60; // عدد الساعات
    int minutes = duration % 60; // عدد الدقائق

    // حساب عدد الدورات وتخزين الباقي
    numOfCycles.value = (duration ~/ cycleDurationMinutes);
    remainingMinutes.value = duration % cycleDurationMinutes;

    print('$hours hours and $minutes minutes');
    print('Number of cycles: ${numOfCycles.value}');
    print('Remaining minutes: $remainingMinutes');

    return remainingMinutes.value;
  }

  // Optional: If you want to reset the sleep cycle settings to default
  void resetSleepCycle() {
    bedtime.value = DateTime.now();
    wakeUpTime.value = DateTime.now();
    numOfCycles.value = 2; // Reset to default number of cycles
  }

  Future<void> saveTimes() async {
    try {
      loading.value = true;
      numOfCycles.value = calculateSleepDuration();
      sensorService.sensorsCurrentUser.value;
      print(sensorService.sensorsCurrentUser.value);
      print(':::::::::::::::::::::');
      sensorService.userSensors.toString();
      print(sensorService.userSensors.toString());
      print(':::::::::::::::::::::');
      // Save to Firestore using the service
      await firestoreService.saveAlarm(
        DateFormat('hh:mm a').format(wakeUpTime.value),
        DateFormat('hh:mm a').format(bedtime.value),
        calculateSleepDuration().toString(),
        userId.value,
        selectedBeneficiaryId.value,
        userId.value == selectedBeneficiaryId.value,
        sensorService.selectedSensor.value,
      );

      // await AppAlarm.saveAlarm(
      // DateFormat('hh:mm a').format(bedtime.value).toString(),
      // DateFormat('hh:mm a').format(wakeUpTime.value),
      //   selectedBeneficiaryId.value,
      // );
      DateTime now = DateTime.now();
      print(now);
      await AppAlarm.saveAlarm(
        bedtime: DateFormat('hh:mm a').format(bedtime.value).toString(),
        optimalWakeTime: DateFormat('hh:mm a').format(wakeUpTime.value),
        userId: selectedBeneficiaryId.value,
        usertype: userId.value == selectedBeneficiaryId.value,
        name: selectedBeneficiaryName.value,
        sensorId: sensorService.selectedSensor.value,
      );
      await AppAlarm.getAlarms();
      loading.value = false;
      Future.delayed(const Duration(seconds: 1), () {
        Get.back();
      });
    } catch (e) {
      print("Error saving times: $e");

      loading.value = false;
    }
    Get.back();
  }

  int calculateSleepTimeInMinutes() {
    int bedtimeMinutes = bedtime.value.hour * 60 + bedtime.value.minute;
    int wakeUpTimeMinutes =
        wakeUpTime.value.hour * 60 + wakeUpTime.value.minute;

    if (wakeUpTimeMinutes < bedtimeMinutes) {
      wakeUpTimeMinutes += 24 * 60;
    }
    int numberOfCycles = (wakeUpTimeMinutes - bedtimeMinutes / 90).floor();

    return numberOfCycles;
  }
}
