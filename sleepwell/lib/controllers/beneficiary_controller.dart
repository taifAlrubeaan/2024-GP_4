 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    fetchBeneficiaries(userId!);
  }

  Future<void> fetchBeneficiaries(String userId) async {
    isLoading(true);
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('beneficiaries')
          .where('userid', isEqualTo: userId)
          .get();
      beneficiaries.value = snapshot.docs
          .map((doc) => BeneficiaryModel.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error fetching beneficiaries: $e');
    } finally {
      isLoading(false);
    }
  }

  void setBeneficiaryId(String id) {
    selectedBeneficiaryId.value = id;
  }

  Future<void> addBeneficiary(String name, String watch) async {
    if (userId != null) {
      try {
        BeneficiaryModel newBeneficiary = BeneficiaryModel(
          id: '',
          name: name,
          watch: watch,
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
