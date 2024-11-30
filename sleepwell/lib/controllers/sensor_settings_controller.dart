import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sleepwell/models/sensor_model.dart';
import '../models/user_sensor.dart';
import '../services/sensor_service.dart';
// import '../widget/show_sensor_widget.dart';
import '../widget/show_sensor_dailog_widget.dart';

//
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
    await sensorService.getUserSensors(userId);
    await sensorService.loadSensors();
    userSensors = await sensorService.getUserSensors(userId!);
    log('userSensors $userId $userSensors');
    if (userSensors.isNotEmpty) {
      await sensorService.loadSensors();
      selectedSensor = sensorService.selectedSensor.value.obs;
      await sensorService.getUserSensors(userId!);
      showSensorSelectionDialog(
        context: context,

        userSensors: sensorService.sensorsCurrentUser
            .map((sensorId) =>
                UserSensor(sensorId: sensorId, userId: userId!, enable: true))
            .toList(),
        selectedSensorId: sensorService.selectedSensor.value.obs,
        onSensorSelected: sensorService.selectSensor,
        // onDeleteSensor: deleteSensor,
        onDeleteSensor: (sensorId) async {
          await showConfirmDeleteDialog(context, sensorId);
        },
      );

      sensorsCurrentUser.clear();
      sensorsCurrentUser
          .addAll(userSensors.map((sensor) => sensor.sensorId).toList());
    } else {
      // } else {
      showAddSensorDialog(context);
    }
    await sensorService.loadSensors();
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

  Future<void> addUserSensor(
      String userId, String sensorId, BuildContext context) async {
    Map<String, dynamic> sensorData = {
      'sensorId': sensorId,
      'userId': userId,
      'enable': true,
    };

    await sensorService.usersSensorsDatabase.push().set(sensorData);

    _showSuccessDialog(context, 'Sensor added successfully.');
    await sensorService.loadSensors();
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
}
