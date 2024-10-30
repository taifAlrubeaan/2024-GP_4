import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sleepwell/models/sensor_model.dart';

import '../models/user_sensor.dart';
import '../services/sensor_service.dart';
import '../widget/show_sensor_widget.dart';

class SensorSettingsController extends GetxController {
  final sensorService = Get.find<SensorService>();

  var loading = true.obs;
  var sensorsCurrentUser = <String>[].obs;
  var selectedSensor = ''.obs;
  List<UserSensor> userSensors = [];
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  var sensorsIds = <String>[].obs;
  RxBool isSleeping = false.obs;

  String sleepStartTime = '';

  double? previousTemperature;

  @override
  void onInit() {
    super.onInit();
    getAllSensors();
  }

  Future<void> checkUserSensors(BuildContext context) async {
    if (userId == null) {
      print("Error: User ID is null");
      return;
    }
    await sensorService.loadSensors();
    userSensors = await sensorService.getUserSensors(userId);

    if (userSensors.isEmpty) {
      showAddSensorDialog(context);
    } else {
      // } else {
      selectedSensor = userSensors[0].sensorId.obs;
      showSensorSelectionDialog(
        context: context,
        userSensors: sensorService.sensorsCurrentUser
            .map((sensorId) =>
                UserSensor(sensorId: sensorId, userId: userId!, enable: true))
            .toList(),
        selectedSensorId: selectedSensor.value,
        onSensorSelected: selectSensor,
        // onDeleteSensor: deleteSensor,
        onDeleteSensor: (sensorId) async {
          await showConfirmDeleteDialog(context, sensorId);
        },
      );

      sensorsCurrentUser.clear();
      sensorsCurrentUser
          .addAll(userSensors.map((sensor) => sensor.sensorId).toList());
    }
    loading = false.obs;
  }

  Future<List<Sensor>> getAllSensors() async {
    DataSnapshot snapshot = await sensorService.sensorsDatabase.get();
    List<Sensor> sensorsList = [];

    if (snapshot.exists) {
      Map<dynamic, dynamic> sensorData =
          snapshot.value as Map<dynamic, dynamic>;

      sensorData.forEach((key, value) {
        Sensor sensor = Sensor.fromMap(value as Map<dynamic, dynamic>);
        sensorsList.add(sensor);
        sensorsIds.add(sensor.sensorId);
      });
    }
    for (var sensor in sensorsList) {
      print(
          "Sensor ID: ${sensor.sensorId}, Heart Rate: ${sensor.heartRate}, SpO2: ${sensor.spO2}, Temperature: ${sensor.temperatura}");
    }

    return sensorsList;
  }

  Future<Sensor?> getSensorById(String sensorId) async {
    DataSnapshot snapshot = await sensorService.sensorsDatabase.get();

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

  // void listenToSensorChanges(String sensorId) {
  //   sensorsDatabase.onValue.listen((DatabaseEvent event) {
  //     try {
  //       final data = event.snapshot.value;
  //       if (data != null && data is Map<dynamic, dynamic>) {
  //         List<Sensor> sensorReadings = [];
  //         for (var value in data.values) {
  //           if (value is Map<dynamic, dynamic>) {
  //             sensorReadings.add(Sensor.fromMap(value));
  //           }
  //         }
  //         calculateSleepStartTimeFromReadings(sensorReadings, sensorId, 1 / 60);
  //       }
  //     } catch (error) {
  //       print("Error processing data: $error");
  //     } finally {}
  //   }, onError: (error) {
  //     print("Error reading data: $error");
  //   });
  // }

  // void calculateSleepStartTimeFromReadings(
  //     List<Sensor> sensors, String sensorId, double threshold) {
  //   Sensor sensor = sensors.firstWhere((sensor) => sensor.sensorId == sensorId);
  //   double currentTemperature = sensor.temperatura.toDouble();

  //   if (previousTemperature != null &&
  //       previousTemperature! - currentTemperature >= 1) {
  //     DateTime now = DateTime.now();
  //     print(
  //         "Temperature decreased by 1 degree or more. Current DateTime: $now");
  //   }

  //   previousTemperature = currentTemperature;
  // }

  Future<List<UserSensor>> getUserSensors(String? userId) async {
    if (userId == null) {
      return [];
    }

    DataSnapshot snapshot = await sensorService.usersSensorsDatabase.get();
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

      if (userSensors.isNotEmpty) {
        this.userSensors = userSensors;
      }
    }

    return userSensors;
  }

  Future<void> addUserSensor(
      String userId, String sensorId, BuildContext context) async {
    Map<String, dynamic> sensorData = {
      'sensorId': sensorId,
      'userId': userId,
      'enable': true,
    };

    await sensorService.usersSensorsDatabase.push().set(sensorData);

    _showSuccessDialog(context, 'Sensor added successfully.');
  }

  Future<void> deleteSensor(String sensorId) async {
    try {
      DataSnapshot snapshot = await sensorService.usersSensorsDatabase.get();
      if (snapshot.exists) {
        Map<dynamic, dynamic> sensorsMap =
            snapshot.value as Map<dynamic, dynamic>;
        sensorsMap.forEach((key, value) async {
          if (value['sensorId'] == sensorId && value['userId'] == userId) {
            await sensorService.usersSensorsDatabase.child(key).remove();
            userSensors.removeWhere((sensor) => sensor.sensorId == sensorId);

            sensorsCurrentUser.value =
                userSensors.map((e) => e.sensorId).toList();
          }
        });
      }
      Get.back();
    } catch (e) {
      print("Error deleting sensor: $e");
    }
  }

  void showAddSensorDialog(BuildContext context) {
    TextEditingController sensorIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Add Sensor'),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          content: TextField(
            controller: sensorIdController,
            decoration: const InputDecoration(hintText: 'Enter Sensor ID'),
          ),
          actions: [
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () async {
                String sensorId = sensorIdController.text.trim();
                if (sensorId.isNotEmpty) {
                  if (sensorsIds.contains(sensorId)) {
                    // List<UserSensor> userSensors = await getUserSensors(userId);

                    userSensors = await sensorService.getUserSensors(userId);
                    if (userSensors
                        .any((sensor) => sensor.sensorId == sensorId)) {
                      _showErrorDialog(
                          context, 'This sensor is already assigned to you.');
                    } else {
                      await addUserSensor(userId!, sensorId, context);
                      await sensorService.loadSensors();

                      // _showErrorDialog(context, 'Sensor Added Successfully');
                      // Navigator.pop(context);
                      // Navigator.pop(context);
                      Get.back();
                      Get.back();
                    }
                  } else {
                    _showErrorDialog(context, 'Sensor not found.');
                  }
                } else {
                  _showErrorDialog(context, 'Sensor ID cannot be empty.');
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: [
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                // Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showConfirmDeleteDialog(
      BuildContext context, String sensorId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Confirm Delete'),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              child: const Text('Confirm'),
              onPressed: () async {
                deleteSensor(sensorId);
                Get.back();
                // await deleteSensor(sensorId);
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  void selectSensor(String sensorId) {
    selectedSensor.value = sensorId;
  }
}
