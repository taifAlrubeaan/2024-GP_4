import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sleepwell/models/sensor_model.dart';
import 'package:sleepwell/services/alarm_service.dart';
import 'package:sleepwell/services/firebase_auth_service.dart';
import 'package:sleepwell/services/firebase_firestore_service.dart';
import '../alarm.dart';
import '../models/user_sensor.dart';
import '../push_notification_service.dart';
import 'update_optimal_bedtime_and_wakeuptime_alarm_service.dart';

class SensorService extends GetxService {
  final DatabaseReference sensorsDatabase =
      FirebaseDatabase.instance.ref().child('sensors');
  final DatabaseReference usersSensorsDatabase =
      FirebaseDatabase.instance.ref().child('usersSensors');
  final FirebaseFirestoreService firestoreService = FirebaseFirestoreService();
  final UpdateOptimalBedtimeAndWakeAlarmService updateOptimalAlarm =
      UpdateOptimalBedtimeAndWakeAlarmService();
  // var loading = true.obs;
  var sensorsCurrentUser = <String>[].obs;
  var selectedSensor = ''.obs;
  var selectedCurrentUser = ''.obs;
  List<UserSensor> userSensors = [];
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  var sensorsIds = <String>[].obs;
  RxBool isSleeping = false.obs;

  var sleepStartTime = ''.obs;

  double? previousTemperature;
  int? previousHeartRate;
  int? previousSpO2;
  final FirebaseAuthService authService = FirebaseAuthService();
  // /////////////////////////////////////////
  Sensor? previousSensorReading; // To store the previous sensor readings
  Timer? sensorCheckTimer; // Timer for periodic checks
  final int checkIntervalSeconds = 5; // Interval for checking in seconds
/////////////////////////////////////////
  // Async initializer for setting up SensorService
  Future<SensorService> init() async {
    // userId = FirebaseAuth.instance.currentUser?.uid;
    userId = authService.getUserId() ?? '';
    await loadSensors();
    authService.getUserId();
    log(userId!);
    log(userId!);
    log(userId.toString());
    // AlarmService().init();
// ////////////////////////
    // await isSensorReading(selectedSensor.value.obs.toString());
    if (userId != null && selectedSensor.value.isNotEmpty) {
      // bool loginStatus = prefs.getBool("isLogin") ?? false;
      // if (loginStatus) {
      await isSensorReading(selectedSensor.value.toString());
      log("${userId.toString()}==========${selectedSensor.value}");
      await getSelectedSensor();
      await startSensorReadingChecker();
// ////////////////////////
      listenToSensorChanges(selectedSensor.value.toString());
      AlarmService().init();
    }
    // }
    // Check if the selected sensor is reading and get its details

    return this;
  }

// ////////////////////////
  Future<void> startSensorReadingChecker() async {
    stopSensorReadingChecker(); // Stop any existing timer to avoid duplicates

    // Start a periodic timer
    sensorCheckTimer =
        Timer.periodic(Duration(seconds: checkIntervalSeconds), (timer) async {
      bool isReading = await isSensorActivelyReading(selectedSensor.value);
      log("Sensor ${selectedSensor.value} actively reading: $isReading");

      if (!isReading) {
        log("Sensor ${selectedSensor.value} stopped reading.");
      }
    });
  }

  // Stop the periodic sensor reading checker
  void stopSensorReadingChecker() {
    sensorCheckTimer?.cancel();
  }

  // Function to check if the sensor is actively reading
  Future<bool> isSensorActivelyReading(String sensorId) async {
    Sensor? currentSensorReading = await getSensorById(sensorId);

    if (currentSensorReading == null) {
      log("Sensor data unavailable.");
      return false;
    }

    // Check if current reading is different from the previous one
    bool isActivelyReading = previousSensorReading == null ||
        currentSensorReading.temperatura !=
            previousSensorReading!.temperatura ||
        currentSensorReading.heartRate != previousSensorReading!.heartRate ||
        currentSensorReading.spO2 != previousSensorReading!.spO2;

    // Update previous reading with the current one for the next comparison
    previousSensorReading = currentSensorReading;

    return isActivelyReading;
  }

  @override
  void onClose() {
    stopSensorReadingChecker(); // Ensure the timer is stopped when the service is disposed
    super.onClose();
  }
// Store previous readings for comparison

  // Future<bool> isSensorReading(String sensorId) async {
  //   Sensor? sensor = await getSensorById(sensorId);

