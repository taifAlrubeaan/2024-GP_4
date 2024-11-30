import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sleepwell/screens/statistic/beneficiary_statistics_screen.dart';
import '../controllers/beneficiary_controller.dart';

class BeneficiariesScreen extends StatelessWidget {
  final BeneficiaryController beneficiaryController =
      Get.put(BeneficiaryController());

  BeneficiariesScreen({super.key});

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
        child: GetBuilder<BeneficiaryController>(
          builder: (controller) {
            final String? userId = FirebaseAuth.instance.currentUser?.uid;
            controller.fetchBeneficiaries(userId!);
            if (userId == null) {
              return const Center(
                child: Text(
                  'User not logged in',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            // Fetch beneficiaries if not already fetched
            if (!controller.isLoading.value &&
                controller.beneficiaries.isEmpty) {
              controller.fetchBeneficiaries(userId);
            }

            // if (controller.isLoading.value) {
            //   return const Center(child: CircularProgressIndicator());
            // }

            if (controller.beneficiaries.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'No beneficiaries added',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => showAddBeneficiaryDialog(context),
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.beneficiaries.length,
                    itemBuilder: (context, index) {
                      final beneficiary = controller.beneficiaries[index];
                      return Column(
                        children: [
                          ListTile(
                            title: Text(
                              beneficiary.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            onTap: () {
                              controller.setBeneficiaryId(beneficiary.id);
                              Get.to(() => const BeneficiaryStatisticsScreen());
                            },
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  color: Colors.white,
                                  onPressed: () {
                                    showEditDialog(context, beneficiary.id,
                                        beneficiary.name);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  color: Colors.white,
                                  onPressed: () {
                                    showDeleteDialog(context, beneficiary.id);
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
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'Add New Beneficiary',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => showAddBeneficiaryDialog(context),
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            );
          },
        ),
      ),
    );
  }

  void showAddBeneficiaryDialog(BuildContext context) {
    final nameController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add New Beneficiary'),
        content: SingleChildScrollView(
          child: SizedBox(
            height: 150,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration:
                      const InputDecoration(labelText: 'Beneficiary Name'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                Get.find<BeneficiaryController>()
                    .addBeneficiary(nameController.text);
                Get.back();
              } else {
                Get.snackbar('Warning', 'Please fill all fields');
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void showEditDialog(BuildContext context, String id, String currentName) {
    final editController = TextEditingController(text: currentName);
    Get.dialog(
      AlertDialog(
        title: const Text('Edit Beneficiary Name'),
        content: TextField(
            controller: editController,
            decoration: const InputDecoration(hintText: 'Enter new name')),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (editController.text.isNotEmpty) {
                Get.find<BeneficiaryController>()
                    .updateBeneficiaryName(id, editController.text);
                Get.back();
              } else {
                Get.snackbar('Warning', 'Name cannot be empty');
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void showDeleteDialog(BuildContext context, String id) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Beneficiary'),
        content:
            const Text('Are you sure you want to delete this beneficiary?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.find<BeneficiaryController>().deleteBeneficiary(id);
              Get.back();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
