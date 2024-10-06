// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:sleepwell/screens/beneficiaries%20screen/add_eneficiary_screen.dart';
// import 'package:sleepwell/screens/home_screen.dart';

// class BeneficiariesDropdownScreen extends StatefulWidget {
//   BeneficiariesDropdownScreen({super.key});
//   @override
//   State<BeneficiariesDropdownScreen> createState() =>
//       _BeneficiariesDropdownScreenState();
// }

// class _BeneficiariesDropdownScreenState
//     extends State<BeneficiariesDropdownScreen> {
//   final List<String> beneficiaries = ['Raghad', 'Ruba'];

//   // القائمة ستحتوي على المستفيدين الحاليين
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'My Beneficiaries',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: const Color(0xFF004AAD),
//       ),
//       body: Container(
//         height: MediaQuery.of(context).size.height,
//         // padding: const EdgeInsets.all(30),
//         width: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF004AAD), Color(0xFF040E3B)],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child:
        
//          Column(
//           children: [
//             DropdownButton<String>(
//               items: beneficiaries.map((String beneficiary) {
//                 return DropdownMenuItem<String>(
//                   value: beneficiary,
//                   child: Text(beneficiary),
//                 );
//               }).toList(),
//               onChanged: (String? newValue) {
//                 // تحديث القيم
//               },
//               hint: const Text(
//                 'Select Beneficiary',
//                 style:
//                     TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//               ),
//             ),
//             const SizedBox(height: 300),
//             const Divider(color: Color.fromRGBO(16, 235, 92, 0.903)),
//             Center(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         'Add New Beneficiary',
//                         style: TextStyle(
//                             color: Colors.white, fontWeight: FontWeight.bold),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       ElevatedButton(
//                         onPressed: () {
//                           // إضافة مستفيد جديد
//                           Get.offAll(const AddBeneficiaryScreen());
//                         },
//                         child: const Icon(Icons.add),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
