import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sleepwell/screens/statistic/beneficiary_statistics_screen.dart';
import '../controllers/beneficiary_controller.dart';
import 'settings/sensor_setting_screen.dart';

class BeneficiariesScreen extends StatelessWidget {
  final BeneficiaryController beneficiaryController =
      Get.put(BeneficiaryController());
  var selectedBeneficiaryId = ''.obs;

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
        child: Obx(() {
          if (beneficiaryController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (beneficiaryController.beneficiaries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No beneficiaries added'),
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
              Flexible(
                flex: 2,
                child: ListView.builder(
                  itemCount: beneficiaryController.beneficiaries.length,
                  itemBuilder: (context, index) {
                    final beneficiary =
                        beneficiaryController.beneficiaries[index];
                    return Column(
                      children: [
                        ListTile(
                          title: Text(
                            beneficiary.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          onTap: () async {
                            // Get.to(
                            //   BeneficiaryStatisticsScreen(
                            //       beneficiaryId: beneficiary.id),
                            // );
                            final BeneficiaryController controller =
                                Get.put(BeneficiaryController());
                            controller.setBeneficiaryId(beneficiary.id);
                            Get.to(BeneficiaryStatisticsScreen());
                            // selectedBeneficiaryId.value = beneficiary.id;
                            print(selectedBeneficiaryId);
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
              const SizedBox(height: 16),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Add New Beneficiary',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        showAddBeneficiaryDialog(context);
                        // Get.to(SensorSettingScreen());
                      },
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          );
        }),
      ),
    );
  }

  void showAddBeneficiaryDialog(BuildContext context) {
    final nameController = TextEditingController();
    // final watchController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add New Beneficiary'),
        content: SingleChildScrollView(
          child: SizedBox(
            height: 150, // Adjust height as needed
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Ensures column takes minimal space
              children: [
                TextField(
                  controller: nameController,
                  decoration:
                      const InputDecoration(labelText: 'Beneficiary Name'),
                ),
                // const TextField(
                //   // controller: watchController,
                //   decoration: InputDecoration(labelText: 'Watch'),
                // ),
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
              if (nameController.text.isNotEmpty
                  //&& watchController.text.isNotEmpty
                  ) {
                Get.find<BeneficiaryController>()
                    .addBeneficiary(nameController.text
                        //  watchController.text
                        );
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
