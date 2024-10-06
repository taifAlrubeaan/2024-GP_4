// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import 'beneficiaries_dropdown_screen .dart';

// class AddBeneficiaryScreen extends StatefulWidget {
//   const AddBeneficiaryScreen({super.key});

//   @override
//   _AddBeneficiaryScreenState createState() => _AddBeneficiaryScreenState();
// }

// class _AddBeneficiaryScreenState extends State<AddBeneficiaryScreen> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _watchController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Add Beneficiary',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: const Color(0xFF004AAD),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Container(
//         height: MediaQuery.of(context).size.height,
//         // padding: const EdgeInsets.all(30),
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF004AAD), Color(0xFF040E3B)],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               TextField(
//                 controller: _nameController,
//                 style: const TextStyle(
//                   color: Colors.white,
//                 ),
//                 decoration: const InputDecoration(
//                   labelText: 'Name',
//                   fillColor: Colors.white,
//                   labelStyle: TextStyle(color: Colors.white),
//                 ),
//               ),
//               TextField(
//                 controller: _watchController,
//                 style: const TextStyle(
//                   color: Colors.white,
//                 ),
//                 decoration: const InputDecoration(
//                   labelText: 'Connect the watch',
//                   fillColor: Colors.white,
//                   labelStyle: TextStyle(color: Colors.white),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   // Add beneficiary logic
//                   Navigator.pop(context);
//                   Get.to(BeneficiariesDropdownScreen());
//                 },
//                 child: const Text('Add'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sleepwell/screens/beneficiaries_screen.dart';
import 'package:sleepwell/screens/home_screen.dart'; // إضافة المكتبة

// import 'beneficiaries_dropdown_screen.dart';

class AddBeneficiaryScreen extends StatefulWidget {
  const AddBeneficiaryScreen({super.key});

  @override
  _AddBeneficiaryScreenState createState() => _AddBeneficiaryScreenState();
}

class _AddBeneficiaryScreenState extends State<AddBeneficiaryScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _watchController = TextEditingController();
// دالة لتخزين بيانات التابع في Firestore
  Future<void> addBeneficiary() async {
    String name = _nameController.text.trim();
    String watch = _watchController.text.trim();
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (name.isNotEmpty && watch.isNotEmpty) {
      try {
        // إنشاء معرف فريد للتابع
        String beneficiaryId = DateTime.now()
            .millisecondsSinceEpoch
            .toString(); // يمكنك استخدام أي طريقة أخرى لإنشاء معرف فريد

        // تخزين البيانات في Firestore
        await FirebaseFirestore.instance
            .collection('beneficiaries')
            .doc(beneficiaryId)
            .set({
          'userid': userId,
          'name': name,
          'watch': watch,
          'beneficiaryId': beneficiaryId, // تخزين معرف التابع
          // يمكنك إضافة أي حقول أخرى تحتاجها
        });

        // إعادة تعيين الحقول بعد التخزين
        _nameController.clear();
        _watchController.clear();

        // الانتقال إلى شاشة التابعين
        Get.to(  HomeScreen());
        print('::::::::::::::::::::::::::::::::::::::;');
        print(userId);
        print('::::::::::::::::::::::::::::::::::::::;');
      } catch (e) {
        // التعامل مع الأخطاء إذا حدثت
        Get.snackbar('Error', 'Failed to add beneficiary: $e');
      }
    } else {
      Get.snackbar('Warning', 'Please fill all fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Beneficiary',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF004AAD),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
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
            children: [
              TextField(
                controller: _nameController,
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  fillColor: Colors.white,
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
              TextField(
                controller: _watchController,
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration: const InputDecoration(
                  labelText: 'Connect the watch',
                  fillColor: Colors.white,
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: addBeneficiary, // استدعاء الدالة هنا
                child: const Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
