import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sleepwell/screens/statistic/beneficiary_statistics_screen.dart';
import 'package:sleepwell/screens/statistic/user_statistics_screen.dart';

class BeneficiariesHomeScreen extends StatefulWidget {
  const BeneficiariesHomeScreen({super.key});

  @override
  State<BeneficiariesHomeScreen> createState() =>
      _BeneficiariesHomeScreenState();
}

class _BeneficiariesHomeScreenState extends State<BeneficiariesHomeScreen> {
  List<DocumentSnapshot> beneficiaries = []; // لتخزين بيانات التابعين
  bool isLoading = true; // لتتبع حالة التحميل
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  // final beneficiaryController =
  //     Get.put(BeneficiaryController(), permanent: true);
  @override
  void initState() {
    super.initState();
    fetchBeneficiaries(userId!);
    userId = FirebaseAuth.instance.currentUser?.uid; // الحصول على userId
    if (userId != null) {
      fetchBeneficiaries(userId!);
    } else {
      // في حالة عدم وجود معرف المستخدم، يمكنك عرض رسالة أو توجيه المستخدم لتسجيل الدخول
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchBeneficiaries(String userId) async {
    setState(() {
      isLoading = true; // بدء حالة التحميل
    });

    try {
      // جلب بيانات التابعين من Firestore
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('beneficiaries')
          .where('userid', isEqualTo: userId)
          .get();

      // التأكد من أن البيانات تم جلبها بنجاح
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          beneficiaries = snapshot.docs; // تخزين البيانات في القائمة
          isLoading = false; // تغيير حالة التحميل
        });

        // طباعة البيانات في وحدة التحكم
        print('Beneficiaries fetched:');
        for (var beneficiary in beneficiaries) {
          print('Name: ${beneficiary['name']}, ID: ${beneficiary.id}');
        }
      } else {
        setState(() {
          beneficiaries = []; // إذا لم يوجد تابعين، تعيين القائمة إلى فارغة
          isLoading = false; // تغيير حالة التحميل
        });
        print('No beneficiaries found for userId: $userId');
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
        Get.snackbar('SuccessFully', 'Your Flowers Added Successfully');
        fetchBeneficiaries(userId!); // إعادة جلب المستفيدين

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
                  // Navigator.of(context).pop(); // إغلاق الحوار
                  // Get.back();
                  // Get.back();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
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
      fetchBeneficiaries(userId!); // إعادة جلب المستفيدين
      Get.snackbar('Success', 'Beneficiary name updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update beneficiary name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // final beneficiaryController = Get.find<BeneficiaryController>();
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : beneficiaries.isEmpty
                // الحالة الأولى: إذا كانت القائمة فارغة
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
                            showAddBeneficiaryDialog();
                          },
                          child: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // عرض القائمة حتى منتصف الشاشة
                      Flexible(
                        flex:
                            2, // يحدد المساحة التي تأخذها القائمة بالنسبة للنصف العلوي
                        child:
                            // GetBuilder<BeneficiaryController>(builder: builder)
                            ListView.builder(
                          itemCount: beneficiaries.length,
                          itemBuilder: (context, index) {
                            final beneficiary = beneficiaries[index];
                            return Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    beneficiary['name'],
                                    // beneficiaryController.getBeneficiary().name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onTap: () {
                                    Get.to(
                                      BeneficiaryStatisticsScreen(
                                          ),
                                    );

                                    // beneficiaryController
                                    //     .setBeneficiary(beneficiary.id);
                                    // beneficiaryController.currentBeneficiary =
                                    //     (beneficiary.id);
                                    // Get.to(
                                    //   BeneficiaryStatisticsScreen(
                                    //       beneficiaryId: beneficiaryController
                                    //           .currentBeneficiary),
                                    // );
                                    // print(
                                    //     '${beneficiaryController.currentBeneficiary}:::::::::::::::::::::::::::;');
                                  },
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          showEditDialog(beneficiary.id,
                                              beneficiary['name']);
                                          // beneficiaryController
                                          //     .getBeneficiary()
                                          //     .name;
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
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
                                                          .pop();
                                                    },
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      deleteBeneficiary(
                                                          beneficiary.id);
                                                      Navigator.of(context)
                                                          .pop();
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
                      ),
                      // زر إضافة مستفيد جديد يظهر في النصف السفلي
                      const SizedBox(height: 20),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Add New Beneficiary',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                showAddBeneficiaryDialog();
                              },
                              child: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
      ),
    );
  }
}