  //   if (sensor != null) {
  //     // Check if the sensor is reading actively
  //     bool isReading =
  //         sensor.temperatura > 0 || sensor.heartRate > 0 || sensor.spO2 > 0;

  //     // Current readings
  //     int currentHeartRate = sensor.heartRate;
  //     int currentTemperature = sensor.temperatura.toInt();
  //     int currentSpO2 = sensor.spO2;

  //     // Compare current readings with previous readings
  //     bool readingsChanged = (previousHeartRate != currentHeartRate &&
  //             previousHeartRate != null) ||
  //         (previousTemperature != currentTemperature &&
  //             previousTemperature != null) ||
  //         (previousSpO2 != currentSpO2 && previousSpO2 != null);

  //     // Log readings for debugging
  //     log("Current Readings - Temperature: $currentTemperature, Heart Rate: $currentHeartRate, SpO2: $currentSpO2");
  //     log("Previous Readings - Temperature: $previousTemperature, Heart Rate: $previousHeartRate, SpO2: $previousSpO2");
  //     log("Sensor ${sensor.sensorId} is actively reading: $readingsChanged");

  //     // Update previous readings for the next check
  //     previousHeartRate = currentHeartRate;
  //     previousTemperature = currentTemperature.toDouble();
  //     previousSpO2 = currentSpO2;

  //     // Notify if sensor is actively reading or not
  //     await PushNotificationService.showNotification(
  //       title: 'Sensor Status',
  //       body: readingsChanged
  //           ? 'Selected sensor $sensorId is actively reading.'
  //           : 'Selected sensor $sensorId is not actively reading.',
  //       schedule: true,
  //       interval: 60,
  //     );

  //     return readingsChanged;
  //   } else {
  //     log("Sensor not found or inactive.");
  //     await PushNotificationService.showNotification(
  //       title: 'Sensor Unavailable',
  //       body: 'Sensor $sensorId is not reading. Please check the sensor.',
  //       schedule: true,
  //       interval: 60,
  //     );
  //     return false;
  //   }
  // }

  Future<bool> isSensorReading(String sensorId) async {
    Sensor? sensor = await getSensorById(sensorId);

    if (sensor == null) {
      log("Sensor not found or inactive.");
      await PushNotificationService.showNotification(
        title: 'Sensor Unavailable',
        body: 'Sensor $sensorId is not reading. Please check the sensor.',
        schedule: true,
        interval: 60,
      );
      return false;
    }
    // , bedtime=08:30 AM, wakeTime=01:12 PM
    // 10:18 AM
    // 11:48
    // Calculating with bedtime: 10:18 AM and wakeUpTime: 01:12 PM
    // Capture the initial reading
    int initialHeartRate = sensor.heartRate;
    int initialTemperature = sensor.temperatura.toInt();
    int initialSpO2 = sensor.spO2;

    log("Initial Readings - Temperature: $initialTemperature, Heart Rate: $initialHeartRate, SpO2: $initialSpO2");

    // Monitor readings for 3 minutes
    bool readingsChanged = false;

    for (int minute = 0; minute < 2; minute++) {
      await Future.delayed(const Duration(minutes: 1));

      // Fetch updated sensor reading
      Sensor? newSensorReading = await getSensorById(sensorId);
      if (newSensorReading == null) {
        log("Failed to retrieve sensor data at minute $minute.");
        continue;
      }

      // Current readings
      int currentHeartRate = newSensorReading.heartRate;
      int currentTemperature = newSensorReading.temperatura.toInt();
      int currentSpO2 = newSensorReading.spO2;

      log("Minute $minute - New Readings: Temperature: $currentTemperature, Heart Rate: $currentHeartRate, SpO2: $currentSpO2");

      // Compare with initial readings
      readingsChanged = (initialHeartRate != currentHeartRate) ||
          (initialTemperature != currentTemperature) ||
          (initialSpO2 != currentSpO2);

      if (readingsChanged) {
        log("Readings changed from initial values.");
        break;
      }
    }

    // Log the final status
    String status = readingsChanged
        ? 'Sensor $sensorId readings have changed within 2 minutes.'
        : 'Sensor $sensorId readings remained the same for 2 minutes.';
    log(status);

    // Notify results
    await PushNotificationService.showNotification(
      title: 'Sensor Status',
      body: status,
      schedule: true,
      interval: 60,
    );

    return readingsChanged;
  }

