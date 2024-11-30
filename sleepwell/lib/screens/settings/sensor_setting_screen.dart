import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sleepwell/controllers/sensor_settings_controller.dart';
import 'package:sleepwell/models/user_sensor.dart';
import '../../services/sensor_service.dart';
import '../../widget/show_sensor_widget.dart';

class SensorSettingScreen extends StatelessWidget {
  final sensorService = Get.find<SensorService>();
  final sensorSettings = Get.put(SensorSettingsController());

  SensorSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    sensorService.getSensorById(sensorService.selectedSensor.value);
    print(sensorService.selectedSensor.value);
    print('-----------------------------------------------');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Setting'),
      ),
      body: Obx(
        () {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: sensorService.sensorsCurrentUser.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                          'Sensor ID: ${sensorService.sensorsCurrentUser[index]}'),
                      onTap: () {
                        sensorService.selectSensor(
                            sensorService.sensorsCurrentUser[index]);
                      },
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  showSensorSelectionDialog(
                    context: context,
                    userSensors: sensorService.sensorsCurrentUser
                        .map((sensorId) => UserSensor(
                              sensorId: sensorId,
                              userId: sensorService.userId ?? '', // userId
                              enable: true, // assuming default enabled
                            ))
                        .toList(),
                    selectedSensorId: sensorService.selectedSensor.value.obs,
                    onSensorSelected: (sensorId) {
                      sensorService.selectSensor(sensorId);
                    },
                    onDeleteSensor: (sensorId) {
                      sensorSettings.showConfirmDeleteDialog(context, sensorId);
                    },
                  );
                },
                child: const Text('Select Sensor'),
              ),
              ElevatedButton(
                onPressed: () {
                  sensorSettings.showAddSensorDialog(context);
                },
                child: const Text('Add Another Sensor'),
              ),
            ],
          );
        },
      ),
    );
  }
}
