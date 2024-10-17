import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleepwell/alarm.dart';
import 'package:sleepwell/widget/clockview.dart';
import '../../controllers/beneficiary_controller.dart';
import '../../push_notification_service.dart';
import '../home_screen.dart';

class AlarmSetupScreen extends StatefulWidget {
  const AlarmSetupScreen({super.key});

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
  int intervalSechend = 0;
  int numOfCycles = 0;

  late DateTime _now;
  late Timer _timer;

  String? userId = FirebaseAuth.instance.currentUser?.uid;

  Future<void> saveUserIdToPrefs(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  String? beneficiaryName;

  Future<void> getBeneficiariesName() async {
    if (beneficiaryId.value.isNotEmpty) {
      try {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('beneficiaries')
            .doc(beneficiaryId
                .value) // استخدم beneficiaryId.value للحصول على القيمة
            .get();

        if (docSnapshot.exists) {
          setState(() {
            beneficiaryName = docSnapshot['name'] ?? 'No Name';
          });
          print('-------------beneficiaryName-----------');
          print(beneficiaryName);
          print('-------------beneficiaryName-----------');
        } else {
          print('Document does not exist');
        }
      } catch (e) {
        print('Error fetching beneficiary name: $e');
      }
    } else {
      print('Beneficiary ID is empty');
    }
  }

  final BeneficiaryController controller = Get.find();
  late RxString beneficiaryId = ''.obs;
  String? selectedBeneficiaryId;
  bool? isForBeneficiary = true;

  @override
  void initState() {
    super.initState();
    selectedBeneficiaryId = controller.selectedBeneficiaryId
        .value; // استخدم .value للحصول على القيمة من RxString

    if (selectedBeneficiaryId != null && selectedBeneficiaryId!.isNotEmpty) {
      isForBeneficiary = false;
      beneficiaryId.value = selectedBeneficiaryId!; // تخصيص القيمة إلى RxString
    } else {
      print('No beneficiary selected');
    }

    getBeneficiariesName();

    print('---------------selectedBeneficiaryId--------------------------');
    print(selectedBeneficiaryId);
    print('-----------selectedBeneficiaryId------------------------------');

    // إعداد باقي عناصر الشاشة
    bedtimeController = TextEditingController();
    wakeUpTimeController = TextEditingController();
    selectedBedtime = TimeOfDay.now();
    selectedWakeUpTime = TimeOfDay.now();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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

    int optimalWakeUpSechend = optimalWakeUpMinutes * 60;
    print(
        "============================::::::::::::optimalWakeUpSechend is:::::: $optimalWakeUpSechend");
    String optimalWakeUpTime = calculateTimeFromMinutes(
        optimalWakeUpMinutes, wakeUpTimeController.text);

    String moreTime = calculateTimeFromMinutes(
        optimalWakeUpMinutes + 15, wakeUpTimeController.text);

    bool compare = compareTimeStringAndTimeOfDay(moreTime, selectedWakeUpTime);
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
      // string durationhours=
      printednumOfCycles = numberOfCycles.toString();
    });

    // التحقق مما إذا كان المنبه لنفس المستخدم أو لأحد التابعين
    // if (isForBeneficiary) {
    //   // إذا كان للمستخدم نفسه
    //   await AppAlarm.saveAlarm(
    //     selectedBedtime,
    //     optimalWakeUpTime,
    //     // isForBeneficiary,
    //     // null,
    //   );
    // } else {
    //   // إذا كان لأحد التابعين
    //   await AppAlarm.saveAlarm(
    //     selectedBedtime,
    //     optimalWakeUpTime,
    //     isForBeneficiary,
    //     selectedBeneficiaryId!,
    //   );
    // }
    bool isForBeneficiary = (selectedBeneficiaryId == null);
    if (selectedBeneficiaryId != null) {
      await AppAlarm.saveAlarm(
        selectedBedtime,
        optimalWakeUpTime,
        beneficiaryId.toString(),
      );
      // استدعاء دالة للحصول على جميع التنبيهات بعد حفظ المنبه الجديد
      await AppAlarm.getAlarms();
    }
    // قد ترغب في عرض رسالة أو تحديث الواجهة بعد الحفظ
    print("Alarm has been saved successfully.");
    calculateSleepDuration(printedBedtime, printedWakeUpTime);
    int currentDay = DateTime.now().day;

