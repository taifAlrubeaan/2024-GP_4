import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sleepwell/widget/statistic_monthly_widget.dart';
import '../../controllers/statistics/alarms_statistics_controller.dart';
import '../../controllers/beneficiary_controller.dart';
import '../../models/alarm_model.dart';
import '../../widget/statistic_daily_widget.dart';
import '../../widget/statistic_weekly_widget.dart';
import '../alarm/sleepwell_cycle_screen.dart';

class BeneficiaryStatisticsScreen extends StatefulWidget {
  const BeneficiaryStatisticsScreen({super.key});

  @override
  State<BeneficiaryStatisticsScreen> createState() =>
      _BeneficiaryStatisticsScreenState();
}

class _BeneficiaryStatisticsScreenState
    extends State<BeneficiaryStatisticsScreen> {
  // String beneficiaryId = 'fcvnYcImdzmPJSZFASF9';
  int _selectedIndex = 0;
  String weekRange = '';

  void getWeekRange() {
    final now = DateTime.now();
    final weekEnd = now.subtract(const Duration(days: 1));
    final weekStart = now.subtract(const Duration(days: 7));

    weekRange =
        '${DateFormat('d MMM').format(weekStart)} - ${DateFormat('d MMM').format(weekEnd)}';
  }

  final BeneficiaryController controller = Get.find();
  late RxString beneficiaryId = ''.obs;

  String? userId = FirebaseAuth.instance.currentUser?.uid;
  String? beneficiaryName;
  Future<void> getBeneficiariesName() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('beneficiaries')
        .doc(beneficiaryId.toString())
        .get();

    if (docSnapshot.exists) {
      setState(() {
        beneficiaryName = docSnapshot['name'] ?? 'No Name';
      });
      print('-------------beneficiaryName-----------');
      print(beneficiaryName);
      print('-------------beneficiaryName-----------');
    }
  }

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
    }

    getBeneficiariesName();
    getWeekRange();
  }

  @override
  Widget build(BuildContext context) {
    AlarmsStatisticsController alarmsController =
        Get.put(AlarmsStatisticsController());
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF004AAD),
          title: Text(
            "$beneficiaryName Statistics And Profile",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'add_alarm') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SleepWellCycleScreen(),
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'add_alarm',
                  child: Row(
                    children: [
                      Icon(Icons.add_alarm, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Add New Alarm'),
                    ],
                  ),
                ),
              ],
            ),
          ],
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
                future: alarmsController
                    .fetchBeneficiaryAlarms(selectedBeneficiaryId!),
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
                    // في حال وجود بيانات
                    final alarms = snapshot.data!;
                    final latestAlarm = alarms.first;

                    // استرجاع القيم من البيانات
                    String? wakeupTime = latestAlarm.wakeupTime;
                    String? bedtime = latestAlarm.bedtime;

                    // التعامل مع numOfCycles
                    int numOfCycles;
                    if (latestAlarm.numOfCycles is int) {
                      numOfCycles = latestAlarm.numOfCycles;
                    } else if (latestAlarm.numOfCycles is String) {
                      numOfCycles = latestAlarm.numOfCycles;
                    } else {
                      numOfCycles = 0;
                    }

                    // تحويل الأوقات من String إلى DateTime
                    DateTime bedtimeDate =
                        DateFormat("hh:mm a").parse(bedtime!);
                    DateTime wakeupTimeDate =
                        DateFormat("hh:mm a").parse(wakeupTime!);

                    // حساب مدة النوم
                    // Duration sleepDuration =
                    //     wakeupTimeDate.difference(bedtimeDate);
                    // String sleepHoursDuration =
                    //     "${sleepDuration.inHours} h ${sleepDuration.inMinutes.remainder(60)}m";

                    Map<String, dynamic> sleepDuration = alarmsController
                        .calculateSleepDuration(bedtimeDate, wakeupTimeDate);

                    String sleepHoursDuration = sleepDuration['formatted'];

                    String timestamp = DateFormat('yyyy-MM-dd: hh:mm a')
                        .format(latestAlarm.timestamp)
                        .toString();
                    timestamp = 'Statistic Daily for Times:\n $timestamp';

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
                future: alarmsController
                    .fetchBeneficiaryLastWeekAlarms(selectedBeneficiaryId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    final alarms = snapshot.data ?? [];

                    // إنشاء القوائم للأيام السبعة
                    List<double> sleepHours = List.filled(7, 0.0);
                    List<double> sleepCycles = List.filled(7, 0.0);

                    // معالجة البيانات لتحديد القيم لكل يوم
                    for (var alarm in alarms) {
                      final alarmDate = alarm.timestamp;
                      final differenceInDays =
                          DateTime.now().difference(alarmDate).inDays;

                      if (differenceInDays >= 0 && differenceInDays < 7) {
                        int index = 6 - differenceInDays; // اليوم الصحيح
                        sleepHours[index] =
                            alarm.sleepDuration.inHours.toDouble();
                        sleepCycles[index] = alarm.sleepCycles.toDouble();
                      }
                    }

                    // قائمة الألوان
                    final weekColors = [
                      const Color(0xFF26C6DA), // Sun
                      const Color(0xFFDF1EE9), // Mon
                      const Color(0xFF81C784), // Tue
                      const Color(0xFF53C3E9), // Wed
                      const Color(0xFF2196F3), // Thu
                      const Color(0xFF0AE393), // Fri
                      const Color(0xFF53C3E9), // Sat
                    ];

                    // إنشاء BarChartGroupData
                    final barGroups = List.generate(7, (index) {
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: sleepHours[index],
                            color: weekColors[index],
                            width: 16,
                          ),
                        ],
                      );
                    });

                    // إنشاء PieChartSectionData
                    final pieSections = List.generate(7, (index) {
                      return PieChartSectionData(
                        value: sleepCycles[index],
                        color: weekColors[index],
                        title: '${sleepCycles[index].toStringAsFixed(1)}',
                        radius: 60,
                      );
                    });

                    // حساب متوسط ساعات النوم
                    final double averageSleepHours =
                        sleepHours.reduce((a, b) => a + b) / sleepHours.length;

                    // عرض الواجهة
                    return StatisticsWeeklyWidget(
                      barGroups: barGroups,
                      pieSections: pieSections,
                      chartMaxYweek: 20,
                      averageSleepHours: averageSleepHours,
                      weekRange: weekRange,
                    );
                  }
                },
              ),
            ),
            SingleChildScrollView(
              child: FutureBuilder<List<AlarmModelData>>(
                future: alarmsController
                    .fetchBeneficiaryCurrentMonthAlarms(selectedBeneficiaryId!),
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
                      try {
                        String bedtimeString = alarm.bedtime ?? '';
                        String wakeupTimeString = alarm.wakeupTime ?? '';
                        int cyclesString = alarm.numOfCycles;

                        // تأكد من أن الحقلين bedtime و wakeupTime ليسا فارغين
                        if (bedtimeString.isNotEmpty &&
                            wakeupTimeString.isNotEmpty) {
                          // Parse times with AM/PM format
                          DateTime bedtime =
                              DateFormat('hh:mm a').parse(bedtimeString);
                          DateTime wakeupTime =
                              DateFormat('hh:mm a').parse(wakeupTimeString);

                          if (wakeupTime.isBefore(bedtime)) {
                            wakeupTime =
                                wakeupTime.add(const Duration(days: 1));
                          }

                          double sleepDuration =
                              wakeupTime.difference(bedtime).inHours.toDouble();
                          int cycles = cyclesString;

                          sleepHoursMonth.add(sleepDuration);
                          sleepCyclesMonth.add(cycles.toDouble());

                          // Calculate weekly data
                          int weekIndex =
                              ((alarm.timestamp.day - 1) / 7).floor();
                          if (weekIndex < 4) {
                            weeklySleepCycles[weekIndex] += cycles.toDouble();
                            weeklySleepHours[weekIndex].add(sleepDuration);
                          }
                        }
                      } catch (e) {
                        print("Error parsing time or date: $e");
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
