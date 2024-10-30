// import 'dart:async';
// import 'dart:ffi';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// import '../services/firebase_auth_service.dart';
// import '../services/firebase_firestore_service.dart';

// class AlarmSetupController extends GetxController {
//   final FirebaseAuthService authService = FirebaseAuthService();
//   final FirebaseFirestoreService firestoreService = FirebaseFirestoreService();

//   late TextEditingController bedtimeController;
//   late TextEditingController wakeUpTimeController;
//   late TimeOfDay selectedBedtime;
//   late TimeOfDay selectedWakeUpTime;
//   String printedBedtime = '';
//   String printedWakeUpTime = '';
//   String printedNumOfCycles = '';
//   RxInt numOfCycles = 0.obs;
//  var sensorId = ''.obs;
//   late DateTime _now;
//   late Timer _timer;
//   RxString userId = ''.obs;
//   RxString beneficiaryId = ''.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     bedtimeController = TextEditingController();
//     wakeUpTimeController = TextEditingController();
//     selectedBedtime = TimeOfDay.now();
//     selectedWakeUpTime = TimeOfDay.now();
//     _now = DateTime.now();
//     userId.value = authService.getUserId() ?? '';
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       _now = DateTime.now();
//       update(); // Use GetX's update to trigger UI updates.
//     });
//   }

//   @override
//   void onClose() {
//     bedtimeController.dispose();
//     wakeUpTimeController.dispose();
//     _timer.cancel();
//     super.onClose();
//   }

//   Future<void> saveTimes(String beneficiaryId) async {
//     TimeOfDay? selectedTime = selectedBedtime;

//     // Example of applying DRY principle by using a reusable method
//     int totalSleepTimeMinutes = calculateSleepTimeInMinutes();
//     int numberOfCycles = (totalSleepTimeMinutes / 90).floor();
//     numOfCycles.value = numberOfCycles;

//     // Save to Firestore using the service
//     await firestoreService.saveAlarm(
//       printedBedtime,
//       printedWakeUpTime,
//       numOfCycles.value.toString(),
//       userId.value,
//       beneficiaryId,
//       beneficiaryId.isEmpty,
//       sensorId.value,
//     );
//   }

//   int calculateSleepTimeInMinutes() {
//     int bedtimeMinutes = selectedBedtime.hour * 60 + selectedBedtime.minute;
//     int wakeUpTimeMinutes = selectedWakeUpTime.hour * 60 + selectedWakeUpTime.minute;

//     if (wakeUpTimeMinutes < bedtimeMinutes) {
//       wakeUpTimeMinutes += 24 * 60;
//     }

//     return wakeUpTimeMinutes - bedtimeMinutes;
//   }

//   String formatTime(TimeOfDay time) {
//     final now = DateTime.now();
//     final formattedTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
//     return DateFormat('hh:mm a').format(formattedTime);
//   }

//   // Add additional reusable methods for sleep time calculations and Firestore operations here
// }
