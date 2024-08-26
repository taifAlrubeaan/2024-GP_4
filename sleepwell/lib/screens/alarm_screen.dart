import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sleepwell/screens/alarm/alarm_setup_screen.dart';
import 'dart:core';

import '../widget/custom_bottom_bar.dart';

class AlarmScreen extends StatefulWidget {
  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  bool isAlarmAdded = false;
  String printedBedtime = '';
  String printedWakeUpTime = '';
  int numOfCycles = 0;

  @override
  void initState() {
    super.initState();
    checkIfAlarmAddedToday();
  }

  void checkIfAlarmAddedToday() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('alarms')
          .where('added_day', isEqualTo: DateTime.now().day)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var alarmData = querySnapshot.docs.first.data() as Map<String, dynamic>;

        setState(() {
          isAlarmAdded = true;
          printedBedtime = alarmData['bedtime'] ?? '';
          printedWakeUpTime = alarmData['wakeup_time'] ?? '';
          numOfCycles = int.parse(alarmData['num_of_cycles'] ?? '0');
        });
      }
    } catch (e) {
      // Handle errors if needed
      print(e);
    }
  }

  void deleteAlarm() async {
    try {
      // Query the alarm document to delete
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('alarms')
          .where('added_day', isEqualTo: DateTime.now().day)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Get the document ID of the alarm
        String documentID = querySnapshot.docs.first.id;

        // Delete the alarm document
        await FirebaseFirestore.instance
            .collection('alarms')
            .doc(documentID)
            .delete();

        // Update the UI
        setState(() {
          isAlarmAdded = false;
          printedBedtime = '';
          printedWakeUpTime = '';
          numOfCycles = 0;
        });

        // Optionally, display a snackbar to confirm deletion
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Alarm deleted successfully'),
          duration: Duration(seconds: 2),
        ));
      }
    } catch (e) {
      // Handle errors if needed
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Alarm app',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF004AAD),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF004AAD), Color(0xFF040E3B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isAlarmAdded
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Alarm has been Scheduled',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 150,
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Actual sleep time is: $printedBedtime',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Optimal wake-up time is: $printedWakeUpTime',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'You slept for $numOfCycles ${numOfCycles == 1 ? 'sleep cycle' : 'sleep cycles'}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Go to profile page to edit alarm settings",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            // Call the delete alarm function
                            deleteAlarm();
                          },
                          child: const Text('Delete Alarm'),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(
                      Icons.alarm,
                      size: 100,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No alarm created',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'No created alarm. Create a new alarm \nby tapping the + button',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 50),
                    FloatingActionButton(
                      onPressed: () {
                        Get.off(() => const AlarmSetupScreen());
                      },
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: CustomBottomBar(),
    );
  }
}
