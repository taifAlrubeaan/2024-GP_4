import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleepwell/controllers/get_new_alarm_to_running.dart';
import 'package:sleepwell/models/sensor_model.dart';

import '../models/user_sensor.dart';
import '../widget/show_sensor_widget.dart';

class SensorSettingsController extends GetxController {
  final DatabaseReference sensorsDatabase =
      FirebaseDatabase.instance.ref().child('sensors');
  final DatabaseReference usersSensorsDatabase =
      FirebaseDatabase.instance.ref().child('usersSensors');

  var loading = true.obs;
  var sensorsCurrentUser = <String>[].obs;
  var selectedSensor = ''.obs;
  List<UserSensor> userSensors = [];
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  var sensorsIds = <String>[].obs;
  RxBool isSleeping = false.obs;
  var isCheckingReadings = false.obs;
  String sleepStartTime = '';

  double? previousTemperature;

  @override
  void onInit() {
    super.onInit();
    loadCachedSensors();
    loadSensors();
    listenToSensorChanges(selectedSensor.value);
  }

  Future<void> loadSensors() async {
    loading.value = true;
    userSensors = await getUserSensors(userId);
    sensorsCurrentUser.value = userSensors.map((e) => e.sensorId).toList();
    await cacheUserSensors();
    loading.value = false;
  }

  Future<void> checkUserSensors(BuildContext context) async {
    if (userId == null) {
      print("Error: User ID is null");
      return;
    }

    userSensors = await getUserSensors(userId);

    if (userSensors.isEmpty) {
      showAddSensorDialog(context);
    } else if (userSensors.length == 1) {
      selectedSensor = userSensors[0].sensorId.obs;
    } else {
      showSensorSelectionDialog(
        context: context,
        userSensors: sensorsCurrentUser
            .map((sensorId) =>
                UserSensor(sensorId: sensorId, userId: userId!, enable: true))
            .toList(),
        selectedSensorId: selectedSensor.value,
        onSensorSelected: selectSensor,
        onDeleteSensor: deleteSensor,
      );

      sensorsCurrentUser.clear();
      sensorsCurrentUser
          .addAll(userSensors.map((sensor) => sensor.sensorId).toList());
    }
    loading = false.obs;
  }

  Future<void> loadCachedSensors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedSensors = prefs.getString('userSensors');

    if (cachedSensors != null) {
      try {
        List<dynamic> sensorsList = jsonDecode(cachedSensors);
        userSensors = sensorsList
            .where((element) => element != null && element is Map)
            .map((e) => UserSensor.fromMap(e as Map<dynamic, dynamic>))
            .toList();
        sensorsCurrentUser.value = userSensors.map((e) => e.sensorId).toList();
      } catch (e) {
        print("Error decoding cached sensors: $e");
      }
    }
  }

  Future<void> cacheUserSensors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List sensorData = userSensors.map((sensor) => sensor.toMap()).toList();
    await prefs.setString('userSensors', jsonEncode(sensorData));
    print("User sensors cached successfully.");
  }

  Future<List<Sensor>> getAllSensors() async {
    DataSnapshot snapshot = await sensorsDatabase.get();
    List<Sensor> sensorsList = [];

    if (snapshot.exists) {
      Map<dynamic, dynamic> sensorData =
          snapshot.value as Map<dynamic, dynamic>;

      sensorData.forEach((key, value) {
        Sensor sensor = Sensor.fromMap(value as Map<dynamic, dynamic>);
        sensorsList.add(sensor);
        sensorsIds.add(sensor.sensorId);

        print(
            "Sensor ID: ${sensor.sensorId}, Heart Rate: ${sensor.heartRate}, SpO2: ${sensor.spO2}, Temperature: ${sensor.temperatura}");
      });
    }

    return sensorsList;
  }

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
    sensorsDatabase.onValue.listen((DatabaseEvent event) {
      try {
        final data = event.snapshot.value;
        if (data != null && data is Map<dynamic, dynamic>) {
          List<Sensor> sensorReadings = [];
          for (var value in data.values) {
            if (value is Map<dynamic, dynamic>) {
              sensorReadings.add(Sensor.fromMap(value));
            }
          }
          calculateSleepStartTimeFromReadings(sensorReadings, sensorId, 1 / 60);
        }
      } catch (error) {
        print("Error processing data: $error");
      } finally {
        isCheckingReadings.value = false;
      }
    }, onError: (error) {
      print("Error reading data: $error");
      isCheckingReadings.value = false;
    });
  }

  void calculateSleepStartTimeFromReadings(
      List<Sensor> sensors, String sensorId, double threshold) {
    Sensor sensor = sensors.firstWhere((sensor) => sensor.sensorId == sensorId);
    double currentTemperature = sensor.temperatura.toDouble();

    if (previousTemperature != null &&
        previousTemperature! - currentTemperature >= 1) {
      DateTime now = DateTime.now();
      print(
          "Temperature decreased by 1 degree or more. Current DateTime: $now");
    }

    previousTemperature = currentTemperature;
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

      if (userSensors.isNotEmpty) {
        this.userSensors = userSensors;
        await cacheUserSensors();
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

    await usersSensorsDatabase.push().set(sensorData);
    await loadSensors();
    _showSuccessDialog(context, 'Sensor added successfully.');
  }

  Future<void> deleteSensor(String sensorId) async {
    try {
      DataSnapshot snapshot = await usersSensorsDatabase.get();
      if (snapshot.exists) {
        Map<dynamic, dynamic> sensorsMap =
            snapshot.value as Map<dynamic, dynamic>;
        sensorsMap.forEach((key, value) async {
          if (value['sensorId'] == sensorId && value['userId'] == userId) {
            await usersSensorsDatabase.child(key).remove();
            userSensors.removeWhere((sensor) => sensor.sensorId == sensorId);
            await cacheUserSensors();
            sensorsCurrentUser.value =
                userSensors.map((e) => e.sensorId).toList();
          }
        });
      }
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
          title: const Text('Add Sensor'),
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
                    List<UserSensor> userSensors = await getUserSensors(userId);
                    if (userSensors
                        .any((sensor) => sensor.sensorId == sensorId)) {
                      _showErrorDialog(
                          context, 'This sensor is already assigned to you.');
                    } else {
                      await addUserSensor(userId!, sensorId, context);
                      Navigator.pop(context);
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
