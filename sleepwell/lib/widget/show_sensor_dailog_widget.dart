import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleepwell/models/user_sensor.dart';
import '../controllers/sensor_settings_controller.dart';
import '../main.dart';
import '../services/sensor_service.dart';

class ShowSensorDialogWidget extends StatefulWidget {
  final List<UserSensor> userSensors;
  final String? selectedSensorId;
  final Function(String) onSensorSelected;
  final Function(String) onDeleteSensor;

  const ShowSensorDialogWidget({
    Key? key,
    required this.userSensors,
    required this.selectedSensorId,
    required this.onSensorSelected,
    required this.onDeleteSensor,
  }) : super(key: key);

  @override
  _ShowSensorDialogWidgetState createState() => _ShowSensorDialogWidgetState();
}

class _ShowSensorDialogWidgetState extends State<ShowSensorDialogWidget> {
  String? _selectedSensorId;
  final sensorService = Get.find<SensorService>();
  final sensorSettings = Get.find<SensorSettingsController>();

  // Store selected sensor in SharedPreferences
  Future<void> _storeSelectedSensorId(String sensorId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedSensorId', sensorId);
  }

  // Retrieve selected sensor from SharedPreferences
  Future<void> _getSelectedSensorId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedSensorId = prefs.getString('selectedSensorId');
    });
  }

  // Set selected sensor
  void _sensorSelected(String sensorId) {
    setState(() {
      _selectedSensorId = sensorId;
    });
    widget.onSensorSelected(sensorId);
    print('Selected Sensor: $sensorId');

    // Store sensor in SharedPreferences
    _storeSelectedSensorId(sensorId);
  }

  Future<void> _checkSensorReading(String sensorId) async {
    log("Selected User Sensor ID: $sensorId");

    // Fetch initial readings
    final initialSensor = await sensorService.getSensorById(sensorId);
    if (initialSensor == null) {
      log("Sensor $sensorId not found or unavailable.");
      return;
    }

    int initialTemperature = initialSensor.temperatura.toInt();
    int initialHeartRate = initialSensor.heartRate;
    int initialSpO2 = initialSensor.spO2;

    log("Initial Readings - Temperature: $initialTemperature, Heart Rate: $initialHeartRate, SpO2: $initialSpO2");

    // Wait for 1 minute while showing a CircularProgressIndicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
          title: Text('Scanning Sensor'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Monitoring sensor for 1 minute...'),
            ],
          ),
        );
      },
    );

    await Future.delayed(const Duration(minutes: 1));

    // Fetch new readings
    final newSensor = await sensorService.getSensorById(sensorId);
    if (newSensor == null) {
      Navigator.pop(context);
      log("Sensor $sensorId not found or unavailable after 1 minute.");
      return;
    }

    int newTemperature = newSensor.temperatura.toInt();
    int newHeartRate = newSensor.heartRate;
    int newSpO2 = newSensor.spO2;

    log("Minute 1 - New Readings: Temperature: $newTemperature, Heart Rate: $newHeartRate, SpO2: $newSpO2");

    // Close progress dialog
    Navigator.pop(context);

    // Display comparison results
    bool isChanged = (initialTemperature != newTemperature) ||
        (initialHeartRate != newHeartRate) ||
        (initialSpO2 != newSpO2);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sensor Comparison for $sensorId'),
        content: Text(
          isChanged
              ? 'Sensor $sensorId reading: $isChanged\n'
                  'Readings have changed:\n'
                  '- Temperature: $initialTemperature -> $newTemperature\n'
                  '- Heart Rate: $initialHeartRate -> $newHeartRate\n'
                  '- SpO2: $initialSpO2 -> $newSpO2'
              : 'No changes detected in sensor readings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Delete sensor from the database
  void _deleteSensorFromDatabase(String sensorId) {
    print('Sensor deleted: $sensorId');
    setState(() {
      widget
          .onDeleteSensor(sensorId); // Call the provided delete sensor function
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedSensorId = widget.selectedSensorId;
    _getSelectedSensorId(); // Retrieve the stored sensor on dialog start
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.7,
      initialChildSize: 0.5,
      minChildSize: 0.3,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text(
                      'Available Devices',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      PopupMenuButton(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 'add_sensor') {
                            sensorSettings.showAddSensorDialog(context);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'add_sensor',
                            child: Row(
                              children: [
                                Icon(Icons.add_alarm, color: Colors.black),
                                SizedBox(width: 8),
                                Text('Add New Sensor Device'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: widget.userSensors.length,
                  itemBuilder: (context, index) {
                    final userSensor = widget.userSensors[index];
                    return ListTile(
                      title: Text("Sensor ${userSensor.sensorId}"),
                      leading: _selectedSensorId == userSensor.sensorId
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.radio_button_unchecked),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle,
                                color: Colors.blue),
                            onPressed: () {
                              _checkSensorReading(
                                  sensorService.selectedSensor.value);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteSensorFromDatabase(userSensor.sensorId!);
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        _sensorSelected(userSensor.sensorId!);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Function to show the sensor selection dialog
void showSensorSelectionDialog({
  required BuildContext context,
  required List<UserSensor> userSensors,
  required Rx<String> selectedSensorId, // Store the selected sensor
  required Function(String) onSensorSelected,
  required Function(String) onDeleteSensor,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return ShowSensorDialogWidget(
        userSensors: userSensors,
        selectedSensorId: selectedSensorId.value,
        onSensorSelected: onSensorSelected,
        onDeleteSensor: onDeleteSensor,
      );
    },
  );
}
