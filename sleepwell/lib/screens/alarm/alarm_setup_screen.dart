import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sleepwell/alarm.dart';
import 'package:sleepwell/screens/alarm_screen.dart';
import 'package:sleepwell/screens/clockview.dart';

class AlarmSetupScreen extends StatefulWidget {
  static String RouteScreen = 'alarm_screen';

  const AlarmSetupScreen({Key? key}) : super(key: key);

  @override
  State<AlarmSetupScreen> createState() => _AlarmSetupScreenState();
}

class _AlarmSetupScreenState extends State<AlarmSetupScreen> {
  late TextEditingController bedtimeController;
  late TextEditingController wakeUpTimeController;
  late TimeOfDay selectedBedtime;
  late TimeOfDay selectedWakeUpTime;

  String printedBedtime = '';
  String printedWakeUpTime = '';
  String printednumOfCycles = '';
  int numOfCycles = 0;

  late DateTime _now;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    bedtimeController = TextEditingController();
    wakeUpTimeController = TextEditingController();
    selectedBedtime = TimeOfDay.now();
    selectedWakeUpTime = TimeOfDay.now();
    _now = DateTime.now();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    bedtimeController.dispose();
    wakeUpTimeController.dispose();
    _timer.cancel();
    super.dispose();
  }

  Future<TimeOfDay?> _showBedtimePicker() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        print('this is the selected bedtime');
        print(pickedTime);
        bedtimeController.text = pickedTime.format(context);
        selectedBedtime = pickedTime;
      });
    }

    return pickedTime;
  }

  void _showWakeUpTimePicker() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedWakeUpTime,
    );

    if (pickedTime != null) {
      setState(() {
        print('this is the selected wake up time');
        print(pickedTime);
        selectedWakeUpTime = pickedTime;
        wakeUpTimeController.text = pickedTime.format(context);
      });
    }
  }

  void _saveTimes() async {
    TimeOfDay? selectedTime = selectedBedtime;

    if (selectedTime != null) {
      List<Map<String, int>> myHourList = timeAndHeart(selectedTime);

      int bedtimeIndex = 0;
      int bedtimeMinutes = 0;
      int sleepCycleMinutes = 90; // Duration of each sleep cycle in minutes

      int? firstRead = myHourList[0]['heartRate'];
      int? diff = (firstRead! * 0.2).toInt();
      int? toComp = firstRead - diff;

      for (int i = 0; i < myHourList.length; i++) {
        if (myHourList[i]['heartRate']! < toComp) {
          bedtimeIndex = i;
          break;
        }
      }

      if (bedtimeIndex > 0) {
        bedtimeMinutes = myHourList[bedtimeIndex]['hour']! * 60 +
            myHourList[bedtimeIndex]['minute']!;
      } else {
        bedtimeMinutes = myHourList[myHourList.length - 1]['hour']! * 60 +
            myHourList[myHourList.length - 1]['minute']!;
      }

      int wakeUpTimeMinutes =
          selectedWakeUpTime.hour * 60 + selectedWakeUpTime.minute;

      if (wakeUpTimeMinutes < bedtimeMinutes) {
        wakeUpTimeMinutes += 24 * 60;
      }

      int totalSleepTimeMinutes = wakeUpTimeMinutes - bedtimeMinutes;
      int numberOfCycles = (totalSleepTimeMinutes / 90).floor();
      numOfCycles = numberOfCycles;

      int optimalWakeUpMinutes =
          bedtimeMinutes + (numberOfCycles * sleepCycleMinutes);
      String optimalWakeUpTime = calculateTimeFromMinutes(
          optimalWakeUpMinutes, wakeUpTimeController.text);

      String moreTime = calculateTimeFromMinutes(
          optimalWakeUpMinutes + 15, wakeUpTimeController.text);

      bool compare =
          compareTimeStringAndTimeOfDay(moreTime, selectedWakeUpTime);
      if (compare) {
        optimalWakeUpTime = moreTime;
      }

      setState(() {
        int? hour = myHourList[bedtimeIndex]['hour'];
        int? minute = myHourList[bedtimeIndex]['minute'];
        String period = (hour! < 12) ? 'AM' : 'PM';
        hour = (hour > 12) ? hour - 12 : hour;

        printedBedtime = '$hour:${minute.toString().padLeft(2, '0')} $period';
        printedWakeUpTime = optimalWakeUpTime;
        printednumOfCycles = numberOfCycles.toString();
      });

      await AppAlarm.saveAlarm(selectedBedtime, optimalWakeUpTime);
      AppAlarm.getAlarms();

      int currentDay = DateTime.now().day;

      await FirebaseFirestore.instance.collection('alarms').add({
        'bedtime': printedBedtime,
        'wakeup_time': printedWakeUpTime,
        'num_of_cycles': printednumOfCycles,
        'added_day': currentDay,
        'timestamp': FieldValue.serverTimestamp(),
      });
      var timestamp = FieldValue.serverTimestamp();
      print("=================================$timestamp");
      Get.off(() => AlarmScreen());
    }
  }

  String calculateTimeFromMinutes(int minutes, String referenceTime) {
    int hours = minutes ~/ 60;
    int mins = minutes % 60;
    TimeOfDay timeOfDay = TimeOfDay(hour: hours, minute: mins);
    DateTime dateTime = DateFormat('hh:mm a').parse(referenceTime);
    dateTime = DateTime(dateTime.year, dateTime.month, dateTime.day,
        timeOfDay.hour, timeOfDay.minute);
    return DateFormat('hh:mm a').format(dateTime);
  }

  int calculateMinutesFromTime(String time) {
    TimeOfDay timeOfDay =
        TimeOfDay.fromDateTime(DateFormat('hh:mm a').parse(time));
    return (timeOfDay.hour * 60) + timeOfDay.minute;
  }

  bool compareTimeStringAndTimeOfDay(String timeString, TimeOfDay timeOfDay) {
    List<String> parts = timeString.split(' ');
    List<String> timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    if (parts[1] == 'PM' && hour != 12) {
      hour += 12;
    }

    DateTime parsedDateTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      hour,
      minute,
    );

    DateTime targetDateTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      timeOfDay.hour,
      timeOfDay.minute,
    );

    return parsedDateTime.isBefore(targetDateTime) ||
        parsedDateTime.isAtSameMomentAs(targetDateTime);
  }

  List<Map<String, int>> timeAndHeart(TimeOfDay bedtime) {
    List<Map<String, int>> myHourList = [];

    DateTime now = DateTime.now();
    DateTime startTime = DateTime(
      now.year,
      now.month,
      now.day,
      bedtime.hour,
      bedtime.minute,
    );

    DateTime endTime = startTime.add(const Duration(hours: 1));

    int initialHeartRate = 120;
    int finalHeartRate = 50;

    DateTime currentTime = startTime;
    Random random = Random();
    while (currentTime.isBefore(endTime)) {
      int heartRate;
      if (currentTime.isBefore(startTime.add(Duration(minutes: 30)))) {
        // Decrease heart rate gradually from initialHeartRate to 95 bpm
        double progress = currentTime.difference(startTime).inMinutes /
            (startTime.add(Duration(minutes: 30)).difference(startTime))
                .inMinutes;

        int decreaseAmount = (progress * (initialHeartRate - 95)).round();
        heartRate = initialHeartRate - decreaseAmount;
      } else {
        // Decrease heart rate gradually from 95 bpm to finalHeartRate
        double progress = currentTime
                .difference(startTime.add(const Duration(minutes: 30)))
                .inMinutes /
            (endTime.difference(startTime.add(const Duration(minutes: 30))))
                .inMinutes;

        int decreaseAmount = (progress * (95 - finalHeartRate)).round();
        heartRate = 95 - decreaseAmount;
      }

      myHourList.add({
        'hour': currentTime.hour,
        'minute': currentTime.minute,
        'heartRate': heartRate,
      });

      // Generate a random duration between 10 and 20 minutes
      int randomDuration = 10 + random.nextInt(11);
      currentTime = currentTime.add(Duration(minutes: randomDuration));
    }

    return myHourList;
  }

  int timeDifferenceInMinutes(TimeOfDay start, TimeOfDay end) {
    final startTime = start.hour * 60 + start.minute;
    final endTime = end.hour * 60 + end.minute;
    return (endTime - startTime).abs();
  }

  void _checkAndSaveTimes() {
    if (timeDifferenceInMinutes(selectedBedtime, selectedWakeUpTime) < 120) {
      // Show warning dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              "Warning",
              style: TextStyle(color: Colors.red),
            ),
            content: const Text(
                "please select the wake up time with at least 2 hours deffrence"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Navigator.of(context).pop(); // Close the dialog
                  Get.back();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    } else {
      _saveTimes(); // Proceed to save times if the difference is sufficient
    }
  }

  @override
  Widget build(BuildContext context) {
    //var now = DateTime.now();
    var formattedDate = DateFormat('EEE, d MMM').format(_now);
    var formattedTime = DateFormat('hh:mm').format(_now);

    //var white = Colors.white;
    //const color = Color.fromARGB(255, 255, 255, 255);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 16, 95, 199),
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
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).padding.top),
            const Text(
              'SleepWell Cycle',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 20,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 40,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: ClockView(),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      "BEDTIME",
                      style: TextStyle(
                        color: Color(0xffff0863),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.3,
                      ),
                    ),
                    GestureDetector(
                      onTap: _showBedtimePicker,
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: bedtimeController,
                          decoration: const InputDecoration(
                            hintText: "Select bedtime",
                            hintStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: const TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "WAKE UP TIME",
                      style: TextStyle(
                          color: Color(0xffff0863),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.3),
                    ),
                    GestureDetector(
                      onTap: _showWakeUpTimePicker,
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: wakeUpTimeController,
                          decoration: const InputDecoration(
                            hintText: "Select wake-up time",
                            hintStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: const TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
                alignment: Alignment.center,
                child: Center(
                    child: TextButton(
                  onPressed: _checkAndSaveTimes,
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.pink),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  child: const Text('Save'),
                ))),
            const SizedBox(height: 20),
            TextButton(
                onPressed: () {
                  Get.to(AlarmScreen());
                },
                child: const Text(
                  "GoTo Alarm Screen",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     DateTime now = DateTime.now();
      //     final nowTime = TimeOfDay.fromDateTime(now);
      //     // Adding one minute to the current time
      //     final newTime = nowTime.replacing(
      //       hour: nowTime.hourOfPeriod,
      //       minute: nowTime.minute + 1,
      //     );
      //     // Saving the alarm with the updated time
      //     await AppAlarm.saveAlarm(
      //       newTime,
      //       "${newTime.hour}:${newTime.minute} ${newTime.period == DayPeriod.am ? 'PM' : 'AM'}",
      //     );
      //     // Getting all alarms
      //     AppAlarm.getAlarms();
      //   },
      //   child: const Icon(Icons.alarm),
      // ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          DateTime now = DateTime.now();
          final nowTime = TimeOfDay.fromDateTime(now);
          await AppAlarm.saveAlarm(
              nowTime, "${nowTime.hour}:${nowTime.minute + 1} AM");
          AppAlarm.getAlarms();
        },
        child: const Icon(Icons.alarm),
      ),
    );
  }
}

