import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../alarm.dart';
import '../../../controllers/beneficiary_controller.dart';
import '../../../controllers/sensor_settings_controller.dart';
import '../../../controllers/sleep-cycle-ontroller.dart';
import '../../../services/sensor_service.dart';
import '../../../widget/clockview.dart';
import '../../../widget/confirmation_dialog_widget.dart';

class SleepWellCycleScreen extends StatelessWidget {
  final SleepCycleController controller = Get.put(SleepCycleController());
  final sensorService = Get.find<SensorService>();
  final BeneficiaryController beneficiaryController =
      Get.put(BeneficiaryController());
  // final String? userId = FirebaseAuth.instance.currentUser?.uid;
  final sensorSettings = Get.put(SensorSettingsController());

  SleepWellCycleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    sensorService.listenToSensorChanges(sensorService.selectedSensor.value);

    return Scaffold(
      appBar: _buildAppBar(),
      body: LayoutBuilder(builder: (context, constraints) {
        double screenHeight = constraints.maxHeight;
        double screenWidth = constraints.maxWidth;
        return Container(
          height: screenHeight,
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.07,
            vertical: screenHeight * 0.05,
          ),
          decoration: _buildGradientBackground(),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(screenWidth),
                const Divider(color: Color.fromRGBO(255, 7, 247, 1)),
                SizedBox(height: screenHeight * 0.02),
                _buildDateTimeRow(screenWidth),
                SizedBox(height: screenHeight * 0.05),
                _buildTimeSelectors(context),
                const SizedBox(height: 10),
                _buildSaveButton(context),
                const SizedBox(height: 20),
                _buildSelectDeviceButton(context),
                _buildSensorStatus(),
                ElevatedButton(
                  onPressed: () async {
                    // Call the function to update alarm with new values
                    await AppAlarm.loadAndUpdateAlarm(
                      newBedtime: '09:15 AM', // Set newBedtime to '01:20 AM',
                      userId:
                          controller.userId.value, // Set userId to 'userId',
                      // userId: 'GnQXhV91N7XRbM9z9t8g', // Set userId to 'userId',
                    );
                    await AppAlarm.printAllAlarms();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Alarm updated successfully!")),
                    );
                  },
                  child: const Text("Update Alarm"),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  AppBar _buildAppBar() => AppBar(
        title: const Text(
          'SleepWell Cycle',
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF004AAD),
      );

  BoxDecoration _buildGradientBackground() => const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF004AAD), Color(0xFF040E3B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      );

  Widget _buildHeader(double screenWidth) {
    return Obx(() {
      if (beneficiaryController.isLoading.value) {
        return const CircularProgressIndicator();
      }
      if (beneficiaryController.beneficiaries.isEmpty) {
        return const Text("No beneficiaries found.");
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Select Alarm For',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(width: screenWidth * 0.03),
          DropdownButton<String>(
            value: beneficiaryController.selectedBeneficiaryId.value.isNotEmpty
                ? beneficiaryController.selectedBeneficiaryId.value
                : null,
            hint: const Text(
              'Select a beneficiary',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(6, 248, 26, 1)),
            ),
            items: _buildBeneficiaryDropdownItems(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                beneficiaryController.setBeneficiaryId(newValue);
              }
            },
          ),
        ],
      );
    });
  }

  List<DropdownMenuItem<String>> _buildBeneficiaryDropdownItems() {
    return [
      DropdownMenuItem<String>(
        value: controller.userId.value,
        child: const Text('Yourself'),
        onTap: () {
          controller.setBeneficiary(controller.userId.value, 'Yourself');
        },
      ),
      ...beneficiaryController.beneficiaries.map((beneficiary) {
        return DropdownMenuItem<String>(
          value: beneficiary.id,
          child: Text(
            beneficiary.name,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          onTap: () {
            controller.setBeneficiary(beneficiary.id, beneficiary.name);
          },
        );
      })
    ];
  }

  Widget _buildDateTimeRow(double screenWidth) {
    final formattedDate = DateFormat('EEE, d MMM').format(DateTime.now());
    final formattedTime = DateFormat('hh:mm').format(DateTime.now());

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(formattedTime,
                  style: const TextStyle(color: Colors.white, fontSize: 40)),
              Text(formattedDate,
                  style: const TextStyle(color: Colors.white, fontSize: 15)),
            ],
          ),
        ),
        SizedBox(width: screenWidth * 0.03),
        const Align(alignment: Alignment.centerRight, child: ClockView()),
      ],
    );
  }

  Widget _buildTimeSelectors(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTimeSelector(context, "BEDTIME", controller.bedtime, true),
        const Divider(color: Color.fromRGBO(7, 255, 181, 1)),
        const SizedBox(height: 20),
        _buildTimeSelector(
            context, "WAKE UP TIME", controller.wakeUpTime, false),
        const Divider(color: Color.fromRGBO(7, 255, 181, 1)),
      ],
    );
  }

  Widget _buildTimeSelector(
      BuildContext context, String label, Rx<DateTime> time, bool isBedtime) {
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
          onTap: () => _showTimePicker(context, isBedtime),
          child: Obx(() => Text(
                DateFormat('hh:mm a').format(time.value),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              )),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: TextButton(
        onPressed: () => _checkAndSaveTimes(context),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.pink),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        ),
        child: const Text('Save'),
      ),
    );
  }

  Widget _buildSelectDeviceButton(BuildContext context) {
    return ElevatedButton(
      // onPressed: () {},
      onPressed: () => sensorSettings.checkUserSensors(context),
      child: const Text('Select Device'),
    );
  }

  Widget _buildSensorStatus() {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Text(
          'Finished checking sensor readings: ${sensorService.sleepStartTime.value.toString()}', // Access with .value
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  void _showTimePicker(BuildContext context, bool isBedtime) {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
          isBedtime ? controller.bedtime.value : controller.wakeUpTime.value),
    ).then((selectedTime) {
      if (selectedTime != null) {
        final now = DateTime.now();
        final selectedDateTime = DateTime(now.year, now.month, now.day,
            selectedTime.hour, selectedTime.minute);
        isBedtime
            ? controller.setBedtime(selectedDateTime)
            : controller.setWakeUpTime(selectedDateTime);
      }
    });
  }

  void _checkAndSaveTimes(BuildContext context) {
    // Validator for Beneficiary and Device Selection
    if (beneficiaryController.selectedBeneficiaryId.value.isEmpty) {
      _showWarningDialog(context, "Please select a beneficiary.");
      return;
    }

    if (sensorService.selectedSensor.value.isEmpty) {
      _showWarningDialog(context, "Please select a device.");
      return;
    }

    // Check time difference
    if (_timeDifferenceInMinutes(
            controller.bedtime.value, controller.wakeUpTime.value) <
        120) {
      _showWarningDialog(context,
          "Please select a wake-up time with at least 2 hours difference.");
    } else {
      sensorService
          .selectUsers(beneficiaryController.selectedBeneficiaryId.value);
      _showConfirmationDialog(context);
    }
  }

  int _timeDifferenceInMinutes(DateTime start, DateTime end) {
    return (end.difference(start).inMinutes).abs();
  }

  void _showWarningDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Warning", style: TextStyle(color: Colors.red)),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("OK"))
        ],
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Obx(
        () => ConfirmationDialogWidget(
            alarmFor: controller.selectedBeneficiaryName.value,
            selectedDevice: sensorService.selectedSensor.value,
            wakeUpTime:
                DateFormat('hh:mm a').format(controller.wakeUpTime.value),
            bedTime: DateFormat('hh:mm a').format(controller.bedtime.value),
            sleepCycle: controller.calculateSleepDuration(),
            onPressed:
                controller.loading.value ? null : () => controller.saveTimes(),
            changeDevice: null
            // () => sensorService.checkUserSensors(context),
            ),
      ),
    );
  }
}
