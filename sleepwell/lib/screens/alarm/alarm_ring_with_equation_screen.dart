import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:sleepwell/main.dart';
import 'package:sleepwell/widget/equation_widget.dart';
import '../../models/alarm_data.dart';

class AlarmRingWithEquationScreen extends StatefulWidget {
  final AlarmSettings alarmSettings;
  final bool showEasyEquation;
  final AlarmData alarmsData;
  const AlarmRingWithEquationScreen({
    super.key,
    required this.alarmSettings,
    required this.showEasyEquation,
    required this.alarmsData,
  });

  @override
  State<AlarmRingWithEquationScreen> createState() =>
      _AlarmRingWithEquationScreenState();
}

class _AlarmRingWithEquationScreenState
    extends State<AlarmRingWithEquationScreen> {
  late String name;
  late bool userType;

  @override
  void initState() {
    super.initState();
    name = widget.alarmsData.name;
    userType = widget.alarmsData.usertype;
  }

  @override
  Widget build(BuildContext context) {
    final String title =
        "Ringing...\nOptimal time to WAKE UP\n for Yourself   $name";

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
              isForBeneficiary: userType!,
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
