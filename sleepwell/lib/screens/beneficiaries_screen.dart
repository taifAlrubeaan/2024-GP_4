import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sleepwell/screens/statistic/real_time_data_screen.dart';
import 'beneficiaries screen/add_eneficiary_screen.dart';
import 'settings_screen.dart';
import 'statistic/sensor_data_screen.dart';

class BeneficiariesScreen extends StatefulWidget {
  const BeneficiariesScreen({super.key});

  @override
  State<BeneficiariesScreen> createState() => _BeneficiariesScreenState();
}

class _BeneficiariesScreenState extends State<BeneficiariesScreen> {
  final List<String> beneficiaries = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Beneficiaries',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       Get.to(() => const SettingsScreen());
        //     },
        //     icon: Icon(
        //       Icons.settings,
        //       color: Colors.grey[300],
        //     ),
        //   ),
        // ],
        backgroundColor: const Color(0xFF004AAD),
      ),
      body: beneficiaries.isEmpty
          ? Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF004AAD), Color(0xFF040E3B)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
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
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => AddBeneficiaryScreen()));
                        Get.to(const AddBeneficiaryScreen());
                      },
                      child: const Icon(Icons.add),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => AddBeneficiaryScreen()));
                        Get.to(const SensorDataScreen());
                        // deleteCollection('feedback').then((_) {
                        //   print('Collection deleted successfully');
                        // }).catchError((error) {
                        //   print('Error deleting collection: $error');
                        // });
                      },
                      child: const Text("SensorDataScreen"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.to(RealTimeDataScreen());
                      },
                      child: const Text("RealTimeDataScreen"),
                    ),
                  ],
                ),
              ),
            )
          : BeneficiariesList(beneficiaries: beneficiaries),
    );
  }

  Future<void> deleteCollection(String collectionPath) async {
    // Reference to the collection
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection(collectionPath);

    // Get all documents in the collection
    var snapshots = await collectionRef.get();

    // Loop through each document and delete it
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }
}

class BeneficiariesList extends StatefulWidget {
  final List<String> beneficiaries;

  const BeneficiariesList({super.key, required this.beneficiaries});

  @override
  State<BeneficiariesList> createState() => _BeneficiariesListState();
}

class _BeneficiariesListState extends State<BeneficiariesList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      // padding: const EdgeInsets.all(30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF004AAD), Color(0xFF040E3B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ListView.builder(
        itemCount: widget.beneficiaries.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(widget.beneficiaries[index]),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // Function to delete beneficiary
              },
            ),
          );
        },
      ),
    );
  }
}
