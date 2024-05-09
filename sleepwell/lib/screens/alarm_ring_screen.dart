import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter/widgets.dart';
=======
import 'package:sleepwell/feedback/feedback_page.dart';
>>>>>>> 8179d31e3a942c8b14e3c497cd7f96bf200bcbe8
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleepwell/main.dart';

class AlarmRingScreen extends StatelessWidget {
  final AlarmSettings alarmSettings;

  const AlarmRingScreen({super.key, required this.alarmSettings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              "Ringing...\nOptimal time to WAKE UP",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Text("🔔", style: TextStyle(fontSize: 50)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RawMaterialButton(
                  onPressed: () {
                    final now = DateTime.now();
                    int snooze = prefs.getInt("snooze") ??
                        1; // This line will give an error if 'prefs' is not defined in this scope.
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
                RawMaterialButton(
                  onPressed: () async {
                    // Show a dialog asking if the user wants to give feedback
                    final shouldShowFeedbackDialog = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Daily Feedback'),
                          content:
                              Text('Do you want to give you feedback now?'),
                          actions: [
                            TextButton(
                              child: Text('Remiend me later'),
                              onPressed: () {
                                Alarm.stop(alarmSettings.id)
                                    .then((_) => Navigator.pop(context, false));
                              },
                            ),
                            TextButton(
                              child: Text('Yes'),
                              onPressed: () {
                                Alarm.stop(alarmSettings.id)
                                    .then((_) => Navigator.pop(context, true));
                              },
                            ),
                          ],
                        );
                      },
                    );

                    // If the user wants to give feedback, navigate to the FeedbackPage
                    if (shouldShowFeedbackDialog ?? false) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FeedbackPage()),
                      );
                    } else {
                      // Otherwise, stop the alarm and schedule a callback to show the dialog again after an hour
                      Alarm.stop(alarmSettings.id)
                          .then((_) => Navigator.pop(context));
                      Timer(Duration(minutes: 1), () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Daily Feedback'),
                              content:
                                  Text('Do you want to give you feedback now?'),
                              actions: [
                                TextButton(
                                  child: Text('remiend me later'),
                                  onPressed: () {
                                    Alarm.stop(alarmSettings.id).then(
                                        (_) => Navigator.pop(context, false));
                                  },
                                ),
                                TextButton(
                                  child: Text('Yes'),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => FeedbackPage()),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      });
                    }
                  },
                  child: Text(
                    "Stop",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}