// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
 
// class BottomSheetWidget extends StatelessWidget {
//   final DeviceController controllerDevice;
//   final String title;
//   final bool isForBeneficiary;
//   final String? beneficiaryId;
//   const BottomSheetWidget({
//     Key? key,
//     required this.controllerDevice,
//     required this.title,
//     this.isForBeneficiary = false,
//     this.beneficiaryId,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       expand: false,
//       maxChildSize: 0.7,
//       initialChildSize: 0.5,
//       minChildSize: 0.3,
//       builder: (BuildContext context, ScrollController scrollController) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                   ),
//                 ],
//               ),
//               Expanded(
//                 child: ListView(
//                   controller: scrollController,
//                   children: [
//                     Obx(
//                       () => ListTile(
//                         title: const Text('Sensor 1'),
//                         trailing: isForBeneficiary
//                             ? controllerDevice
//                                         .selectedBeneficiaryDevice.value ==
//                                     'Sensor 1'
//                                 ? const Icon(Icons.check_circle,
//                                     color: Colors.green)
//                                 : null
//                             : controllerDevice.selectedDevice.value ==
//                                     'Sensor 1'
//                                 ? const Icon(Icons.check_circle,
//                                     color: Colors.green)
//                                 : null,
//                         onTap: () {
//                           if (isForBeneficiary && beneficiaryId != null) {
//                             controllerDevice.saveBeneficiaryDevice(
//                                 'Sensor 1', beneficiaryId!);
//                           } else {
//                             controllerDevice.saveDevice('Sensor 1');
//                           }
//                           // يمكنك التحكم بإغلاق النافذة هنا إذا أردت
//                           // Navigator.pop(context);
//                         },
//                       ),
//                     ),
//                     Obx(
//                       () => ListTile(
//                         title: const Text('Sensor 2'),
//                         trailing: isForBeneficiary
//                             ? controllerDevice
//                                         .selectedBeneficiaryDevice.value ==
//                                     'Sensor 2'
//                                 ? const Icon(Icons.check_circle,
//                                     color: Colors.green)
//                                 : null
//                             : controllerDevice.selectedDevice.value ==
//                                     'Sensor 2'
//                                 ? const Icon(Icons.check_circle,
//                                     color: Colors.green)
//                                 : null,
//                         onTap: () {
//                           if (isForBeneficiary && beneficiaryId != null) {
//                             controllerDevice.saveBeneficiaryDevice(
//                                 'Sensor 2', beneficiaryId!);
//                           } else {
//                             controllerDevice.saveDevice('Sensor 2');
//                           }
//                         },
//                       ),
//                     ),
//                     Obx(
//                       () => ListTile(
//                         title: const Text('Sensor 3'),
//                         trailing: isForBeneficiary
//                             ? controllerDevice
//                                         .selectedBeneficiaryDevice.value ==
//                                     'Sensor 3'
//                                 ? const Icon(Icons.check_circle,
//                                     color: Colors.green)
//                                 : null
//                             : controllerDevice.selectedDevice.value ==
//                                     'Sensor 3'
//                                 ? const Icon(Icons.check_circle,
//                                     color: Colors.green)
//                                 : null,
//                         onTap: () {
//                           if (isForBeneficiary && beneficiaryId != null) {
//                             controllerDevice.saveBeneficiaryDevice(
//                                 'Sensor 3', beneficiaryId!);
//                           } else {
//                             controllerDevice.saveDevice('Sensor 3');
//                           }
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // استدعاء الـ widget مع الخيارات المناسبة
//   static void showDeviceBottomSheet(
//     BuildContext context,
//     DeviceController controllerDevice,
//     String title, {
//     bool isForBeneficiary = false,
//     String? beneficiaryId,
//   }) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return BottomSheetWidget(
//           controllerDevice: controllerDevice,
//           title: title,
//           isForBeneficiary: isForBeneficiary,
//           beneficiaryId: beneficiaryId,
//         );
//       },
//     );
//   }
// }
