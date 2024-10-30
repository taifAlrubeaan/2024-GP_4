// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../controllers/alarm_setup_controller.dart';


// class AlarmSetupScreen extends StatelessWidget {
//   final AlarmSetupController controller = Get.put(AlarmSetupController());

//    AlarmSetupScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Alarm Setup')),
//       body: Column(
//         children: [
//           TextField(
//             controller: controller.bedtimeController,
//             decoration: InputDecoration(labelText: 'Bedtime'),
//             readOnly: true,
//             onTap: () => _showBedtimePicker(context),
//           ),
//           TextField(
//             controller: controller.wakeUpTimeController,
//             decoration: InputDecoration(labelText: 'Wake-up Time'),
//             readOnly: true,
//             onTap: () => _showWakeUpTimePicker(context),
//           ),
//           ElevatedButton(
//             onPressed: () => controller.saveTimes(controller.beneficiaryId.value),
//             child: Text('Save Alarm'),
//           ),
//           Obx(() => Text('Number of Sleep Cycles: ${controller.numOfCycles.value}')),
//         ],
//       ),
//     );
//   }

//   Future<void> _showBedtimePicker(BuildContext context) async {
//     final pickedTime = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );

//     if (pickedTime != null) {
//       controller.bedtimeController.text = controller.formatTime(pickedTime);
//       controller.selectedBedtime = pickedTime;
//     }
//   }

//   Future<void> _showWakeUpTimePicker(BuildContext context) async {
//     final pickedTime = await showTimePicker(
//       context: context,
//       initialTime: controller.selectedWakeUpTime,
//     );

//     if (pickedTime != null) {
//       controller.wakeUpTimeController.text = controller.formatTime(pickedTime);
//       controller.selectedWakeUpTime = pickedTime;
//     }
//   }
// }
