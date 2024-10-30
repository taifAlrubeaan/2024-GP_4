import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sleepwell/models/sensor_model.dart';
import 'package:sleepwell/services/firebase_firestore_service.dart';

import '../alarm.dart';
import '../models/user_sensor.dart';

class SensorService extends GetxService {
  final DatabaseReference sensorsDatabase =
      FirebaseDatabase.instance.ref().child('sensors');
  final DatabaseReference usersSensorsDatabase =
      FirebaseDatabase.instance.ref().child('usersSensors');
  final FirebaseFirestoreService firestoreService = FirebaseFirestoreService();

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

  // Async initializer for setting up SensorService
  Future<SensorService> init() async {
    await loadSensors();

    listenToSensorChanges(selectedSensor.value);
    return this;
  }

  Future<void> loadSensors() async {
    // loading.value = true;
    userSensors = await getUserSensors(userId);
    sensorsCurrentUser.value = userSensors.map((e) => e.sensorId).toList();
    await getSelectedSensorId();
    log('sensorsCurrentUser');
    log(selectedSensor.toString());
    log('sensorsCurrentUser2');
    // loading.value = false;
  }

  Future<void> getSelectedSensorId() async {
    if (userId == null) {
      print("Error: User ID is null");
      return;
    }
    if (userSensors.isNotEmpty) {
      selectedSensor = userSensors[0].sensorId.obs;
    }
  }

  // Future<List<Sensor>> getAllSensors() async {
  //   DataSnapshot snapshot = await sensorsDatabase.get();
  //   List<Sensor> sensorsList = [];

  //   if (snapshot.exists) {
  //     Map<dynamic, dynamic> sensorData =
  //         snapshot.value as Map<dynamic, dynamic>;

  //     sensorData.forEach((key, value) {
  //       Sensor sensor = Sensor.fromMap(value as Map<dynamic, dynamic>);
  //       sensorsList.add(sensor);
  //       sensorsIds.add(sensor.sensorId);
  //     });
  //   }
  //   for (var sensor in sensorsList) {
  //     print(
  //         "Sensor ID: ${sensor.sensorId}, Heart Rate: ${sensor.heartRate}, SpO2: ${sensor.spO2}, Temperature: ${sensor.temperatura}");
  //   }

  //   return sensorsList;
  // }

  Future<Sensor?> getSensorById(String sensorId) async {
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

    return null;
  }

  void listenToSensorChanges(String sensorId) {
    sensorsDatabase.onValue.listen((DatabaseEvent event) async {
      final data = event.snapshot.value;

      // Convert data to a list of sensor objects
      List<Sensor> sensorReadings = convertObjectToLIst(data);
      // Filter by selected sensor ID
      Sensor currentSensor = sensorReadings.firstWhere(
        (sensor) => sensor.sensorId == selectedSensor.value,
        orElse: () =>
            Sensor(sensorId: '', temperatura: 0, spO2: 0, heartRate: 0),
      );
      print('currentSensor: ${currentSensor.toMap()}');
      if (currentSensor.sensorId.isNotEmpty) {
        double currentTemperature = currentSensor.temperatura.toDouble();
        int currentHeartRate = currentSensor.heartRate;

        bool hasDecreased = false;

        // Check if temperature has decreased
        if (previousTemperature != null &&
            previousTemperature! > currentTemperature) {
          hasDecreased = true;
          print(
              "Temperature decreased from $previousTemperature to $currentTemperature");
        }

        // Check if heart rate has decreased by 20% or more
        if (previousHeartRate != null &&
            currentHeartRate <= previousHeartRate! * 0.8) {
          hasDecreased = true;
          print(
              "Heart rate decreased by 20% or more from $previousHeartRate to $currentHeartRate");
        }

        // Print the datetime if any decrease was detected
        if (hasDecreased) {
          DateTime now = DateTime.now();

          print("Current DateTime: $now");
          await AppAlarm.loadAndUpdateAlarm(
            newBedtime: DateFormat('hh:mm a').format(now),
            userId: selectedCurrentUser.value.obs.toString(),
          );
          await AppAlarm.printAllAlarms();
          await firestoreService.updateBedtime(
            userId: selectedCurrentUser.value.obs.toString(),
            newBedtime: DateFormat('hh:mm a').format(now),
          );
        }

        // Update previous values for the next comparison
        previousTemperature = currentTemperature;
        previousHeartRate = currentHeartRate;
      }
    }, onError: (error) {
      print("Error reading data: $error");
    });
  }

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
    if (userId == null) {
      return [];
    }

    DataSnapshot snapshot = await usersSensorsDatabase.get();
    List<UserSensor> userSensors = [];

    if (snapshot.exists) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        Map<dynamic, dynamic> sensorData = value as Map<dynamic, dynamic>;
        if (sensorData['userId'] == userId &&
            sensorData.containsKey('sensorId')) {
          userSensors.add(UserSensor.fromMap(sensorData));
        }
      });
    }

    return userSensors;
  }

  void selectSensor(String sensorId) {
    selectedSensor.value = sensorId;
  }

  void selectUsers(String selectUsers) {
    selectedCurrentUser.value = selectUsers;
  }
}
