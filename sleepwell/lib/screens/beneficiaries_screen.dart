import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sleepwell/screens/beneficiaries%20screen/add_eneficiary_screen.dart';

import 'beneficiaries screen/beneficiaries_details_screen.dart';

class BeneficiariesScreen extends StatefulWidget {
  const BeneficiariesScreen({super.key});

  @override
  State<BeneficiariesScreen> createState() => _BeneficiariesScreenState();
}

class _BeneficiariesScreenState extends State<BeneficiariesScreen> {
  List<DocumentSnapshot> beneficiaries = []; // لتخزين بيانات التابعين
  bool isLoading = true; // لتتبع حالة التحميل
  String? userId;

  @override
  void initState() {
    super.initState();
    fetchBeneficiaries();
    userId = FirebaseAuth.instance.currentUser?.uid; // الحصول على userId
    if (userId != null) {
      fetchBeneficiaries();
    } else {
      // في حالة عدم وجود معرف المستخدم، يمكنك عرض رسالة أو توجيه المستخدم لتسجيل الدخول
      setState(() {
        isLoading = false;
      });
    }
  }

  // دالة لجلب التابعين من Firestore
  Future<void> fetchBeneficiaries() async {
    try {
      // جلب بيانات التابعين من Firestore
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('beneficiaries')
          .where('userid', isEqualTo: userId)
          .get();

      setState(() {
        beneficiaries = snapshot.docs; // تخزين البيانات في القائمة
        isLoading = false; // تغيير حالة التحميل
      });

      // طباعة البيانات في وحدة التحكم
      print('Beneficiaries fetched:');
      for (var beneficiary in beneficiaries) {
        print('Name: ${beneficiary['name']}, ID: ${beneficiary.id}');
      }
    } catch (e) {
      // التعامل مع الأخطاء عند جلب البيانات
      print('Error fetching beneficiaries: $e');
      setState(() {
        isLoading = false; // تغيير حالة التحميل حتى لو حدث خطأ
      });
    }
  }

  // دالة لحذف التابع
  Future<void> deleteBeneficiary(String beneficiaryId) async {
    try {
      await FirebaseFirestore.instance
          .collection('beneficiaries')
          .doc(beneficiaryId)
          .delete();
      setState(() {
        beneficiaries.removeWhere((element) =>
            element.id == beneficiaryId); // إزالة التابع من القائمة
      });
      Get.snackbar('Success', 'Beneficiary deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete beneficiary: $e');
    }
  }

// دالة لعرض حوار لإضافة مستفيد جديد
  void showAddBeneficiaryDialog() {
    // إنشاء متغيرات للتحكم في النصوص المدخلة
    final TextEditingController nameController = TextEditingController();
    final TextEditingController watchController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Beneficiary'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Beneficiary Name',
                  ),
                ),
                TextField(
                  controller: watchController,
                  decoration: const InputDecoration(
                    labelText: 'Watch',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق الحوار
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // تحقق من أن الحقول ليست فارغة
                if (nameController.text.isNotEmpty &&
                    watchController.text.isNotEmpty) {
                  // استدعاء دالة لإضافة المستفيد
                  addBeneficiary(nameController.text, watchController.text);
                  Navigator.of(context).pop(); // إغلاق الحوار
                } else {
                  Get.snackbar('Warning', 'Please fill all fields');
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

// دالة لإضافة مستفيد جديد
  Future<void> addBeneficiary(String name, String watch) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      try {
        // تخزين البيانات في Firestore
        await FirebaseFirestore.instance.collection('beneficiaries').add({
          'userid': userId,
          'name': name,
          'watch': watch,
        });

        // يمكنك إضافة أي معالجة أخرى بعد الإضافة الناجحة، مثل تحديث الشاشة
        print('Beneficiary added: Name: $name, Watch: $watch');
      } catch (e) {
        // التعامل مع الأخطاء إذا حدثت
        Get.snackbar('Error', 'Failed to add beneficiary: $e');
      }
    } else {
      Get.snackbar('Warning', 'User not logged in');
    }
  }

  // دالة لعرض حوار تعديل الاسم
  void showEditDialog(String beneficiaryId, String currentName) {
    TextEditingController editController =
        TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Beneficiary Name'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(hintText: 'Enter new name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق الحوار
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String newName = editController.text.trim();
                if (newName.isNotEmpty) {
                  await updateBeneficiaryName(
                      beneficiaryId, newName); // تحديث الاسم
                  Navigator.of(context).pop(); // إغلاق الحوار
                } else {
                  Get.snackbar('Warning', 'Name cannot be empty');
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  // دالة لتحديث اسم التابع في Firestore
  Future<void> updateBeneficiaryName(
      String beneficiaryId, String newName) async {
    try {
      await FirebaseFirestore.instance
          .collection('beneficiaries')
          .doc(beneficiaryId)
          .update({'name': newName}); // تحديث الاسم
      fetchBeneficiaries(); // إعادة جلب المستفيدين
      Get.snackbar('Success', 'Beneficiary name updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update beneficiary name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Beneficiaries',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF004AAD),
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
        child: isLoading // عرض شاشة التحميل إذا كانت البيانات قيد الجلب
            ? const Center(child: CircularProgressIndicator())
            : beneficiaries.isEmpty // إذا كانت القائمة فارغة
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No beneficiaries added',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Add a new beneficiary by tapping the button',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Get.to(const AddBeneficiaryScreen());
                          },
                          child: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      ListView.builder(
                        itemCount: beneficiaries.length,
                        itemBuilder: (context, index) {
                          final beneficiary = beneficiaries[index];
                          return Column(
                            children: [
                              ListTile(
                                title: Text(
                                  beneficiary['name'],
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ), // اسم التابع
                                onTap: () => Get.to(
                                  BeneficiaryDetailsScreen(
                                    beneficiaryName: beneficiary['name'],
                                    
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        // يمكنك إضافة دالة لتعديل الاسم
                                        // على سبيل المثال، عرض حوار لتعديل الاسم
                                        showEditDialog(beneficiary.id,
                                            beneficiary['name']);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        // تأكيد الحذف قبل القيام بذلك
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text(
                                                  'Delete Beneficiary'),
                                              content: const Text(
                                                  'Are you sure you want to delete this beneficiary?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // إغلاق الحوار
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    deleteBeneficiary(
                                                        beneficiary
                                                            .id); // حذف التابع
                                                    Navigator.of(context)
                                                        .pop(); // إغلاق الحوار
                                                  },
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                color: Color(0xFF21D4F3),
                              ),
                            ],
                          );
                        },
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // لتوسيط العناصر عموديًا
                          crossAxisAlignment: CrossAxisAlignment
                              .center, // لتوسيط العناصر أفقيًا
                          children: [
                            const SizedBox(
                              height: 30.0,
                            ),
                            // const Divider(
                            //     color: Color.fromRGBO(16, 235, 92, 0.903)),

                            const Text(
                              'Add New Beneficiary',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                                height: 16), // إضافة مسافة بين النص والزر
                            ElevatedButton(
                              onPressed: () {
                                // إضافة مستفيد جديد
                                showAddBeneficiaryDialog();
                              },
                              child: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
