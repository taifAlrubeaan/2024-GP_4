import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../alarm.dart';
import '../../services/sensor_service.dart';

class CyclesCalculationTestingController extends GetxController {
  Rx<DateTime> bedtime = DateTime.now().obs;
  Rx<DateTime> actualBedtime = DateTime.now().obs;
  Rx<DateTime> wakeUpTime = DateTime.now().obs;

  RxInt numberOfCycles = 0.obs;
  RxDouble sleepHours = 0.0.obs;
  RxDouble remainingMinutesToCompleteHour = 0.0.obs;
  RxDouble remainingMinutesToCompleteCycle = 0.0.obs;
  RxString optimalWakeTime = ''.obs;
  RxBool addedFifteenMinutes = false.obs;
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  final sensorService = Get.find<SensorService>();

  Future<void> calculateSleepCycles() async {
    DateTime adjustedWakeUpTime = wakeUpTime.value;

    // Adjust for next day if wake-up time is earlier than actual bedtime
    if (wakeUpTime.value.isBefore(actualBedtime.value)) {
      adjustedWakeUpTime = wakeUpTime.value.add(const Duration(days: 1));
    }

    final sleepDuration = adjustedWakeUpTime.difference(actualBedtime.value);

    sleepHours.value =
        sleepDuration.inHours + (sleepDuration.inMinutes % 60) / 60.0;
    numberOfCycles.value = (sleepDuration.inMinutes / 90).floor();
    remainingMinutesToCompleteCycle.value = sleepDuration.inMinutes % 90;

    // Check if the duration is a perfect multiple of 90 minutes
    addedFifteenMinutes.value = (sleepDuration.inMinutes % 90) != 0;

    // Set optimal wake time based on 90-minute sleep cycles
    final optimalCycleTime =
        actualBedtime.value.add(Duration(minutes: 90 * numberOfCycles.value));
    optimalWakeTime.value = DateFormat('hh:mm a').format(optimalCycleTime);

    remainingMinutesToCompleteHour.value = sleepDuration.inMinutes % 60;

    print('Sleep Duration (minutes): ${sleepDuration.inMinutes}');
    print('Number of Cycles: ${numberOfCycles.value}');
    print(
        'Remaining Minutes to Complete Cycle: ${remainingMinutesToCompleteCycle.value}');
    print('Sleep Hours: ${sleepHours.value}');
    print('Optimal Wake Time: ${optimalWakeTime.value}');
    print('Added Fifteen Minutes: ${addedFifteenMinutes.value}');

    // await AppAlarm.saveAlarm(
    //   alarmId: generateUniqueAlarmId(),
    //   bedtime: DateFormat('hh:mm a').format(bedtime.value).toString(),
    //   optimalWakeTime: optimalWakeTime.value,
    //   userId: userId.toString(),
    //   usertype: true,
    //   name: 'Yourself',
    //   sensorId: sensorService.selectedSensor.value,
    // );
    // await AppAlarm.getAlarms();
  }

  /// Generates a unique alarm ID
  static int generateUniqueAlarmId() {
    return DateTime.now().millisecondsSinceEpoch % 10000;
  }

  void setBedtime(DateTime time) {
    bedtime.value = time;
  }

  void setActualBedtime(DateTime time) {
    actualBedtime.value = time;
  }

  void setWakeUpTime(DateTime time) {
    wakeUpTime.value = time;
  }
}
