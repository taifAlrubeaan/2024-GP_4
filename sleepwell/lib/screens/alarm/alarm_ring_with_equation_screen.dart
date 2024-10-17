import 'package:alarm/alarm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sleepwell/controllers/beneficiary_controller.dart';
import 'package:sleepwell/main.dart';
import 'package:sleepwell/widget/equation_widget.dart';

class AlarmRingWithEquationScreen extends StatefulWidget {
  final AlarmSettings alarmSettings;
  final bool showEasyEquation;

  const AlarmRingWithEquationScreen({
    super.key,
    required this.alarmSettings,
    required this.showEasyEquation,
  });

  @override
  State<AlarmRingWithEquationScreen> createState() =>
      _AlarmRingWithEquationScreenState();
}

class _AlarmRingWithEquationScreenState
    extends State<AlarmRingWithEquationScreen> {
  String beneficiaryName = 'Unknown';
  final BeneficiaryController controller = Get.find();

  late RxString beneficiaryId = ''.obs;

  String? selectedBeneficiaryId;
  bool? isForBeneficiary = true;

  @override
  void initState() {
    super.initState();
    selectedBeneficiaryId = controller.selectedBeneficiaryId.value;

    if (selectedBeneficiaryId != null && selectedBeneficiaryId!.isNotEmpty) {
      isForBeneficiary = false;
      beneficiaryId.value = selectedBeneficiaryId!;
      getBeneficiariesName(beneficiaryId.value);
    }
  }

  Future<void> getBeneficiariesName(String beneficiaryId) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('beneficiaries')
        .doc(beneficiaryId)
        .get();

    if (docSnapshot.exists) {
      setState(() {
        beneficiaryName = docSnapshot['name'] ?? 'No Name';
      });
    } else {
      setState(() {
        beneficiaryName = 'No Name';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = isForBeneficiary!
        ? "Ringing...\nOptimal time to WAKE UP for Yourself"
        : "Ringing...\nOptimal time to WAKE UP for $beneficiaryName";

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Text("🔔", style: TextStyle(fontSize: 50)),

            // Show the equation widget
            EquationWidget(
              showEasyEquation: widget.showEasyEquation,
              alarmId: widget.alarmSettings.id,
              isForBeneficiary: isForBeneficiary!,
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextButton(
                onPressed: () {
                  final now = DateTime.now();
                  int snooze = prefs.getInt("snooze") ?? 1;
                  Alarm.set(
                    alarmSettings: widget.alarmSettings.copyWith(
                      dateTime: DateTime(
                        now.year,
                        now.month,
                        now.day,
                        now.hour,
                        now.minute,
                        0,
                        0,
                      ).add(Duration(minutes: snooze)),
                    ),
                  ).then((_) => Navigator.pop(context));
                },
                child: Text(
                  "Snooze",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
