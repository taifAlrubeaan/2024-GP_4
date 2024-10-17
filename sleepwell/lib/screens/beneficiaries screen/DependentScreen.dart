import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sleepwell/controllers/alarms_controller.dart';
import 'package:sleepwell/models/alarm_model.dart';

class DependentScreen extends StatefulWidget {
  // const DependentScreen({super.key});

  // final String userId;

  // DependentScreen({required this.userId});

  @override
  _DependentScreenState createState() => _DependentScreenState();
}

class _DependentScreenState extends State<DependentScreen> {
  final AlarmsController _alarmsController = AlarmsController();
  late Future<List<AlarmModelData>> _dependentAlarms;
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  @override
  void initState() {
    super.initState();
    _dependentAlarms = _alarmsController.fetchLastWeekAlarms(
      userId!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dependent Alarms'),
      ),
      body: FutureBuilder<List<AlarmModelData>>(
        future: _dependentAlarms,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No data found for this dependent.'));
          } else {
            String formatTimestamp(DateTime timestamp) {
              DateTime dateTime = timestamp;
              String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
              return formattedDate;
            }

            final alarms = snapshot.data!;
            return ListView.builder(
              itemCount: alarms.length,
              itemBuilder: (context, index) {
                final alarm = alarms[index];
                return ListTile(
                  title: Text('Bedtime: ${alarm.bedtime}'),
                  subtitle: Text('Wakeup: ${alarm.wakeupTime}'),
                  trailing: Text(
                      'Cycles: ${alarm.numOfCycles}:timestamp ${formatTimestamp(alarm.timestamp)}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
