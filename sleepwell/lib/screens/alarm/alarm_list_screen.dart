import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/alarm/alarm_list__controller.dart';
import '../../widget/alarm_list_widget.dart';
import '../edite_alarm_screen.dart';
import 'sleepwell_cycle_screen.dart';

class AlarmListScreen extends StatelessWidget {
  final AlarmListController controller = Get.put(AlarmListController());

  AlarmListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Print alarms when navigating to this screen
    // controller.printAlarmsToConsole();
    // controller.printAllAlarms();
    controller.loadAlarms();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Alarm List',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF004AAD),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(SleepWellCycleScreen());
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF004AAD), Color(0xFF040E3B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Obx(() {
          if (controller.alarms.isEmpty) {
            return const Center(
              child: Text(
                "No alarms found.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: controller.alarms.length,
            itemBuilder: (context, index) {
              controller.loadAlarms();
              final alarm = controller.alarms[index];
              return AlarmListWidget(
                alarm: alarm,
                onDelete: () {
                  controller.deleteAlarm(alarm.alarmId);
                },
                onTap: () async {
                  final updatedAlarm = await Get.to(
                    EditAlarmScreen(alarm: alarm),
                  );
                  if (updatedAlarm != null) {
                    controller.updateAlarm(index, updatedAlarm);
                  }
                },
              );
            },
          );
        }),
      ),
    );
  }
}
