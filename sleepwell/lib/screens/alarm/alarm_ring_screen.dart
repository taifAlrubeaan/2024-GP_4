import 'package:alarm/alarm.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/alarm_data.dart';
import '../feedback/feedback_page.dart';
import '../home_screen.dart';
// alarm_ring_screen.dart

class AlarmRingScreen extends StatefulWidget {
  final AlarmSettings alarmSettings;
  final AlarmData alarmsData;
  AlarmRingScreen(
      {Key? key, required this.alarmSettings, required this.alarmsData})
      : super(key: key);

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen> {
  late String name;
  late bool userType;

  @override
  void initState() {
    super.initState();
    // final Map<String, dynamic> alarmsData = Get.arguments ?? {};
    name = widget.alarmsData.name;
    userType = widget.alarmsData.usertype;
  }

  @override
  Widget build(BuildContext context) {
    final String title = "Ringing...\nOptimal time to WAKE UP\n for $name";
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Text("🔔", style: TextStyle(fontSize: 50)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    DateTime now = DateTime.now();
                    Alarm.set(
                      alarmSettings: widget.alarmSettings.copyWith(
                        dateTime: now.add(const Duration(minutes: 5)),
                      ),
                    ).then((_) => Navigator.pop(context));
                  },
                  child: const Text("Snooze"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await Alarm.stop(widget.alarmSettings.id);
                    Get.offAll(() =>
                        userType ? const FeedbackPage() : const HomeScreen());
                  },
                  child: Text("Stop"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
