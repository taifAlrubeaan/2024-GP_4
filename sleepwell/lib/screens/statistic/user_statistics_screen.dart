import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/alarms_controller.dart';
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
    AlarmsController alarmsController = Get.put(AlarmsController());

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
                    return const Center(child: Text("No data available"));
                  } else {
                    final alarms = snapshot.data!;

                    // جلب أول بيانات نوم
                    final latestAlarm = alarms.first;
                    String wakeupTime = latestAlarm.wakeupTime; // وقت الاستيقاظ
                    String bedtime = latestAlarm.bedtime; // وقت النوم
                    String numOfCycles = latestAlarm.numOfCycles;

                    // تحويل الأوقات من String إلى DateTime
                    DateTime bedtimeDate = DateFormat("HH:mm").parse(bedtime);
                    DateTime wakeupTimeDate =
                        DateFormat("HH:mm").parse(wakeupTime);

                    // حساب عدد الساعات الفعلية للنوم
                    Duration sleepDuration =
                        wakeupTimeDate.difference(bedtimeDate);

                    // تحويل مدة النوم إلى عدد ساعات ودقائق
                    String sleepHoursDuration =
                        "${sleepDuration.inHours} h ${sleepDuration.inMinutes.remainder(60)}m";

                    return StatisticDailyWidget(
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
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text("Error loading data"));
                  } else {
                    final alarms = snapshot.data ?? [];

                    // إنشاء قائمة تحتوي على ساعات النوم لكل يوم من الأسبوع
                    List<double> sleepHours = List.filled(7, 0.0);
                    List<double> sleepCycles = List.filled(7, 0.0);

                    // معالجة البيانات لتحديد الأيام الصحيحة
                    for (var alarm in alarms) {
                      final alarmDate =
                          alarm.timestamp; // تأكد من أن لديك حقل التوقيت
                      final differenceInDays =
                          DateTime.now().difference(alarmDate).inDays;
                      print(
                          ':::::::::::::differenceInDays::::::::::::::::::::;;');
                      print(differenceInDays);
                      print(
                          ':::::::::::::::differenceInDays::::::::::::::::::;;');
                      if (differenceInDays >= 0 && differenceInDays <= 7) {
                        sleepHours[7 - differenceInDays] = alarm
                            .sleepDuration.inHours
                            .toDouble(); // 6 - difference لإدخال القيمة في العمود الصحيح
                        sleepCycles[7 - differenceInDays] = alarm.sleepCycles
                            .toDouble(); // 6 - difference لإدخال القيمة في العمود الصحيح
                      }
                    }

                    // توليد barGroups بناءً على sleepHours
                    final barGroups = List.generate(7, (index) {
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: sleepHours[index], // استخدام القيمة مباشرة
                            color: Colors.blue,
                            width: 16,
                          ),
                        ],
                      );
                    });

                    List<Color> weekColors = [
                      const Color(0xFF26C6DA), // Sun
                      const Color.fromRGBO(223, 30, 233, 1), // Mon
                      const Color(0xFF81C784), // Tue
                      const Color(0xFF53C3E9), // Wed
                      Colors.blue, // Thu
                      const Color.fromARGB(255, 10, 227, 147), // Fri
                      const Color(0xFF53C3E9), // Sat
                    ];

                    // توليد pieSections بناءً على sleepCycles
                    final pieSections = List.generate(7, (index) {
                      return PieChartSectionData(
                        value: sleepCycles[index], // استخدام القيمة مباشرة
                        color: weekColors[index],
                        title: '${sleepCycles[index]}', // عرض القيمة
                        radius: 60,
                      );
                    });

                    const double chartMaxYweek = 20; // قيمة افتراضية
                    final double averageSleepHours =
                        sleepHours.reduce((a, b) => a + b) / sleepHours.length;

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
                    final firstDayOfMonth =
                        DateTime(now.year, now.month, 1); // Start of the month
                    String monthName =
                        DateFormat('MMMM yyyy').format(firstDayOfMonth);

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
                    List<List<double>> weeklySleepHours = [
                      [],
                      [],
                      [],
                      []
                    ]; // Store sleep hours per week

                    // Calculate the maximum value for chart Y-axis
                    double maxSleepHours = sleepHoursMonth.isNotEmpty
                        ? sleepHoursMonth.reduce((a, b) => a > b ? a : b)
                        : 10.0;
                    double chartMaxYMonth = maxSleepHours + 15;

                    for (var alarm in alarms) {
                      String bedtimeString = alarm.bedtime;
                      String wakeupTimeString = alarm.wakeupTime;
                      String cyclesString = alarm.numOfCycles;

                      // Parse times with AM/PM format
                      DateTime bedtime =
                          DateFormat('hh:mm a').parse(bedtimeString);
                      DateTime wakeupTime =
                          DateFormat('hh:mm a').parse(wakeupTimeString);

                      if (wakeupTime.isBefore(bedtime)) {
                        wakeupTime = wakeupTime.add(const Duration(days: 1));
                      }

                      double sleepDuration =
                          wakeupTime.difference(bedtime).inHours.toDouble();
                      int cycles = int.tryParse(cyclesString) ?? 0;

                      sleepHoursMonth.add(sleepDuration);
                      sleepCyclesMonth.add(cycles.toDouble());

                      // Calculate weekly data
                      int weekIndex = ((alarm.timestamp.day - 1) / 7).floor();
                      if (weekIndex < 4) {
                        weeklySleepCycles[weekIndex] += cycles.toDouble();
                        weeklySleepHours[weekIndex].add(sleepDuration);
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

                    // إعداد المخطط الشريطي (Bar Chart) لعرض متوسط ساعات النوم ودورات النوم لكل أسبوع
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
                          // Bar for sleep cycles
                          // BarChartRodData(
                          //   toY: weeklySleepCycles[index], // عدد دورات النوم
                          //   color: Colors.green,
                          //   width: 16,
                          // ),
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
