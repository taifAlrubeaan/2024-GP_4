import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BeneficiaryDetailsScreen extends StatefulWidget {
  final String beneficiaryName; // اسم التابع

  const BeneficiaryDetailsScreen({
    Key? key,
    required this.beneficiaryName,
  }) : super(key: key);

  @override
  State<BeneficiaryDetailsScreen> createState() => _BeneficiaryDetailsScreenState();
}

class _BeneficiaryDetailsScreenState extends State<BeneficiaryDetailsScreen> {
  String sleepHoursDurationLastDay = '0:0 h';
  String sleepTimeActualLastDay = '0:0';
  String sleepCyclesLastDay = '0 C';
  String wakeUpTimeLastDay = '0:0';

  List<FlSpot> sleepCycleDataLastDay = [];
// END Var DAY
  // String? userId;
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  @override
  void initState() {
    loadDayData();
  }
  // void initState() {
  //   super.initState();
  //   // loadDataForMonth();
  //   // loadDataWeek();
  //   loadDayData();
  //   // getUserId();
  // }

// Day
  Future<void> loadDayData() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await FirebaseFirestore.instance
          .collection('alarms')
          .where('uid', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .where('timestamp', isLessThan: endOfDay)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final alarm = snapshot.docs.first;

        String bedtimeString = alarm['bedtime'];
        String wakeupTimeString = alarm['wakeup_time'];
        String cyclesString = alarm['num_of_cycles'];

        DateTime bedtime = DateFormat('HH:mm').parse(bedtimeString);
        DateTime wakeupTime = DateFormat('HH:mm').parse(wakeupTimeString);

        if (wakeupTime.isBefore(bedtime)) {
          wakeupTime = wakeupTime.add(const Duration(days: 1));
        }

        double sleepDuration =
            wakeupTime.difference(bedtime).inHours.toDouble();
        double actualSleepTime =
            wakeupTime.difference(bedtime).inMinutes / 60.0;
        num cycles = int.tryParse(cyclesString) ?? 0;

        // تحديث القيم لواجهة المستخدم
        setState(() {
          sleepHoursDurationLastDay = '${sleepDuration.toStringAsFixed(1)}h';
          sleepTimeActualLastDay = actualSleepTime.toStringAsFixed(1);
          sleepCyclesLastDay = '$cycles';
          wakeUpTimeLastDay = DateFormat('HH:mm').format(wakeupTime);

          // تحديث بيانات المخطط
          sleepCycleDataLastDay =
              generateSleepCycleDataDay(bedtime, wakeupTime, cycles);
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  List<FlSpot> generateSleepCycleDataDay(
      DateTime bedtime, DateTime wakeupTime, num cycles) {
    List<FlSpot> spots = [];
    double hoursOfSleep = wakeupTime.difference(bedtime).inHours.toDouble();
    double cycleInterval = hoursOfSleep / cycles;

    for (double i = 0; i <= hoursOfSleep; i += cycleInterval) {
      double cycleType = (i % (2 * cycleInterval)) < cycleInterval
          ? 1
          : 2; // Alternating between light and deep sleep
      spots.add(FlSpot(i, cycleType));
    }

    return spots;
  }

  List<String> getFormattedDatesForWeek() {
    final now = DateTime.now();
    // final weekStart = now.subtract(Duration(days: now.weekday));
    final weekStart = now.subtract(const Duration(days: 7));
    final weekEnd = now.subtract(
        const Duration(days: 1)); // Today is the end of the 7-day period

    List<String> formattedDates = [];
    for (int i = 0; i < 7; i++) {
      DateTime date = weekStart.add(Duration(days: i));
      String formattedDate = DateFormat('dd/MM').format(date);
      formattedDates.add(formattedDate);
    }
    return formattedDates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.beneficiaryName} Profile',
          style: const TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF004AAD),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF004AAD), Color(0xFF040E3B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Beneficiary Name: ${widget.beneficiaryName}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              // يمكنك إضافة تفاصيل أخرى هنا
            ],
          ),
        ),
      ),
    );
  }
}
