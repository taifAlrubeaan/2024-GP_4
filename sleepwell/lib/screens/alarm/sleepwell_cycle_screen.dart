import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../alarm.dart';
import '../../controllers/alarm/alarm_list__controller.dart';
import '../../controllers/beneficiary_controller.dart';
import '../../controllers/sensor_settings_controller.dart';
import '../../controllers/alarm/sleep-cycle-ontroller.dart';
import '../../services/sensor_service.dart';
import '../../services/update_optimal_bedtime_and_wakeuptime_alarm_service.dart';
import '../../widget/clockview.dart';
import '../../widget/confirmation_dialog_widget.dart';

// class SleepWellCycleScreen extends StatelessWidget {
//   final SleepCycleController controller = Get.put(SleepCycleController());
//   final UpdateOptimalBedtimeAndWakeAlarmService updateOptimalAlarm =
//       UpdateOptimalBedtimeAndWakeAlarmService();
//   final sensorService = Get.find<SensorService>();
//   final BeneficiaryController beneficiaryController =
//       Get.put(BeneficiaryController());
//   // final String? userId = FirebaseAuth.instance.currentUser?.uid;
//   final sensorSettings = Get.put(SensorSettingsController());
//   final AlarmListController listController = Get.put(AlarmListController());
// // 9 Pm 4:30 AM
// // 10:40 Pm
// // 4:50

// // 5:30 AM
//   SleepWellCycleScreen({super.key});

//   /// Generates a unique alarm ID
//   static int generateUniqueAlarmId() {
//     return DateTime.now().millisecondsSinceEpoch % 10000;
//   }

//   @override
//   Widget build(BuildContext context) {
//     // sensorService.listenToSensorChanges(sensorService.selectedSensor.value);

//     return Scaffold(
//       appBar: _buildAppBar(),
//       body: LayoutBuilder(builder: (context, constraints) {
//         double screenHeight = constraints.maxHeight;
//         double screenWidth = constraints.maxWidth;
//         return Container(
//           height: screenHeight,
//           padding: EdgeInsets.symmetric(
//             horizontal: screenWidth * 0.07,
//             vertical: screenHeight * 0.05,
//           ),
//           decoration: _buildGradientBackground(),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildHeader(screenWidth),
//                 const Divider(color: Color.fromRGBO(255, 7, 247, 1)),
//                 SizedBox(height: screenHeight * 0.02),
//                 _buildDateTimeRow(screenWidth),
//                 SizedBox(height: screenHeight * 0.05),
//                 _buildTimeSelectors(context),
//                 const SizedBox(height: 10),
//                 _buildSaveButton(context),
//                 const SizedBox(height: 20),
//                 _buildSelectDeviceButton(context),

//                 // ElevatedButton(
//                 //   // onPressed: () => showAlarmsDialog(context, '654321'),

//                 //   onPressed: () async {

//                 //     final String bedtime = DateFormat('hh:mm a').format(DateTime.now());
//                 // controller.calculateOptimalCycles( );
//                 //    },
//                 //   child: const Text("Show Alarms by Sensor ID"),
//                 // ),
//                 // ElevatedButton(
//                 //   onPressed: () {
//                 //     // String bedtime = "03:43 PM"; // 10:30 PM
//                 //     // String wakeUpTime = "05:44 AM"; // 6:30 AM

//                 //     // String optimalWakeUpTime = updateOptimalAlarm
//                 //     //     .calculateOptimalWakeUpTime(bedtime, wakeUpTime);
//                 //     // print('Optimal Wake-Up Time: $optimalWakeUpTime');

