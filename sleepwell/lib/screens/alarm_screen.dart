import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:core';

import 'alarm/SleepWellCycleScreen/sleepwell_cycle_screen.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  bool isAlarmAdded = false;
  String printedBedtime = '';
  String printedWakeUpTime = '';
  int numOfCycles = 0;
// final userid = FirebaseFirestore.instance.doc('documentPath');
  // final userids = FirebaseFirestore.instance.collection('Users').doc('userId');
  // String? userId;
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  @override
  void initState() {
    super.initState();
    print('::::::::::::::::::::::::::uid:::::::::::::::::::');
    print(userId);
    print('::::::::::::::::::::::::::uid:::::::::::::::::::');
    checkIfAlarmAddedToday();
    // getUserId();
    print(userId);
  }

  void checkIfAlarmAddedToday() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('alarms')
          .where('uid', isEqualTo: userId)
          .where('isForBeneficiary', isEqualTo: true)
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
          .where('uid', isEqualTo: userId)
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
            .where('uid', isEqualTo: userId)
            .get()
            .then((querySnapshot) {
          for (var doc in querySnapshot.docs) {
            if (doc.id == documentID) {
              doc.reference.delete();
            }
          }
        });

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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
        height: screenHeight,
        width: screenWidth, // Make the container responsive
        padding: EdgeInsets.all(screenHeight * 0.03), // Responsive padding
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF004AAD), Color(0xFF040E3B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isAlarmAdded
            ? Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  deleteAlarm();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Alarm deleted successfully'),
                  ));
                },
                child: Column(
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
                    SizedBox(
                      height: screenHeight * 0.2, // Replace fixed height
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
                          SizedBox(
                              height:
                                  screenHeight * 0.02), // Responsive spacing
                          Text(
                            'Optimal wake-up time is: $printedWakeUpTime',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Text(
                            'You slept for $numOfCycles ${numOfCycles == 1 ? 'sleep cycle' : 'sleep cycles'}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          const Text(
                            "Go to profile page to edit alarm settings",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          ElevatedButton(
                            onPressed: () {
                              // Call the delete alarm function
                              deleteAlarm();
                            },
                            child: const Text('Delete Alarm'),
                          ),
                          // FloatingActionButton(
                          //   onPressed: () {
                          //     print(":::::::::::::::;");
                          //     print(userId);
                          //   },
                          //   child: const Icon(Icons.ad_units),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                    SizedBox(height: screenHeight * 0.03),
                    const Text(
                      'No alarm created',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    const Text(
                      'No created alarm. Create a new alarm \nby tapping the + button',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    FloatingActionButton(
                      onPressed: () {
                        Get.to(SleepWellCycleScreen());
                      },
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
      ),
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
// 10:20
// 11:50
// 6
