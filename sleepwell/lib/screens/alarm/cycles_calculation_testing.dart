import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/alarm/alarm_list__controller.dart';
import '../../controllers/alarm/cycles_calculation_testing_controller.dart';

class CyclesCalculationTesting extends StatelessWidget {
  final CyclesCalculationTestingController controller =
      Get.put(CyclesCalculationTestingController());
  final AlarmListController listController = Get.put(AlarmListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF004AAD),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Cycles Calculation Testing',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF004AAD), Color(0xFF040E3B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimeSelectors(context),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  alignment: Alignment.center,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 10),
                  backgroundColor: const Color.fromRGBO(11, 157, 247, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: const BorderSide(color: Color(0xFF004AAD)),
                  ),
                ),
                onPressed: () {
                  _checkAndSaveTimes(context);
                },
                child: const Text(
                  'Calculate',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(color: Color.fromRGBO(9, 238, 13, 1)),
              const SizedBox(height: 20),
              _buildCalculationResults(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelectors(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTimeSelector(
            context, "Bedtime", controller.bedtime, controller.setBedtime),
        const SizedBox(height: 20),
        _buildTimeSelector(context, "Actual Bedtime", controller.actualBedtime,
            controller.setActualBedtime),
        const SizedBox(height: 20),
        _buildTimeSelector(context, "Wake Up Time", controller.wakeUpTime,
            controller.setWakeUpTime),
      ],
    );
  }

  Widget _buildTimeSelector(BuildContext context, String label,
      Rx<DateTime> time, Function(DateTime) setTime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              color: Color(0xffff0863),
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3),
        ),
        GestureDetector(
          onTap: () => _showTimePicker(context, setTime),
          child: Obx(
            () => Text(
              DateFormat('hh:mm a').format(time.value),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  void _showTimePicker(BuildContext context, Function(DateTime) setTime) {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    ).then((selectedTime) {
      if (selectedTime != null) {
        final now = DateTime.now();
        final selectedDateTime = DateTime(now.year, now.month, now.day,
            selectedTime.hour, selectedTime.minute);
        setTime(selectedDateTime);
      }
    });
  }

  Widget _buildCalculationResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Calculation Results:',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Obx(
          () => Text(
            "Number of Sleep Cycles: ${controller.numberOfCycles.value}   ",
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        Obx(
          () => Text(
            "Sleep Hours: ${controller.sleepHours.value.toInt()}     ",
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        Obx(
          () => Text(
            "Optimal Wake Up Time: ${controller.optimalWakeTime.value}",
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        Obx(
          () => Text(
            "The system added 15 min? ${controller.addedFifteenMinutes.value ? 'Yes' : 'No'}",
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }

  int _timeDifferenceInMinutes(DateTime start, DateTime end) {
    return (end.difference(start).inMinutes).abs();
  }

  void _checkAndSaveTimes(BuildContext context) {
    if (_timeDifferenceInMinutes(
            controller.bedtime.value, controller.actualBedtime.value) <
        30) {
      _showWarningDialog(context,
          "Please select an actual bedtime at least 30 minutes after the selected bedtime.");
    } else if (_timeDifferenceInMinutes(
            controller.actualBedtime.value, controller.wakeUpTime.value) <
        30) {
      _showWarningDialog(context,
          "Please select a wake-up time at least 30 minutes after the selected actual bedtime.");
    } else {
      controller.calculateSleepCycles();
      listController.loadAlarms();
    }
  }

  void _showWarningDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warning'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