//                 //     int alarmId = sensorService.findAlarmBySensor('123456');
//                 //     String wakeupTimeString =
//                 //         sensorService.getWakeupTimeForAlarm(alarmId).trim();
//                 //   },
//                 //   child: const Text('Calculate Optimal Cycles'),
//                 // ),
//                 // FloatingActionButton(
//                 //   onPressed: () async {
//                 //     DateTime now = DateTime.now();
//                 //     final nowTime = TimeOfDay.fromDateTime(now);
//                 //      DateFormat("hh:mm a").parse({nowTime.hour}:${(nowTime.minute + 1) % 60});
//                 //     // if (sensorService.selectedSensor.value.isNotEmpty) {
//                 //     await AppAlarm.saveAlarm(
//                 //       // alarmId: 115,
//                 //       userId: controller.userId.value,
//                 //       // userId: 'GnQXhV91N7XRbM9z9t8g',
//                 //       bedtime: "${now.hour}:${now.minute} AM",
//                 //       optimalWakeTime:
//                 //           "${nowTime.hour}:${(nowTime.minute + 1) % 60} AM",
//                 //       name: 'Yourself',
//                 //       usertype: true, // for ben =false
//                 //       sensorId: '123456',
//                 //       // sensorId: sensorService.selectedSensor.value,
//                 //     );

//                 //     // Fetch and log all alarms
//                 //     await AppAlarm.getAlarms();
//                 //     // }

//                 //     // await GetNewAlarmToRunning.fetchTodayAlarms(
//                 //     //     controller.userId.value);
//                 //   },
//                 //   child: const Icon(Icons.alarm),
//                 // )

//                 FloatingActionButton(
//                   onPressed: () async {
//                     DateTime now = DateTime.now();
//                     final nowTime = TimeOfDay.fromDateTime(now);

//                     // Convert to 12-hour format for bedtime and optimal wake time
//                     String bedtime =
//                         DateFormat("hh:mm a").format(now); // Current time
//                     String optimalWakeTime = DateFormat("hh:mm a").format(
//                       now.add(const Duration(
//                           minutes: 1)), // Add 1 minute for the wake time
//                     );
//                     // if (sensorService.selectedSensor.value.isNotEmpty) {

//                     // Save the alarm using AppAlarm.saveAlarm
//                     await AppAlarm.saveAlarm(
//                       alarmId: generateUniqueAlarmId(),
//                       userId: controller.userId.value,
//                       // userId: 'bS92hVQIbxAYbSmiMazF',
//                       // userId: 'GnQXhV91N7XRbM9z9t8g',
//                       bedtime: bedtime,
//                       optimalWakeTime: optimalWakeTime,
//                       name: 'Yourself',
//                       // name: 'Nora',
//                       usertype: true, // for ben =false
//                       sensorId: '123456',
//                       // sensorId: sensorService.selectedSensor.value,
//                     );

//                     // Fetch and log all alarms for debugging
//                     await AppAlarm.getAlarms();
//                     // Get.to(AlarmListScreen());
//                     // }
//                     listController.loadAlarms();
//                   },
//                   child: const Icon(Icons.alarm),
//                 )
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }

