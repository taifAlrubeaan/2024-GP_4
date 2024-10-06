import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../widget/info_card.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key});

  @override
  _StatisticScreenState createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  // day
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
    int selectedIndex = 0;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF004AAD),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60.0),
            child: Column(
              children: [
                const Column(
                  children: [
                    Text(
                      "Statistics",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TabBar(
                  onTap: (index) {
                    setState(() {
                      selectedIndex = index;
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
        // bottomNavigationBar: CustomBottomBar(),
        body: IndexedStack(
          index: selectedIndex,
          children: [
            // Container(
            //   height: MediaQuery.of(context).size.height,
            //   decoration: const BoxDecoration(
            //     gradient: LinearGradient(colors: [
            //       Color(0xFF004AAD),
            //       Color(0xFF040E3B),
            //     ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            //   ),
            // ),
            Container(
              height: MediaQuery.of(context).size.height,
              // padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF004AAD), Color(0xFF040E3B)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: InfoCard(
                          title: 'Num of Sleep Hours:',
                          value: sleepHoursDurationLastDay,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InfoCard(
                          title: ' Actual sleep time',
                          value: sleepTimeActualLastDay,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: InfoCard(
                          title: "Num of Sleep Cycles:",
                          value: sleepCyclesLastDay,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InfoCard(
                          title: "Wake up time",
                          value: wakeUpTimeLastDay,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF004AAD), Color(0xFF040E3B)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height / 3,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Light and Deep Sleep Cycles',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                              child: LineChart(
                            LineChartData(
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      switch (value.toInt()) {
                                        case 0:
                                          return const Text(
                                            'Awake',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          );
                                        case 1:
                                          return const Text('Light Sleep',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                              ));
                                        case 2:
                                          return const Text('Deep Sleep',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                              ));
                                        default:
                                          return const Text('');
                                      }
                                    },
                                    interval: 1,
                                    reservedSize: 100,
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      // عرض الساعات أسفل المحور الأفقي
                                      return Text(
                                        'h${value.toInt() + 1}',
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.white),
                                      );
                                    },
                                    interval: 1,
                                  ),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: true,
                                drawHorizontalLine: true,
                                horizontalInterval: 1,
                                verticalInterval: 1,
                                checkToShowHorizontalLine: (value) {
                                  return value == 0 || value == 1 || value == 2;
                                },
                                getDrawingHorizontalLine: (value) {
                                  return const FlLine(
                                    color: Colors.white,
                                    strokeWidth: 0.5,
                                  );
                                },
                                getDrawingVerticalLine: (value) {
                                  return const FlLine(
                                    color: Colors.white,
                                    strokeWidth: 0.5,
                                  );
                                },
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border.all(
                                    color:
                                        const Color.fromRGBO(13, 238, 219, 1),
                                    width: 1),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  isCurved:
                                      false, // لجعل الخطوط مستقيمة بين النقاط
                                  spots: [
                                    // النقاط التي تمثل دورات النوم (Light, Deep) مع التوقيت المناسب
                                    const FlSpot(
                                        0, 1), // مثال: بداية النوم الخفيف
                                    const FlSpot(
                                        1, 2), // مثال: التحول إلى النوم العميق
                                    const FlSpot(
                                        2, 1), // مثال: العودة إلى النوم الخفيف
                                    const FlSpot(
                                        3, 2), // مثال: العودة إلى النوم العميق
                                    const FlSpot(4, 0), // مثال: الاستيقاظ
                                  ],
                                  color: Colors.blue,
                                  barWidth: 3,
                                  belowBarData: BarAreaData(show: false),
                                ),
                              ],
                            ),
                          )),
                          // const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // // Week view
          ],
        ),
      ),
    );
  }
}
