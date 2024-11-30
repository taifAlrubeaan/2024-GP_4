import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/statistics/alarms_statistics_controller.dart';
import '../../models/alarm_model.dart';
import '../../widget/statistic_daily_widget.dart';
import '../../widget/statistic_monthly_widget.dart';
import '../../widget/statistic_weekly_widget.dart';

class UserStatisticsScreen extends StatefulWidget {
  const UserStatisticsScreen({super.key});

  @override
  State<UserStatisticsScreen> createState() => _UserStatisticsScreenState();
}

class _UserStatisticsScreenState extends State<UserStatisticsScreen> {
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  int _selectedIndex = 0;
  String weekRange = '';

  void getWeekRange() {
    final now = DateTime.now();
    final weekEnd = now.subtract(const Duration(days: 1)); // نهاية الأسبوع
    final weekStart = now.subtract(const Duration(days: 7)); // بداية الأسبوع

    weekRange =
        '${DateFormat('d MMM').format(weekStart)} - ${DateFormat('d MMM').format(weekEnd)}';
  }

  @override
  void initState() {
    super.initState();
    getWeekRange();
  }

  @override
  Widget build(BuildContext context) {
    AlarmsStatisticsController alarmsController =
        Get.put(AlarmsStatisticsController());
    alarmsController.fetchLastWeekAlarms(userId!);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF004AAD),
          title: const Text(
            "Statistics",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: PreferredSize(
            preferredSize:
                const Size.fromHeight(60.0), // adjust the height as needed
            child: Column(
              children: [
                TabBar(
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: 'Day'),
                    Tab(text: 'Week'),
                    Tab(text: 'Month'),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            SingleChildScrollView(
              child: FutureBuilder<List<AlarmModelData>>(
                future: alarmsController.fetchLastDayAlarms(userId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text("Error loading data"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    DateTime now = DateTime.now();
                    String timestamp = DateFormat('yyyy-MM-dd: hh:mm a')
                        .format(now)
                        .toString();
                    timestamp =
                        'No data available for yesterday:  This Is Default data\n Do Daily ALarm To View Statistics Daily Like This ';
                    // timestamp = 'Statistic Daily Times In: $timestamp';
                    int numOfCycles = 1;

                    String formattedTime = DateFormat("hh:mm a").format(now);

                    return StatisticDailyWidget(
                      timestamp: timestamp,
                      sleepHoursDuration: '0 h 0 m',
                      wakeup_time: formattedTime,
                      numOfCycles: numOfCycles,
                      actualSleepTime: formattedTime,
                    );
                  } else {
                    final alarms = snapshot.data!;
                    final latestAlarm = alarms.first;
                    String? wakeupTime =
                        latestAlarm.wakeupTime; // وقت الاستيقاظ
                    String? bedtime = latestAlarm.bedtime; // وقت النوم
                    int numOfCycles = latestAlarm.numOfCycles;
                    // String timestamp = latestAlarm.timestamp.toString();
                    String timestamp = DateFormat('yyyy-MM-dd: hh:mm a')
                        .format(latestAlarm.timestamp)
                        .toString();
                    timestamp = 'Statistic Daily for Times:\n $timestamp';
                    DateTime bedtimeDate =
                        DateFormat("hh:mm a").parse(bedtime!);
                    DateTime wakeupTimeDate =
                        DateFormat("hh:mm a").parse(wakeupTime!);

                    Map<String, dynamic> sleepDuration = alarmsController
                        .calculateSleepDuration(bedtimeDate, wakeupTimeDate);

                    String sleepHoursDuration = sleepDuration['formatted'];

                    return StatisticDailyWidget(
                      timestamp: timestamp,
                      sleepHoursDuration: sleepHoursDuration,
                      wakeup_time: wakeupTime,
                      numOfCycles: numOfCycles,
                      actualSleepTime: bedtime,
                    );
                  }
                },
              ),
            ),
            SingleChildScrollView(
              child: FutureBuilder<List<AlarmModelData>>(
                future: alarmsController.fetchLastWeekAlarms(userId!),
                builder: (context, snapshot) {
                  alarmsController.fetchLastWeekAlarms(userId!);
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text("Error loading data"));
                  } else {
                    final alarms = snapshot.data ?? [];
                    log('alarms WeklyGettings Is ${alarms.length.toString()}');
                    // log("snapshot.data ?? []snapshot.data ?? []snapshot.data ?? []");
                    log(alarms.length.toString());
                    log(alarms.length.toString());
                    log(alarms.length.toString());
                    log(alarms.length.toString());
                    // قائمة تحتوي على ساعات النوم ودورات النوم لكل يوم من الأسبوع
                    List<double> sleepHours = List.filled(7, 0.0);
                    List<double> sleepCycles = List.filled(7, 0.0);

                    // معالجة البيانات
                    for (var alarm in alarms) {
                      final alarmDate = alarm.timestamp; // حقل التوقيت
                      final differenceInDays =
                          DateTime.now().difference(alarmDate).inDays;

                      if (differenceInDays >= 0 && differenceInDays < 7) {
                        int index = 6 - differenceInDays;
                        sleepHours[index] = alarm.sleepDuration.inHours
                            .toDouble(); // ساعات النوم
                        sleepCycles[index] =
                            alarm.sleepCycles.toDouble(); // دورات النوم
                      }
                    }

                    // ألوان الأسبوع
                    List<Color> weekColors = [
                      const Color(0xFF26C6DA), // Sun
                      const Color(0xFFDF1EE9), // Mon
                      const Color(0xFF81C784), // Tue
                      const Color(0xFF53C3E9), // Wed
                      Colors.blue, // Thu
                      const Color(0xFF0AE393), // Fri
                      const Color(0xFF53C3E9), // Sat
                    ];

                    // إنشاء الأعمدة (Bar Chart)
                    final barGroups = List.generate(7, (index) {
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: sleepHours[index],
                            color: weekColors[index], // تطابق الألوان
                            width: 16,
                          ),
                        ],
                      );
                    });

                    // إنشاء القطاعات (Pie Chart)
                    final pieSections = List.generate(7, (index) {
                      return PieChartSectionData(
                        value: sleepCycles[index],
                        color: weekColors[index], // تطابق الألوان
                        title: sleepCycles[index] > 0
                            ? sleepCycles[index].toStringAsFixed(1)
                            : '', // عرض القيمة
                        radius: 60,
                      );
                    });

                    // ضبط القيم القصوى للرسم البياني
                    const double chartMaxYweek = 25; // افتراضي
                    final double averageSleepHours = sleepHours
                            .where((value) => value > 0)
                            .fold(0.0, (a, b) => a + b) /
                        sleepHours.where((value) => value > 0).length;

                    // نطاق الأسبوع
                    final DateTime now = DateTime.now();
                    final String weekEnd = DateFormat('yyyy-MM-dd')
                        .format(now.subtract(const Duration(days: 1)));
                    final String weekStart = DateFormat('yyyy-MM-dd')
                        .format(now.subtract(const Duration(days: 7)));
                    final String weekRange = '$weekStart - $weekEnd';

                    // عرض الرسم البياني
                    return StatisticsWeeklyWidget(
                      barGroups: barGroups,
                      pieSections: pieSections,
                      chartMaxYweek: chartMaxYweek,
                      averageSleepHours: averageSleepHours,
                      weekRange: weekRange,
                    );
                  }
                },
              ),
            ),
            SingleChildScrollView(
              child: FutureBuilder<List<AlarmModelData>>(
                future: alarmsController.fetchPreviousMonthAlarms(userId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text("Error loading data"));
                  } else {
                    final alarms = snapshot.data ?? [];

                    final now = DateTime.now(); // Get the current date

                    DateTime firstDayCurrentMonth =
                        DateTime(now.year, now.month, 1);
                    DateTime firstDayPreviousMonth = DateTime(
                        firstDayCurrentMonth.year,
                        firstDayCurrentMonth.month,
                        1);
                    String monthName =
                        DateFormat('MMMM yyyy').format(firstDayPreviousMonth);
                    List<BarChartGroupData> barGroupsMontt = [];
                    List<PieChartSectionData> pieSectionsMonth = [];
                    List<double> sleepHoursMonth = [];
                    List<double> sleepCyclesMonth = [];

                    double averageSleepHoursMonth = 0.0;
                    List<Color> montColors = [
                      const Color(0xFF26C6DA), // WK 1
                      const Color.fromRGBO(223, 30, 233, 1), // WK 2
                      const Color.fromARGB(255, 10, 227, 147), // WK 3
                      const Color(0xFFB3FD12), // WK 4
                    ];

                    List<double> weeklySleepCycles = [
                      0,
                      0,
                      0,
                      0
                    ]; // Sum of sleep cycles for each week
                    List<List<double>> weeklySleepHours = [[], [], [], []];

                    // Calculate the maximum value for chart Y-axis
                    double maxSleepHours = sleepHoursMonth.isNotEmpty
                        ? sleepHoursMonth.reduce((a, b) => a > b ? a : b)
                        : 10.0;
                    double chartMaxYMonth = maxSleepHours + 15;

                    for (var alarm in alarms) {
                      try {
                        String? bedtimeString = alarm.bedtime;
                        String? wakeupTimeString = alarm.wakeupTime;
                        int cyclesString = alarm.numOfCycles;

                        // Parse times with AM/PM format
                        DateTime bedtime =
                            DateFormat('hh:mm a').parse(bedtimeString!);
                        DateTime wakeupTime =
                            DateFormat('hh:mm a').parse(wakeupTimeString!);

                        if (wakeupTime.isBefore(bedtime)) {
                          wakeupTime = wakeupTime.add(const Duration(days: 1));
                        }

                        double sleepDuration =
                            wakeupTime.difference(bedtime).inHours.toDouble();
                        int cycles = cyclesString ?? 0;

                        sleepHoursMonth.add(sleepDuration);
                        sleepCyclesMonth.add(cycles.toDouble());

                        // Calculate weekly data
                        int weekIndex = ((alarm.timestamp.day - 1) / 7).floor();
                        if (weekIndex < 4) {
                          weeklySleepCycles[weekIndex] += cycles.toDouble();
                          weeklySleepHours[weekIndex].add(sleepDuration);
                        }
                      } catch (e) {
                        print("Error parsing time: $e");
                      }
                    }

                    // حساب متوسط ساعات النوم لكل أسبوع
                    List<double> averageWeeklySleepHours =
                        weeklySleepHours.map((hours) {
                      double totalHours = hours.fold(0.0, (a, b) => a + b);
                      return hours.isNotEmpty ? totalHours / hours.length : 0.0;
                    }).toList();
                    print(averageWeeklySleepHours);
                    // حساب مجموع ساعات النوم للشهر
                    double totalSleepHoursMonth =
                        sleepHoursMonth.fold(0.0, (a, b) => a + b);
                    // حساب متوسط ساعات النوم للشهر
                    averageSleepHoursMonth = sleepHoursMonth.isNotEmpty
                        ? totalSleepHoursMonth / sleepHoursMonth.length
                        : 0.0;
                    print(
                        "Average Monthly Sleep Hours: $averageSleepHoursMonth");

                    barGroupsMontt = List.generate(
                      4,
                      (index) => BarChartGroupData(
                        x: index,
                        barRods: [
                          // Bar for average sleep hours
                          BarChartRodData(
                            toY: averageWeeklySleepHours[
                                index], // متوسط ساعات النوم
                            color: Colors.blue,
                            width: 16,
                          ),
                        ],
                      ),
                    );

                    // إعداد المخطط الدائري (Pie Chart) لعرض بيانات دورات النوم لكل أسبوع
                    pieSectionsMonth = List.generate(
                      4,
                      (index) => PieChartSectionData(
                        value: weeklySleepCycles[
                            index], // إجمالي دورات النوم للأسبوع
                        color: montColors[index],
                        title:
                            'W${index + 1}: ${(weeklySleepCycles[index] / 4).toStringAsFixed(1)}C',
                        radius: 60,
                      ),
                    );

                    return StatisticsMonthlyWidget(
                      barGroups: barGroupsMontt,
                      pieSections: pieSectionsMonth,
                      chartMaxYMonthly: chartMaxYMonth,
                      averageMonthlySleepHours: averageSleepHoursMonth,
                      monthName: monthName,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