//   void showAlarmsDialog(BuildContext context, String sensorId) async {
//     String formattedendDayOfWackup =
//         DateFormat('hh:mm a').format(DateTime.now());
//     DateTime bedtimeDate = DateFormat("HH:mm a").parse(formattedendDayOfWackup);
//     List<Map<String, dynamic>> alarms =
//         await controller.getAlarmDataForTodayBySensorId(sensorId, bedtimeDate);

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.grey[50],
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           title: Text(
//             'Alarms for Sensor ID: $sensorId',
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 20,
//               color: Colors.blueAccent,
//             ),
//           ),
//           content: alarms.isNotEmpty
//               ? SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: alarms.map((alarm) {
//                       return Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             // 'No alarms found for this sensor today.',
//                             'This Sensor Is Not  Available. Its Connected With Anather Alarm Now. \n Plesase Select Another Sensor',
//                             style: TextStyle(color: Colors.redAccent),
//                           ),
//                           _buildStyledText('Bedtime', alarm['bedtime']),
//                           _buildStyledText(
//                               'Optimal Wake Time', alarm['wakeup_time']),
//                           _buildStyledText('isForBeneficiary',
//                               alarm['isForBeneficiary'] ? 'true' : 'false'),
//                           _buildStyledText('Sensor ID', alarm['sensorId']),
//                           _buildStyledText('User ID', alarm['uid']),
//                           _buildStyledText(
//                               'Beneficiary ID', alarm['beneficiaryId']),
//                           _buildStyledText(
//                               'Timestamp', alarm['timestamp'].toString()),
//                           const Divider(
//                             color: Colors.grey,
//                             thickness: 1,
//                             height: 20,
//                           ),
//                         ],
//                       );
//                     }).toList(),
//                   ),
//                 )
//               : const Text(
//                   // 'No alarms found for this sensor today.',
//                   'This Sensor is Available. There are no alarms for today Connected With It.',
//                   style: TextStyle(color: Colors.redAccent),
//                 ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text(
//                 'Close',
//                 style: TextStyle(
//                   color: Colors.blueAccent,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildStyledText(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: RichText(
//         text: TextSpan(
//           style: const TextStyle(fontSize: 16, color: Colors.black87),
//           children: [
//             TextSpan(
//               text: '$label: ',
//               style: const TextStyle(
//                   fontWeight: FontWeight.bold, color: Colors.blueGrey),
//             ),
//             TextSpan(
//               text: value,
//               style: const TextStyle(color: Colors.black),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> renameCollection() async {
//     String oldName = "User behavior";
//     String newName = "userHabitts";
//     FirebaseFirestore firestore = FirebaseFirestore.instance;

//     try {
//       // Reference to old and new collections
//       CollectionReference oldCollectionRef = firestore.collection(oldName);
//       CollectionReference newCollectionRef = firestore.collection(newName);

//       // Get all documents from the old collection
//       QuerySnapshot snapshot = await oldCollectionRef.get();

//       // Copy each document to the new collection
//       for (var doc in snapshot.docs) {
//         await newCollectionRef.doc(doc.id).set(doc.data());
//       }

//       // Delete documents in the old collection
//       for (var doc in snapshot.docs) {
//         await oldCollectionRef.doc(doc.id).delete();
//       }

//       print("Collection renamed from $oldName to $newName");
//     } catch (e) {
//       print("Error renaming collection: $e");
//     }
//   }

//   AppBar _buildAppBar() => AppBar(
//         title: const Text(
//           'SleepWell Cycle',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 24,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//         backgroundColor: const Color(0xFF004AAD),
//       );

//   BoxDecoration _buildGradientBackground() => const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Color(0xFF004AAD), Color(0xFF040E3B)],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//       );

//   Widget _buildHeader(double screenWidth) {
//     return Obx(() {
//       if (beneficiaryController.isLoading.value) {
//         return const CircularProgressIndicator();
//       }
// if (beneficiaryController.beneficiaries.isEmpty) {
//   return const Text("No beneficiaries found.");
// }

//       return Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Text(
//             'Select Alarm For',
//             style: TextStyle(
//                 fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
//           ),
//           SizedBox(width: screenWidth * 0.03),
//           DropdownButton<String>(
//             value: beneficiaryController.selectedBeneficiaryId.value.isNotEmpty
//                 ? beneficiaryController.selectedBeneficiaryId.value
//                 : null,
//             hint: const Text(
//               'Select a beneficiary',
//               style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: Color.fromRGBO(6, 248, 26, 1)),
//             ),
//             items: _buildBeneficiaryDropdownItems(),
//             onChanged: (String? newValue) {
//               if (newValue != null) {
//                 beneficiaryController.setBeneficiaryId(newValue);
//               }
//             },
//           ),
//         ],
//       );
//     });
//   }

//   List<DropdownMenuItem<String>> _buildBeneficiaryDropdownItems() {
//     return [
//       DropdownMenuItem<String>(
//         value: controller.userId.value,
//         child: const Text(
//           'Yourself',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Color.fromRGBO(240, 16, 252, 1),
//           ),
//         ),
//         onTap: () {
//           controller.setBeneficiary(controller.userId.value, 'Yourself');
//         },
//       ),
//       ...beneficiaryController.beneficiaries.map((beneficiary) {
//         return DropdownMenuItem<String>(
//           value: beneficiary.id,
//           child: Text(
//             beneficiary.name,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Color.fromRGBO(240, 16, 252, 1),
//             ),
//           ),
//           onTap: () {
//             controller.setBeneficiary(beneficiary.id, beneficiary.name);
//           },
//         );
//       })
//     ];
//   }

//   Widget _buildDateTimeRow(double screenWidth) {
//     final formattedDate = DateFormat('EEE, d MMM').format(DateTime.now());
//     final formattedTime = DateFormat('hh:mm').format(DateTime.now());

//     return Row(
//       children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(formattedTime,
//                   style: const TextStyle(color: Colors.white, fontSize: 40)),
//               Text(formattedDate,
//                   style: const TextStyle(color: Colors.white, fontSize: 15)),
//             ],
//           ),
//         ),
//         SizedBox(width: screenWidth * 0.03),
//         const Align(alignment: Alignment.centerRight, child: ClockView()),
//       ],
//     );
//   }

//   Widget _buildTimeSelectors(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildTimeSelector(context, "BEDTIME", controller.bedtime, true),
//         const Divider(color: Color.fromRGBO(7, 255, 181, 1)),
//         const SizedBox(height: 20),
//         _buildTimeSelector(
//             context, "WAKE UP TIME", controller.wakeUpTime, false),
//         const Divider(color: Color.fromRGBO(7, 255, 181, 1)),
//       ],
//     );
//   }

//   Widget _buildTimeSelector(
//       BuildContext context, String label, Rx<DateTime> time, bool isBedtime) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//               color: Color(0xffff0863),
//               fontSize: 15,
//               fontWeight: FontWeight.w700,
//               letterSpacing: 1.3),
//         ),
//         GestureDetector(
//           onTap: () => _showTimePicker(context, isBedtime),
//           child: Obx(() => Text(
//                 DateFormat('hh:mm a').format(time.value),
//                 style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.w700),
//               )),
//         ),
//       ],
//     );
//   }

//   Widget _buildSaveButton(BuildContext context) {
//     return Align(
//       alignment: Alignment.center,
//       child: TextButton(
//         onPressed: () => _checkAndSaveTimes(context),
//         style: ButtonStyle(
//           backgroundColor: MaterialStateProperty.all<Color>(Colors.pink),
//           foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
//         ),
//         child: const Text('Save'),
//       ),
//     );
//   }

//   Widget _buildUpdateAlarmButton(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () async {
//         // Call the function to update alarm with new values
//         await AppAlarm.loadAndUpdateAlarm(
//           newBedtime: '09:15 AM', // Set newBedtime to '01:20 AM',
//           userId: controller.userId.value, // Set userId to 'userId',
//           // userId: 'GnQXhV91N7XRbM9z9t8g', // Set userId to 'userId',
//         );
//         await AppAlarm.printAllAlarms();
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Alarm updated successfully!")),
//         );
//       },
//       child: const Text("Update Alarm"),
//     );
//   }

//   Widget _buildSelectDeviceButton(BuildContext context) {
//     return ElevatedButton(
//       // onPressed: () {},
//       onPressed: () async {
//         String? userId = FirebaseAuth.instance.currentUser?.uid;
//         await sensorService.getUserSensors(userId!);
//         sensorSettings.checkUserSensors(context);
//       },
//       child: const Text('Select Device'),
//     );
//   }

//   Widget _buildSensorStatus() {
//     return Obx(
//       () => Padding(
//         padding: const EdgeInsets.only(top: 20),
//         child: Text(
//           'Finished checking sensor readings: ${sensorService.sleepStartTime.value.toString()}', // Access with .value
//           style: const TextStyle(fontSize: 20, color: Colors.white),
//         ),
//       ),
//     );
//   }

//   void _showTimePicker(BuildContext context, bool isBedtime) {
//     showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.fromDateTime(
//           isBedtime ? controller.bedtime.value : controller.wakeUpTime.value),
//     ).then((selectedTime) {
//       if (selectedTime != null) {
//         final now = DateTime.now();
//         final selectedDateTime = DateTime(now.year, now.month, now.day,
//             selectedTime.hour, selectedTime.minute);
//         isBedtime
//             ? controller.setBedtime(selectedDateTime)
//             : controller.setWakeUpTime(selectedDateTime);
//       }
//     });
//   }

//   void _checkAndSaveTimes(BuildContext context) {
//     // Validator for Beneficiary and Device Selection
//     if (beneficiaryController.selectedBeneficiaryId.value.isEmpty) {
//       _showWarningDialog(context, "Please select a beneficiary.");
//       return;
//     }

//     if (sensorService.selectedSensor.value.isEmpty) {
//       _showWarningDialog(context, "Please select a device.");
//       return;
//     }

//     // Check time difference
//     if (_timeDifferenceInMinutes(
//             controller.bedtime.value, controller.wakeUpTime.value) <
//         120) {
//       _showWarningDialog(context,
//           "Please select a wake-up time with at least 2 hours difference.");
//     } else {
//       sensorService
//           .selectUsers(beneficiaryController.selectedBeneficiaryId.value);
//       _showConfirmationDialog(context);
//     }
//   }

// int _timeDifferenceInMinutes(DateTime start, DateTime end) {
//   return (end.difference(start).inMinutes).abs();
// }

// void _showWarningDialog(BuildContext context, String message) {
//   showDialog(
//     context: context,
//     builder: (_) => AlertDialog(
//       title: const Text("Warning", style: TextStyle(color: Colors.red)),
//       content: Text(message),
//       actions: [
//         TextButton(onPressed: () => Get.back(), child: const Text("OK"))
//       ],
//     ),
//   );
// }

//   Future<void> checkAvalibalSensor(
//       BuildContext context, String sensorId) async {
//     String formattedendDayOfWackup =
//         DateFormat('hh:mm a').format(controller.bedtime.value);
//     DateTime SelectedbedtimeDate =
//         DateFormat("HH:mm a").parse(formattedendDayOfWackup);
//     List<Map<String, dynamic>> alarms =
//         await controller.getAlarmDataForTodayBySensorId(
//             sensorService.selectedSensor.value, SelectedbedtimeDate);
//     if (controller.checkIfHaveAlarms() == false) {
//       _showWarningDialog(context,
//           "This User Already Have Alarms For This Day\n To Set A New Alarm Please Delete The Alarms First.");
//       return;
//     }
//     if (alarms.isEmpty) {
//       controller.saveTimes();
//     } else {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             backgroundColor: Colors.grey[50],
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             title: Text(
//               'Alarms for Sensor ID: ${sensorService.selectedSensor.value}',
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 20,
//                 color: Colors.blueAccent,
//               ),
//             ),
//             content: const Text(
//               'This Sensor Is Not  Available. Its Connected With Anather Alarm Now. \n Plesase Select Another Sensor',
//               style: TextStyle(color: Colors.redAccent),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: const Text(
//                   'Close',
//                   style: TextStyle(
//                     color: Colors.blueAccent,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }

//   void _showConfirmationDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (_) => Obx(
//         () => ConfirmationDialogWidget(
//           alarmFor: controller.selectedBeneficiaryName.value,
//           selectedDevice: sensorService.selectedSensor.value,
//           bedTime: DateFormat('hh:mm a').format(controller.bedtime.value),
//           wakeUpTime: DateFormat('hh:mm a').format(controller.wakeUpTime.value),
//           sleepCycle: controller.calculateSleepDuration(),
//           onPressed: controller.loading.value
//               ? null
//               : () => checkAvalibalSensor(
//                   context, sensorService.selectedSensor.value),
//           changeDevice: () => sensorSettings.checkUserSensors(context),

//           // () => sensorService.checkUserSensors(context),
//         ),
//       ),
//     );
//   }
// }
class SleepWellCycleScreen extends StatelessWidget {
  SleepWellCycleScreen({Key? key}) : super(key: key);

  final SleepCycleController controller = Get.put(SleepCycleController());
  final BeneficiaryController beneficiaryController =
      Get.put(BeneficiaryController());
  final SensorSettingsController sensorSettings =
      Get.put(SensorSettingsController());
  final SensorService sensorService = Get.find<SensorService>();

  @override
  Widget build(BuildContext context) {
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
                FloatingActionButton(
                  onPressed: () async {
                    DateTime now = DateTime.now();
                    final nowTime = TimeOfDay.fromDateTime(now);

                    // Convert to 12-hour format for bedtime and optimal wake time
                    String bedtime =
                        DateFormat("hh:mm a").format(now); // Current time
                    String optimalWakeTime = DateFormat("hh:mm a").format(
                      now.add(const Duration(
                          minutes: 1)), // Add 1 minute for the wake time
                    );
                    // if (sensorService.selectedSensor.value.isNotEmpty) {
                    final AlarmListController listController =
                        Get.put(AlarmListController());
                    // Save the alarm using AppAlarm.saveAlarm
                    await AppAlarm.saveAlarm(
                      alarmId: generateUniqueAlarmId(),
                      userId: controller.userId.value,
                      // userId: 'bS92hVQIbxAYbSmiMazF',
                      // userId: 'GnQXhV91N7XRbM9z9t8g',
                      bedtime: bedtime,
                      optimalWakeTime: optimalWakeTime,
                      name: 'Yourself',
                      // name: 'Nora',
                      usertype: true, // for ben =false
                      sensorId: '123456',
                      // sensorId: sensorService.selectedSensor.value,
                    );

                    // Fetch and log all alarms for debugging
                    await AppAlarm.getAlarms();
                    // Get.to(AlarmListScreen());
                    // }
                    listController.loadAlarms();
                  },
                  child: const Icon(Icons.alarm),
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  static int generateUniqueAlarmId() {
    return DateTime.now().millisecondsSinceEpoch % 10000;
  }

  AppBar _buildAppBar() => AppBar(
        title: const Text(
          'SleepWell Cycle',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
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

  // Widget _buildHeader(double screenWidth) {
  //   return GetBuilder<BeneficiaryController>(
  //     builder: (beneficiaryController) {
  //       if (beneficiaryController.isLoading.value) {
  //         return const Center(child: CircularProgressIndicator());
  //       }
  //       // beneficiaryController.fetchBeneficiaries(controller.userId.value);
  //       if (beneficiaryController.beneficiaries.isEmpty) {
  //         return const Text("No beneficiaries found.");
  //       }
  //       return Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           const Text(
  //             'Select Alarm For',
  //             style: TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.white),
  //           ),
  //           SizedBox(width: screenWidth * 0.03),
  //           DropdownButton<String>(
  //             value: beneficiaryController
  //                         .selectedBeneficiaryId.value.isNotEmpty &&
  //                     beneficiaryController.selectedBeneficiaryId.value != null
  //                 ? beneficiaryController.selectedBeneficiaryId.value
  //                 : null,
  //             hint: const Text(
  //               'Select a beneficiary',
  //               style: TextStyle(
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.bold,
  //                   color: Color.fromRGBO(6, 248, 26, 1)),
  //             ),
  //             items: _buildBeneficiaryDropdownItems(),
  //             onChanged: (String? newValue) {
  //               if (newValue != null) {
  //                 beneficiaryController.setBeneficiaryId(newValue);
  //               }
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // List<DropdownMenuItem<String>> _buildBeneficiaryDropdownItems(
  //     BeneficiaryController beneficiaryController) {
  //   return [
  //     DropdownMenuItem<String>(
  //       value: controller.userId.value,
  //       child: const Text(
  //         'Yourself',
  //         style: TextStyle(
  //           fontSize: 16,
  //           fontWeight: FontWeight.bold,
  //           color: Color.fromRGBO(240, 16, 252, 1),
  //         ),
  //       ),
  //       onTap: () {
  //         controller.setBeneficiary(controller.userId.value, 'Yourself');
  //       },
  //     ),
  //     ...beneficiaryController.beneficiaries.map((beneficiary) {
  //       return DropdownMenuItem<String>(
  //         value: beneficiary.id,
  //         child: Text(
  //           beneficiary.name,
  //           style: const TextStyle(
  //             fontSize: 16,
  //             fontWeight: FontWeight.bold,
  //             color: Color.fromRGBO(240, 16, 252, 1),
  //           ),
  //         ),
  //         onTap: () {
  //           controller.setBeneficiary(beneficiary.id, beneficiary.name);
  //         },
  //       );
  //     })
  //   ];
  // }

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
        child: const Text(
          'Yourself',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(240, 16, 252, 1),
          ),
        ),
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(240, 16, 252, 1),
            ),
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

  // Widget _buildTimeSelectors(BuildContext context) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       GetBuilder<SleepCycleController>(
  //         builder: (controller) {
  //           return _buildTimeSelector(
  //               context, "BEDTIME", controller.bedtime, true);
  //         },
  //       ),
  //       const Divider(color: Color.fromRGBO(7, 255, 181, 1)),
  //       const SizedBox(height: 20),
  //       GetBuilder<SleepCycleController>(
  //         builder: (controller) {
  //           return _buildTimeSelector(
  //               context, "WAKE UP TIME", controller.wakeUpTime.value.o, false);
  //         },
  //       ),
  //       const Divider(color: Color.fromRGBO(7, 255, 181, 1)),
  //     ],
  //   );
  // }

  // Widget _buildTimeSelector(
  //     BuildContext context, String label, DateTime time, bool isBedtime) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         label,
  //         style: const TextStyle(
  //             color: Color(0xffff0863),
  //             fontSize: 15,
  //             fontWeight: FontWeight.w700,
  //             letterSpacing: 1.3),
  //       ),
  //       GestureDetector(
  //         onTap: () => _showTimePicker(context, isBedtime),
  //         child: Text(
  //           DateFormat('hh:mm a').format(time),
  //           style: const TextStyle(
  //               color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
  //         ),
  //       ),
  //     ],
  //   );
  // }

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

  Widget _buildSelectDeviceButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        String? userId = FirebaseAuth.instance.currentUser?.uid;
        await sensorService.getUserSensors(userId!);
        sensorSettings.checkUserSensors(context);
      },
      child: const Text('Select Device'),
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
        if (isBedtime) {
          controller.setBedtime(selectedDateTime);
        } else {
          controller.setWakeUpTime(selectedDateTime);
        }
      }
    });
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

  int _timeDifferenceInMinutes(DateTime start, DateTime end) {
    return (end.difference(start).inMinutes).abs();
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Obx(
        () => ConfirmationDialogWidget(
          alarmFor: controller.selectedBeneficiaryName.value,
          selectedDevice: sensorService.selectedSensor.value,
          bedTime: DateFormat('hh:mm a').format(controller.bedtime.value),
          wakeUpTime: DateFormat('hh:mm a').format(controller.wakeUpTime.value),
          sleepCycle: controller.calculateSleepDuration(),
          onPressed: controller.loading.value
              ? null
              : () => checkAvalibalSensor(
                  context, sensorService.selectedSensor.value),
          changeDevice: () => sensorSettings.checkUserSensors(context),

          // () => sensorService.checkUserSensors(context),
        ),
      ),
    );
  }

  Future<void> checkAvalibalSensor(
      BuildContext context, String sensorId) async {
    if (controller.selectedBeneficiaryName.value == '' ||
        controller.selectedBeneficiaryName.value == null) {
      _showWarningDialog(
          context, "Plese Again To Select Availde User To Set Alarm For It");
      return;
    }
    String formattedendDayOfWackup =
        DateFormat('hh:mm a').format(controller.bedtime.value);
    DateTime SelectedbedtimeDate =
        DateFormat("HH:mm a").parse(formattedendDayOfWackup);
    List<Map<String, dynamic>> alarms =
        await controller.getAlarmDataForTodayBySensorId(
            sensorService.selectedSensor.value, SelectedbedtimeDate);
    if (controller.checkIfHaveAlarms() == false) {
      _showWarningDialog(context,
          "This User Already Have Alarms For This Day\n To Set A New Alarm Please Delete The Alarms First.");
      return;
    }
    if (alarms.isEmpty) {
      controller.saveTimes();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey[50],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(
              'Alarms for Sensor ID: ${sensorService.selectedSensor.value}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.blueAccent,
              ),
            ),
            content: const Text(
              'This Sensor Is Not  Available. Its Connected With Anather Alarm Now. \n Plesase Select Another Sensor',
              style: TextStyle(color: Colors.redAccent),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }
}
