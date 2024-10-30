import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import '../models/beneficiary_model.dart';

class BeneficiaryController extends GetxController {
  var beneficiaries = <BeneficiaryModel>[].obs;
  var isLoading = true.obs;
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  var selectedBeneficiaryId = ''.obs;
  @override
  void onInit() {
    super.onInit();
    if (userId != null) {
      print('User ID: $userId');
      fetchBeneficiaries(userId!);
    } else {
      print('Error: User ID is null');
    }
  }

  Future<void> fetchBeneficiaries(String userId) async {
    try {
      isLoading(true); // بدأ تحميل البيانات
      print('Fetching beneficiaries for userId: $userId');

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('beneficiaries')
          .where('userid', isEqualTo: userId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        print('Beneficiaries found: ${snapshot.docs.length}');
        beneficiaries.value = snapshot.docs
            .map((doc) => BeneficiaryModel.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList();
      } else {
        print('No beneficiaries found for userId: $userId');
      }
    } catch (e) {
      print('Error fetching beneficiaries: $e');
    } finally {
      // تأخير تحديث حالة isLoading إلى ما بعد الانتهاء من البناء
      SchedulerBinding.instance.addPostFrameCallback((_) {
        isLoading(false);
      });
    }
  }

  var selectedBeneficiaryDevice = ''.obs;

  // تعيين المستفيد النشط
  void setBeneficiaryId(String id) {
    selectedBeneficiaryId.value = id;
    // loadSavedDevice(id); // تحميل الجهاز المحفوظ عند تغيير المستفيد
  }

  Future<void> addBeneficiary(String name,
  //  String watch
   ) async {
    if (userId != null) {
      try {
        BeneficiaryModel newBeneficiary = BeneficiaryModel(
          id: '',
          name: name,
          // watch: watch,
          userId: userId!,
        );
        await FirebaseFirestore.instance
            .collection('beneficiaries')
            .add(newBeneficiary.toMap());
        fetchBeneficiaries(userId!);
        Get.snackbar('Success', 'Beneficiary added successfully');
      } catch (e) {
        Get.snackbar('Error', 'Failed to add beneficiary: $e');
      }
    }
  }

  Future<void> deleteBeneficiary(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('beneficiaries')
          .doc(id)
          .delete();
      fetchBeneficiaries(userId!);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete beneficiary: $e');
    }
  }

  Future<void> updateBeneficiaryName(String id, String newName) async {
    try {
      await FirebaseFirestore.instance
          .collection('beneficiaries')
          .doc(id)
          .update({'name': newName});
      fetchBeneficiaries(userId!);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update beneficiary name: $e');
    }
  }
}
