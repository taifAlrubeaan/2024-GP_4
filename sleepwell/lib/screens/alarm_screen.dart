import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/alarm/alarm_controller.dart';
import 'alarm/sleepwell_cycle_screen.dart';
import 'alarm/alarm_list_screen.dart';

class AlarmScreen extends StatelessWidget {
  const AlarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Alarm App',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => AlarmListScreen()),
            icon: const Icon(Icons.schedule_outlined, color: Colors.white),
          ),
        ],
        backgroundColor: const Color(0xFF004AAD),
      ),
      body: GetBuilder<AlarmController>(
        init: AlarmController(),
        builder: (controller) {
          controller.checkIfAlarmAddedToday();
          return Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.all(screenHeight * 0.03),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF004AAD), Color(0xFF040E3B)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: controller.isAlarmAdded
                ? AlarmDetailsWidget(
                    bedtime: controller.printedBedtime,
                    wakeUpTime: controller.printedWakeUpTime,
                    numOfCycles: controller.numOfCycles,
                    onDelete: controller.deleteAlarm,
                  )
                : const AlarmPlaceholderWidget(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => SleepWellCycleScreen()),
        tooltip: 'Add Alarm',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AlarmDetailsWidget extends StatelessWidget {
  final String bedtime;
  final String wakeUpTime;
  final int numOfCycles;
  final VoidCallback onDelete;

  const AlarmDetailsWidget({
    required this.bedtime,
    required this.wakeUpTime,
    required this.numOfCycles,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: <Widget>[
        const Text(
          'Alarm has been Scheduled',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenHeight * 0.2),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Actual sleep time is: $bedtime',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'Optimal wake-up time is: $wakeUpTime',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'You slept for $numOfCycles ${numOfCycles == 1 ? 'sleep cycle' : 'sleep cycles'}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: screenHeight * 0.02),
              ElevatedButton(
                onPressed: onDelete,
                child: const Text('Delete Alarm'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AlarmPlaceholderWidget extends StatelessWidget {
  const AlarmPlaceholderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.alarm, size: 100, color: Colors.black),
        Text(
          'No alarm created',
          style: TextStyle(fontSize: 24, color: Colors.green),
        ),
        Text(
          'Tap the + button to create an alarm',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ],
    );
  }
}