  // Function to retrieve and log the selected sensor details
  Future<void> getSelectedSensor() async {
    if (selectedSensor.value.isEmpty) {
      log("::::::::::::::::::::::No sensor is currently selected.:::::::::::::::::::::::::::");
      return;
    }

    Sensor? sensor = await getSensorById(selectedSensor.value);
    if (sensor != null) {
      log("::::::::::::::::::Selected Sensor ID: ${sensor.sensorId}:::::::::::::::::::::::::::::::");
      log("Selected Sensor ID: ${sensor.sensorId}, Temperature: ${sensor.temperatura}, Heart Rate: ${sensor.heartRate}, SpO2: ${sensor.spO2}");
      log("::::::::::::::::END ::Selected Sensor ID: ${sensor.sensorId}:::::::::::::::::::::::::::::::");
    } else {
      log(":???????????????:::::::Selected sensor data is unavailable.:::::::::::::::::::::::::::::::::::::::::");
    }
  }

// ////////////////////////

  Future<void> loadSensors() async {
    // loading.value = true;
    userSensors = await getUserSensors(userId);
    sensorsCurrentUser.value = userSensors.map((e) => e.sensorId).toList();
    await getSelectedSensorId();
    log('sensorsCurrentUser');
    log('sensorsCurrentUser${selectedSensor.value.obs.toString()}');
    log(selectedSensor.toString());
    log('sensorsCurrentUser2');
    // loading.value = false;
  }

  Future<void> getSelectedSensorId() async {
    if (userId == null) {
      print("Error: User ID is null");
      return;
    }
    if (userSensors.length == 1) {
      selectedSensor = userSensors[0].sensorId.obs;
    }
    if (userSensors.length > 1) {
      selectedSensor = selectedSensor.value.obs;
      // selectedSensor = selectedSensor.toString().obs;
    }
  }

