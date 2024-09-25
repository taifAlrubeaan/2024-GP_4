import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:sleepwell/main.dart';
import 'package:sleepwell/widget/equation_widget.dart';

class AlarmRingWithEquationScreen extends StatelessWidget {
  final AlarmSettings alarmSettings;
  final bool showEasyEquation;

  const AlarmRingWithEquationScreen({
    super.key,
    required this.alarmSettings,
    required this.showEasyEquation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              "Rining...\nOptimal time to WAKE UP",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Text("🔔", style: TextStyle(fontSize: 50)),

            // show the equation widget
            EquationWidget(
                showEasyEquation: showEasyEquation, alarmId: alarmSettings.id),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextButton(
                onPressed: () {
                  final now = DateTime.now();
                  int snooze = prefs.getInt("snooze") ?? 1;
                  Alarm.set(
                    alarmSettings: alarmSettings.copyWith(
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