    await FirebaseFirestore.instance.collection('alarms').add({
      'bedtime': printedBedtime,
      'wakeup_time': printedWakeUpTime,
      'num_of_cycles': printednumOfCycles,
      'added_day': DateTime.now().day,
      'added_month': DateTime.now().month,
      'added_year': DateTime.now().year,
      'timestamp': FieldValue.serverTimestamp(),
      'uid': userId,
      'beneficiaryId': beneficiaryId.toString(),
      'isForBeneficiary': isForBeneficiary,
    });
    var timestamp = FieldValue.serverTimestamp();
    print("=================================$timestamp");
    print("====================================================");
    print(optimalWakeUpTime);
    print("====================================================");

    await PushNotificationService.showNotification(
      title: 'Your Time To Go To Sleep',
      body: 'Your Sleep Time Is Now. Go To Sleep',
      schedule: true,
      interval: printSechendTime(optimalWakeUpTime),
    );
    print("=======================OptimaL tIME=============================");
    printTimeDifference(optimalWakeUpTime);
    print("==========================End==========================");

    print(
        "=======================Sleep duration Hur=============================");
    // printTimeDifference();
    print("==========================End==========================");

    print("=======================Wake up time=============================");
    printTimeDifference(printedBedtime);
    print("==========================End==========================");