  Future<Sensor?> getSensorById(String sensorId) async {
    try {
      DataSnapshot snapshot = await sensorsDatabase.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> sensorData =
            snapshot.value as Map<dynamic, dynamic>;

        for (var value in sensorData.values) {
          Sensor sensor = Sensor.fromMap(value as Map<dynamic, dynamic>);
          if (sensor.sensorId == sensorId) {
            print("Selected User Sensor ID: ${sensor.sensorId}");
            return sensor;
          }
        }
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  StreamSubscription? sensorSubscription;

// , bedtime=08:30 AM, wakeTime=01:12 PM
// Actual 10:18 AM  //wakeUpTime: 01:12 PM
// Calculating with bedtime: 10:18 AM and wakeUpTime: 01:12 PM
// 182
// 1
//
  void listenToSensorChanges(
    String sensorId, {
    Duration scanDuration = const Duration(minutes: 3),
    Duration preModificationDelay = const Duration(seconds: 4),
  }) {
    // Cancel any existing subscription to prevent multiple listeners
    sensorSubscription?.cancel();

    bool isSensorDataReceived = false; // Flag to check if data is received

    // Start a timer to stop listening after the specified duration
    Future.delayed(scanDuration, () async {
      if (!isSensorDataReceived) {
        log("No data received from sensor within $scanDuration. Using default bedtime and wakeup time.");

        try {
          // Fetch the default values for bedtime and optimal wakeup time
          int alarmId = findAlarmBySensor(sensorId);
          if (alarmId != -1) {
            String basicBedtime = getBasicBedtimeForAlarm(alarmId);
            String basicOptimalWakeTime = getWakeupTimeForAlarm(alarmId);

            // Add pre-modification delay before updating values
            await Future.delayed(preModificationDelay);

            String updatedWakeupTime = updateOptimalAlarm
                .calculateOptimalWakeUpTime(basicBedtime, basicOptimalWakeTime);

            await firestoreService.updateBedtime(
              newBedtime: basicBedtime,
              newOptimalWakeUpTime: updatedWakeupTime,
              alarmId: alarmId,
            );

            await AppAlarm.loadAndUpdateOptimalBedtimeAndWakeAlarm(
              alarmId: alarmId,
              newBedtime: basicBedtime,
              newWakeTime: updatedWakeupTime,
            );

            await PushNotificationService.showNotification(
              title: 'Default Alarm Restored',
              body:
                  'No readings received. Your bedtime is set to $basicBedtime, and wakeup time is $updatedWakeupTime.',
              schedule: false,
            );

            log("Restored default alarm: Bedtime: $basicBedtime, Wakeup: $basicOptimalWakeTime");
          } else {
            log("No alarm found for sensor $sensorId.");
          }
        } catch (e) {
          log("Error restoring default alarm: $e");
        }
      }

      // Stop the listener
      sensorSubscription?.cancel();
    });

    // Begin listening to the sensor data
    sensorSubscription =
        sensorsDatabase.onValue.listen((DatabaseEvent event) async {
      try {
        final data = event.snapshot.value;

        if (data == null) {
          log("Error: No data received from database.");
          return;
        }

        // Convert data to a list of sensor objects
        List<Sensor> sensorReadings = [];
        try {
          sensorReadings = convertObjectToLIst(data);
        } catch (e) {
          log("Error converting data to list: $e");
          return;
        }

        // Filter by selected sensor ID
        Sensor currentSensor = sensorReadings.firstWhere(
          (sensor) => sensor.sensorId == selectedSensor.value,
          orElse: () =>
              Sensor(sensorId: '', temperatura: 0, spO2: 0, heartRate: 0),
        );

        log('currentSensor: ${currentSensor.toMap()}');

        if (currentSensor.sensorId.isEmpty) {
          log("No matching sensor found for ID: ${selectedSensor.value}");
          return;
        }

        // Process sensor data safely
        double currentTemperature = currentSensor.temperatura.toDouble();
        int currentHeartRate = currentSensor.heartRate;

        bool hasTemperatureDecreased = previousTemperature != null &&
            previousTemperature! > currentTemperature;

        bool hasHeartRateDecreased = previousHeartRate != null &&
            currentHeartRate <= previousHeartRate! * 0.8;

        // Flag to ensure notifications are sent only once
        bool notificationSent = false;

        if (!notificationSent &&
            (hasTemperatureDecreased || hasHeartRateDecreased)) {
          notificationSent =
              true; // Set flag to true to prevent duplicate notifications
          DateTime now = DateTime.now();

          try {
            isSensorDataReceived = true; // Mark that data was received
            int alarmId = findAlarmBySensor(currentSensor.sensorId);
            if (alarmId != -1) {
              String newBedtime = DateFormat('hh:mm a').format(now);

              // Safely fetch wake-up time
              String wakeupTimeString = getWakeupTimeForAlarm(alarmId);
              if (wakeupTimeString.isEmpty ||
                  !RegExp(r'^\d{1,2}:\d{2} (AM|PM)$')
                      .hasMatch(wakeupTimeString)) {
                throw FormatException(
                    "Invalid wakeup time format: $wakeupTimeString");
              }

              // Add pre-modification delay before updating values
              await Future.delayed(preModificationDelay);

              String updatedWakeupTime = updateOptimalAlarm
                  .calculateOptimalWakeUpTime(newBedtime, wakeupTimeString);

              await firestoreService.updateBedtime(
                newBedtime: newBedtime,
                newOptimalWakeUpTime: updatedWakeupTime,
                alarmId: alarmId,
              );

              await AppAlarm.loadAndUpdateOptimalBedtimeAndWakeAlarm(
                alarmId: alarmId,
                newBedtime: newBedtime,
                newWakeTime: updatedWakeupTime,
              );

              await PushNotificationService.showNotification(
                title: 'Alarm Updated',
                body:
                    'Your sleep time was updated to $newBedtime and optimal wakeup time is $updatedWakeupTime.',
                schedule: false,
              );
              log("Updated alarm: Bedtime: $newBedtime, Wakeup: $updatedWakeupTime");

              // Stop listening once bedtime is sent
              sensorSubscription?.cancel();
            } else {
              log("No alarm associated with sensor ${currentSensor.sensorId}");
            }
          } catch (e) {
            log("Error updating Optimal alarm: $e");
          }
        }

        // Update previous values
        previousTemperature = currentTemperature;
        previousHeartRate = currentHeartRate;
      } catch (e, stackTrace) {
        log("Unexpected error: $e");
        log("Stack trace: $stackTrace");
      }
    }, onError: (error) {
      log("Error reading sensor data: $error");
    });
  }

//   void listenToSensorChanges(String sensorId,
//       {Duration scanDuration = const Duration(minutes: 3)}) {
//     // Cancel any existing subscription to prevent multiple listeners
//     sensorSubscription?.cancel();

//     bool isSensorDataReceived = false; // Flag to check if data is received

//     // Start a timer to stop listening after the specified duration
//     Future.delayed(scanDuration, () async {
//       if (!isSensorDataReceived) {
//         log("No data received from sensor within $scanDuration. Using default bedtime and wakeup time.");

//         try {
//           // Fetch the default values for bedtime and optimal wakeup time
//           int alarmId = findAlarmBySensor(sensorId);
//           if (alarmId != -1) {
//             String basicBedtime = getBasicBedtimeForAlarm(alarmId);
//             // String basicOptimalWakeTime = getBasicOptimalWakeupTimeForAlarm(alarmId);
//             String basicOptimalWakeTime = getWakeupTimeForAlarm(alarmId);

//             // Update the values with default bedtime and wake time
//             String wakeupTimeString = getWakeupTimeForAlarm(alarmId);
//             if (wakeupTimeString.isEmpty ||
//                 !RegExp(r'^\d{1,2}:\d{2} (AM|PM)$')
//                     .hasMatch(wakeupTimeString)) {
//               throw FormatException(
//                   "Invalid wakeup time format: $wakeupTimeString");
//             }
// //////////////////////////////////
//             String updatedWakeupTime = updateOptimalAlarm
//                 .calculateOptimalWakeUpTime(basicBedtime, basicOptimalWakeTime);

//             await firestoreService.updateBedtime(
//               newBedtime: basicBedtime,
//               newOptimalWakeUpTime: updatedWakeupTime,
//               alarmId: alarmId,
//             );

//             await AppAlarm.loadAndUpdateOptimalBedtimeAndWakeAlarm(
//               alarmId: alarmId,
//               newBedtime: basicBedtime,
//               newWakeTime: updatedWakeupTime,
//             );
//             // //////////////////////////////////

//             await PushNotificationService.showNotification(
//               title: 'Default Alarm Restored',
//               body:
//                   'No readings received. Your bedtime is set to $basicBedtime, and wakeup time is $updatedWakeupTime.',
//               schedule: false,
//             );

//             log("Restored default alarm: Bedtime: $basicBedtime, Wakeup: $basicOptimalWakeTime");
//           } else {
//             log("No alarm found for sensor $sensorId.");
//           }
//         } catch (e) {
//           log("Error restoring default alarm: $e");
//         }
//       }

//       // Stop the listener
//       sensorSubscription?.cancel();
//     });

//     // Begin listening to the sensor data
//     sensorSubscription =
//         sensorsDatabase.onValue.listen((DatabaseEvent event) async {
//       try {
//         final data = event.snapshot.value;

//         if (data == null) {
//           log("Error: No data received from database.");
//           return;
//         }

//         // Convert data to a list of sensor objects
//         List<Sensor> sensorReadings = [];
//         try {
//           sensorReadings = convertObjectToLIst(data);
//         } catch (e) {
//           log("Error converting data to list: $e");
//           return;
//         }

//         // Filter by selected sensor ID
//         Sensor currentSensor = sensorReadings.firstWhere(
//           (sensor) => sensor.sensorId == selectedSensor.value,
//           orElse: () =>
//               Sensor(sensorId: '', temperatura: 0, spO2: 0, heartRate: 0),
//         );

//         log('currentSensor: ${currentSensor.toMap()}');

//         if (currentSensor.sensorId.isEmpty) {
//           log("No matching sensor found for ID: ${selectedSensor.value}");
//           return;
//         }

//         // Process sensor data safely
//         double currentTemperature = currentSensor.temperatura.toDouble();
//         int currentHeartRate = currentSensor.heartRate;

//         bool hasTemperatureDecreased = previousTemperature != null &&
//             previousTemperature! > currentTemperature;

//         bool hasHeartRateDecreased = previousHeartRate != null &&
//             currentHeartRate <= previousHeartRate! * 0.8;

//         // Flag to ensure notifications are sent only once
//         bool notificationSent = false;

//         if (!notificationSent &&
//             (hasTemperatureDecreased || hasHeartRateDecreased)) {
//           notificationSent =
//               true; // Set flag to true to prevent duplicate notifications
//           DateTime now = DateTime.now();

//           try {
//             isSensorDataReceived = true; // Mark that data was received
//             int alarmId = findAlarmBySensor(currentSensor.sensorId);
//             if (alarmId != -1) {
//               String newBedtime = DateFormat('hh:mm a').format(now);

//               // Safely fetch wake-up time
//               String wakeupTimeString = getWakeupTimeForAlarm(alarmId);
//               if (wakeupTimeString.isEmpty ||
//                   !RegExp(r'^\d{1,2}:\d{2} (AM|PM)$')
//                       .hasMatch(wakeupTimeString)) {
//                 throw FormatException(
//                     "Invalid wakeup time format: $wakeupTimeString");
//               }

//               String updatedWakeupTime = updateOptimalAlarm
//                   .calculateOptimalWakeUpTime(newBedtime, wakeupTimeString);

//               await firestoreService.updateBedtime(
//                 newBedtime: newBedtime,
//                 newOptimalWakeUpTime: updatedWakeupTime,
//                 alarmId: alarmId,
//               );

//               await AppAlarm.loadAndUpdateOptimalBedtimeAndWakeAlarm(
//                 alarmId: alarmId,
//                 newBedtime: newBedtime,
//                 newWakeTime: updatedWakeupTime,
//               );

//               await PushNotificationService.showNotification(
//                 title: 'Alarm Updated',
//                 body:
//                     'Your sleep time was updated to $newBedtime and optimal wakeup time is $updatedWakeupTime.',
//                 schedule: false,
//               );
//               log("Updated alarm: Bedtime: $newBedtime, Wakeup: $updatedWakeupTime");

//               // Stop listening once bedtime is sent
//               sensorSubscription?.cancel();
//             } else {
//               log("No alarm associated with sensor ${currentSensor.sensorId}");
//             }
//           } catch (e) {
//             log("Error updating Optimal alarm: $e");
//           }
//         }

//         // Update previous values
//         previousTemperature = currentTemperature;
//         previousHeartRate = currentHeartRate;
//       } catch (e, stackTrace) {
//         log("Unexpected error: $e");
//         log("Stack trace: $stackTrace");
//       }
//     }, onError: (error) {
//       log("Error reading sensor data: $error");
//     });
//   }

  String getWakeupTimeForAlarm(int alarmId) {
    // alarmId = 9498;
    final alarm = AppAlarm.getAlarmDataById(alarmId);
    log("::::::::::: alarmId: $alarmId");
    log(alarm!.optimalWakeTime.toString().trim());
    if (alarm == null || alarm.optimalWakeTime.isEmpty) {
      log("Invalid or missing wake-up time for alarm ID: $alarmId");
      return ''; // Return an empty string to handle gracefully in the caller.
    }
    return alarm.optimalWakeTime;
  }

  int findAlarmBySensor(String sensorId) {
    // Query local alarm database to find the alarm linked to the given sensor ID
    final alarm = AppAlarm.getAlarmBySensorId(sensorId);
    return alarm?.alarmId ?? -1;
  }

  String getBasicBedtimeForAlarm(int alarmId) {
    // alarmId = 9498;
    final alarm = AppAlarm.getAlarmDataById(alarmId);
    log("::::::::::: alarmId: $alarmId");
    log(alarm!.bedtime.toString().trim());
    if (alarm == null || alarm.bedtime.isEmpty) {
      log("Invalid or missing Basic Bedtime  for alarm ID: $alarmId");
      return ''; // Return an empty string to handle gracefully in the caller.
    }
    return alarm.bedtime;
  }

// ///////////////////////////////////////////////
  List<Sensor> convertObjectToLIst(Object? data) {
    List<Sensor> sensorReadings = [];
    if (data != null && data is Map<dynamic, dynamic>) {
      for (var value in data.values) {
        if (value is Map<dynamic, dynamic>) {
          sensorReadings.add(Sensor.fromMap(value));
        }
      }
    }
    return sensorReadings;
  }

  Future<List<UserSensor>> getUserSensors(String? userId) async {
    try {
      DataSnapshot snapshot = await usersSensorsDatabase.get();
      List<UserSensor> userSensors = [];

      if (snapshot.exists) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          Map<dynamic, dynamic> sensorData = value as Map<dynamic, dynamic>;
          if (sensorData['userId'] == userId &&
              sensorData.containsKey('sensorId')) {
            userSensors.add(UserSensor.fromMap(sensorData));
            log("User ID: ${sensorData['userId']},userSensors $userSensors  Sensor ID: ${sensorData['sensorId']}");
          }
        });
      }

      return userSensors;
    } catch (e) {
      print(e);
      if (userId == null) {
        return [];
      }
      return [];
    }
  }

  void selectSensor(String sensorId) {
    selectedSensor.value = sensorId;
    loadSensors();
  }

  void selectUsers(String selectUsers) {
    selectedCurrentUser.value = selectUsers;
  }
}
