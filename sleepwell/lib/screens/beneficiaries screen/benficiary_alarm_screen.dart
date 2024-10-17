import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sleepwell/controllers/alarms_controller.dart';
import 'package:sleepwell/models/alarm_model.dart';

class BeneficiaryAlarmScreen extends StatefulWidget {
  final String beneficiaryId;

  BeneficiaryAlarmScreen({required this.beneficiaryId});

  @override
  _BeneficiaryAlarmScreenState createState() => _BeneficiaryAlarmScreenState();
}

class _BeneficiaryAlarmScreenState extends State<BeneficiaryAlarmScreen> {
  final AlarmsController _alarmsController = AlarmsController();
  late Future<List<AlarmModelData>> _beneficiaryAlarms;

  @override
  void initState() {
    super.initState();
    _beneficiaryAlarms =
        _alarmsController.fetchBeneficiaryLastWeekAlarms(widget.beneficiaryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beneficiary Alarms'),
      ),
      body: FutureBuilder<List<AlarmModelData>>(
        future: _beneficiaryAlarms,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No data found for this beneficiary.'));
          } else {
            final alarms = snapshot.data!;
            String formatTimestamp(DateTime timestamp) {
              DateTime dateTime = timestamp;
              String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
              return formattedDate;
            }

            return ListView.builder(
              itemCount: alarms.length,
              itemBuilder: (context, index) {
                final alarm = alarms[index];
                return ListTile(
                  title: Text('Bedtime: ${alarm.bedtime}'),
                  subtitle: Text(
                      'Wakeup: ${alarm.wakeupTime}      Wakeup: ${formatTimestamp(alarm.timestamp)}'),
                  trailing: Text('Cycles: ${alarm.numOfCycles}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