    print("=======================OptimaL tIME=============================");
    printTimeDifference(printednumOfCycles);
    print("==========================End==========================");
    Get.offAll(() => const HomeScreen());
    resetBeneficiaryInfo();
  }

  Future<void> calculateSleepDuration(
      String selectedBedtimeStr, String optimalWakeUpTimeStr) async {
    try {
      // Define the date format
      DateFormat format = DateFormat.jm(); // 'jm' is the format for '1:00 PM'

      // Parse the time strings to DateTime
      DateTime selectedBedtime = format.parse(selectedBedtimeStr);
      DateTime optimalWakeUpTime = format.parse(optimalWakeUpTimeStr);

      // Get the current date
      DateTime now = DateTime.now();

      // Adjust DateTime to include current date
      selectedBedtime = DateTime(now.year, now.month, now.day,
          selectedBedtime.hour, selectedBedtime.minute);
      optimalWakeUpTime = DateTime(now.year, now.month, now.day,
          optimalWakeUpTime.hour, optimalWakeUpTime.minute);

      // If the wakeup time is before the bedtime, assume it's the next day
      if (optimalWakeUpTime.isBefore(selectedBedtime)) {
        optimalWakeUpTime = optimalWakeUpTime.add(const Duration(days: 1));
      }

      // Calculate the sleep duration
      Duration sleepDuration = optimalWakeUpTime.difference(selectedBedtime);
      int sleepHours = sleepDuration.inHours;
      int sleepMinutes = sleepDuration.inMinutes % 60;

      // Print the sleep duration
      print(
          ":::::::::::::::::::::::::::::::::AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA:::::::::::::::::::::::::::::::::::::::::::::::::");
      print('Sleep Duration: $sleepHours hours and $sleepMinutes minutes');
      print(
          ":::::::::::::::::::::::::::::::::AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA:::::::::::::::::::::::::::::::::::::::::::::::::");
    } catch (e) {
      print('Error parsing time strings: $e');
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

  Duration calculateTimeDifference(String optimalWakeUpTime) {
    // Current time
    DateTime now = DateTime.now();

    try {
      // Parse optimalWakeUpTime with AM/PM
      DateTime optimalWakeUpDateTime =
          DateFormat('hh:mm a').parse(optimalWakeUpTime);

      // Combine date and optimalWakeUpTime
      optimalWakeUpDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        optimalWakeUpDateTime.hour,
        optimalWakeUpDateTime.minute,
      );

      // Check if it's AM or PM
      if (optimalWakeUpDateTime.hour < 12) {
        print("Optimal wake-up time is in the AM");
      } else {
        print("Optimal wake-up time is in the PM");
      }

      // Calculate difference
      Duration difference = optimalWakeUpDateTime.difference(now);
      return difference;
    } catch (e) {
      print("Error parsing time: $e");
      return Duration.zero; // Return zero duration in case of an error
    }
  }

  void printTimeDifference(String optimalWakeUpTime) {
    optimalWakeUpTime = optimalWakeUpTime.trim().replaceAll('\u00A0', ' ');

    Duration difference = calculateTimeDifference(optimalWakeUpTime);

    print(
        "Time difference: ${difference.inHours} hours and ${difference.inMinutes.remainder(60)} minutes");
    final CalcSechend = difference.inHours * 60 * 60 +
        (difference.inMinutes.remainder(60) * 60);

    print("::::::::::::::::CalcSechend::::::::::::::::::$CalcSechend");
  }

  int printSechendTime(String optimalWakeUpTime) {
    optimalWakeUpTime = optimalWakeUpTime.trim().replaceAll('\u00A0', ' ');

    Duration difference = calculateTimeDifference(optimalWakeUpTime);
    final CalcSechend = difference.inHours * 60 * 60 +
        (difference.inMinutes.remainder(60) * 60);

    return CalcSechend;
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
      if (currentTime.isBefore(startTime.add(const Duration(minutes: 30)))) {
        // Decrease heart rate gradually from initialHeartRate to 95 bpm
        double progress = currentTime.difference(startTime).inMinutes /
            (startTime.add(const Duration(minutes: 30)).difference(startTime))
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

  void resetBeneficiaryInfo() {
    setState(() {
      beneficiaryName = 'Unknown';
      beneficiaryId.value = '';
      selectedBeneficiaryId = null;
      isForBeneficiary = true; // إعادة تعيين حالة المستفيد
    });
    print('Beneficiary info has been reset');
  }

  @override
  Widget build(BuildContext context) {
    //var now = DateTime.now();
    var formattedDate = DateFormat('EEE, d MMM').format(_now);
    var formattedTime = DateFormat('hh:mm').format(_now);

    //var white = Colors.white;
    //const color = Color.fromARGB(255, 255, 255, 255);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SleepWell Cycle',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF004AAD),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.only(left: 30, bottom: 30, right: 30),
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
            Text(
              beneficiaryId.value.isNotEmpty
                  ? "Set Alarm for $beneficiaryName"
                  : "Set Alarm for Yourself",
              style: const TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Divider(color: Color.fromRGBO(255, 7, 247, 1)),
            SizedBox(height: MediaQuery.of(context).padding.top),
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
                const Align(
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
                ),
              ),
            ),
            const SizedBox(height: 20),
            FloatingActionButton(
              onPressed: () async {
                DateTime now = DateTime.now();
                final nowTime = TimeOfDay.fromDateTime(now);
                bool isForBeneficiary = (selectedBeneficiaryId == null);
                if (selectedBeneficiaryId != null) {
                  print(isForBeneficiary);

                  print(
                      'isForBeneficiaryisForBeneficiaryisForBeneficiaryisForBeneficiary');
                  await AppAlarm.saveAlarm(
                    nowTime,
                    "${nowTime.hour}:${nowTime.minute + 1} AM",
                    beneficiaryId.toString(),
                  );

                  AppAlarm.getAlarms();
                  print(
                      '$isForBeneficiary::::::::::::::::::::::$selectedBeneficiaryId');
                  print(
                      '$isForBeneficiary::::::::::::::::::::::$selectedBeneficiaryId');
                } else {
                  print('::::::: selectedBeneficiaryId=null:::::::::::::::');
                }

                Get.offAll(() => const HomeScreen());
                resetBeneficiaryInfo();
              },
              child: const Icon(Icons.alarm),
            ),
          ],
        ),
      ),
    );
  }
}
