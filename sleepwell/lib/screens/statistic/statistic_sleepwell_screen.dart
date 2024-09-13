import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleepwell/widget/info_card.dart';
import '../../widget/custom_bottom_bar.dart';
import '../../widget/indicator.dart';
import 'my_chart_model.dart';

class StatisticSleepWellScreen extends StatefulWidget {
  const StatisticSleepWellScreen({
    super.key,
  });

  @override
  _StatisticSleepWellScreenState createState() =>
      _StatisticSleepWellScreenState();
}

class _StatisticSleepWellScreenState extends State<StatisticSleepWellScreen> {
  List<BarChartGroupData> barGroupsMontt = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<PieChartSectionData> pieSectionsMonth = [];
  List<double> sleepHoursMonth = [];
  List<double> sleepCyclesMonth = [];
  String monthName = '';
  double averageSleepHoursMonth = 0.0;

  // Week var
  List<BarChartGroupData> barGroups = [];
  List<PieChartSectionData> pieSections = [];
  List<double> sleepHours = [];
  List<double> sleepCycles = [];
  String weekRange = '';
  double averageSleepHours = 0.0;
  List<Color> weekColors = [
    const Color(0xFF26C6DA), // Sun
    const Color.fromRGBO(223, 30, 233, 1), // Mon
    const Color(0xFF81C784), // Tue
    const Color(0xFF53C3E9), // Wed
    Colors.blue, // Thu
    const Color.fromARGB(255, 10, 227, 147), // Fri
    const Color(0xFF53C3E9), // Sat
  ];
  List<Color> montColors = [
    const Color(0xFF26C6DA), // WK 1
    const Color.fromRGBO(223, 30, 233, 1), // WK 2

    const Color.fromARGB(255, 10, 227, 147), // Wk 3
    const Color(0xFFB3FD12), // WK 4
  ];
  final AlarmModel _model = AlarmModel();

// end week
// day
  String sleepHoursDurationLastDay = '0:0 h';
  String sleepTimeActualLastDay = '0:0 h';
  String sleepCyclesLastDay = '0 C';
  String wakeUpTimeLastDay = '0:0 h';

  List<FlSpot> sleepCycleDataLastDay = [];
// END Var DAY
  String? userid;
  @override
  void initState() {
    super.initState();
    loadDataForMonth();
    loadDataWeek();
    loadDayData();
    getUserId();
  }

  Future<void> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userid = prefs.getString('userid'); // استرجاع الـ userid
    });
  }

// Day
  Future<void> loadDayData() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await FirebaseFirestore.instance
          .collection('alarms')
          .where('uid', isEqualTo: userid)
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
          wakeupTime = wakeupTime.add(Duration(days: 1));
        }

        double sleepDuration =
            wakeupTime.difference(bedtime).inHours.toDouble();
        double actualSleepTime =
            wakeupTime.difference(bedtime).inMinutes / 60.0;
        num cycles = int.tryParse(cyclesString) ?? 0;

        // تحديث القيم لواجهة المستخدم
        setState(() {
          sleepHoursDurationLastDay = '${sleepDuration.toStringAsFixed(1)}h';
          sleepTimeActualLastDay = '${actualSleepTime.toStringAsFixed(1)}h';
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

// End
  // Future<void> loadDataWeek() async {
  //   // final now = DateTime.now();
  //   // final weekStart = now.subtract(Duration(days: now.weekday));
  //   // final weekEnd = now.subtract(const Duration(days: 0));
  //   final now = DateTime.now();
  //   final weekEnd = now.subtract(
  //       const Duration(days: 1)); // Today is the end of the 7-day period
  //   final weekStart = now.subtract(
  //       const Duration(days: 7)); // 6 days ago is the start of the 7-day period

  //   // Format the week range for display
  //   weekRange =
  //       '${DateFormat('d MMM').format(weekStart)} - ${DateFormat('d MMM').format(weekEnd)}';

  //   final data = await _model.fetchAlarmData(weekStart, weekEnd);

  //   setState(() {
  //     sleepHours = data['sleepHours'] ?? [];
  //     sleepCycles = data['sleepCycles'] ?? [];
  //     averageSleepHours = data['averageSleepHours'] ?? 0.0;

  //     barGroups = List.generate(
  //       sleepHours.length,
  //       (index) => BarChartGroupData(
  //         x: index,
  //         barRods: [
  //           BarChartRodData(
  //             toY: sleepHours[index],
  //             color: Colors.blue,
  //             width: 16,
  //           ),
  //         ],
  //       ),
  //     );

  //     pieSections = List.generate(
  //       sleepCycles.length,
  //       (index) => PieChartSectionData(
  //         value: sleepCycles[index],
  //         color: weekColors[index % weekColors.length],
  //         title: '${sleepCycles[index]}',
  //         radius: 60,
  //       ),
  //     );
  //   });
  // }
  Future<void> loadDataWeek() async {
    final now = DateTime.now();
    final weekEnd = now.subtract(
        const Duration(days: 1)); // Today is the end of the 7-day period
    final weekStart = now.subtract(
        const Duration(days: 7)); // 6 days ago is the start of the 7-day period

    // Format the week range for display
    weekRange =
        '${DateFormat('d MMM').format(weekStart)} - ${DateFormat('d MMM').format(weekEnd)}';

    final data = await _model.fetchAlarmData(weekStart, weekEnd);

    setState(() {
      sleepHours = data['sleepHours'] ?? [];
      sleepCycles = data['sleepCycles'] ?? [];
      averageSleepHours = data['averageSleepHours'] ?? 0.0;

      // barGroups = List.generate(
      //   sleepHours.length,
      //   (index) => BarChartGroupData(
      //     x: index,
      //     barRods: [
      //       BarChartRodData(
      //         toY: sleepHours[index],
      //         color: Colors.blue,
      //         width: 16,
      //       ),
      //     ],
      //   ),
      // );

      // pieSections = List.generate(
      //   sleepCycles.length,
      //   (index) => PieChartSectionData(
      //     value: sleepCycles[index],
      //     color: weekColors[
      //         index % weekColors.length], // Cycle colors if list is shorter
      //     title: '${sleepCycles[index]}',
      //     radius: 60,
      //   ),
      // );
      barGroups = List.generate(7, (index) {
        double value = (index < sleepHours.length) ? sleepHours[index] : 0.0;
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: value,
              color: Colors.blue,
              width: 16,
            ),
          ],
        );
      });

      pieSections = List.generate(7, (index) {
        double value = (index < sleepCycles.length) ? sleepCycles[index] : 0.0;
        return PieChartSectionData(
          value: value,
          color: weekColors[index % weekColors.length],
          title: '$value',
          radius: 60,
        );
      });
    });
  }

  List<String> getFormattedDatesForWeek() {
    final now = DateTime.now();
    // final weekStart = now.subtract(Duration(days: now.weekday));
    final weekStart = now.subtract(Duration(days: 7));
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

  // Future<void> loadDataForMonth() async {
  //   final now = DateTime.now(); // Get the current date
  //   final firstDayOfMonth =
  //       DateTime(now.year, now.month, 1); // Start of the month
  //   final lastDayOfMonth =
  //       DateTime(now.year, now.month + 1, 0); // End of the month
  //   // final firstDayOfMonth =
  //   //     DateTime(now.year, now.month - 1, 1); // Start of the month
  //   // final lastDayOfMonth = DateTime(now.year, now.month, 0); // End of the month
  //   monthName = DateFormat('MMMM yyyy').format(firstDayOfMonth);

  //   final snapshot = await _firestore
  //       .collection('alarms')
  //       .where('timestamp', isGreaterThanOrEqualTo: firstDayOfMonth)
  //       .where('timestamp', isLessThanOrEqualTo: lastDayOfMonth)
  //       .get();

  //   List<double> weeklySleepCycles = [
  //     0,
  //     0,
  //     0,
  //     0
  //   ]; // Sum of sleep cycles for each week

  //   for (var alarm in snapshot.docs) {
  //     String bedtimeString = alarm['bedtime'];
  //     String wakeupTimeString = alarm['wakeup_time'];
  //     String cyclesString = alarm['num_of_cycles'];

  //     // Parse times with AM/PM format
  //     DateTime bedtime = DateFormat('hh:mm a').parse(bedtimeString);
  //     DateTime wakeupTime = DateFormat('hh:mm a').parse(wakeupTimeString);

  //     if (wakeupTime.isBefore(bedtime)) {
  //       wakeupTime = wakeupTime.add(Duration(days: 1));
  //     }

  //     double sleepDuration = wakeupTime.difference(bedtime).inHours.toDouble();
  //     int cycles = int.tryParse(cyclesString) ?? 0;

  //     sleepHoursMonth.add(sleepDuration);
  //     sleepCyclesMonth.add(cycles.toDouble());

  //     // Calculate weekly data
  //     int weekIndex = ((alarm['timestamp'].toDate().day - 1) / 7).floor();
  //     if (weekIndex < 4) {
  //       weeklySleepCycles[weekIndex] += cycles.toDouble();
  //     }
  //   }

  //   double totalSleepHours = sleepHoursMonth.fold(0.0, (a, b) => a + b);
  //   averageSleepHoursMonth = sleepHoursMonth.isNotEmpty
  //       ? totalSleepHours / sleepHoursMonth.length
  //       : 0.0;

  //   setState(() {
  //     barGroupsMontt = List.generate(
  //       weeklySleepCycles
  //           .length, // Generate only for the length of weeklySleepCycles
  //       (index) => BarChartGroupData(
  //         x: index,
  //         barRods: [
  //           BarChartRodData(
  //             toY: weeklySleepCycles[index],
  //             color: Colors.blue,
  //             width: 16,
  //           ),
  //         ],
  //       ),
  //     );

  //     pieSectionsMonth = List.generate(
  //       4,
  //       (index) => PieChartSectionData(
  //         value: weeklySleepCycles[index], // Total sleep cycles for the week
  //         color: montColors[index],
  //         title: 'Wk ${index + 1}:${weeklySleepCycles[index]}C',
  //         radius: 60,
  //       ),
  //     );
  //   });
  // }

  Future<void> loadDataForMonth() async {
    final now = DateTime.now(); // Get the current date
    final firstDayOfMonth =
        DateTime(now.year, now.month, 1); // Start of the month
    final lastDayOfMonth =
        DateTime(now.year, now.month + 1, 0); // End of the month

    monthName = DateFormat('MMMM yyyy').format(firstDayOfMonth);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }
      CollectionReference alarmsref =
          FirebaseFirestore.instance.collection('alarms');
      // .where('timestamp', isGreaterThanOrEqualTo: firstDayOfMonth)
      //         .where('timestamp', isLessThanOrEqualTo: lastDayOfMonth);
      //         .get();
      // alarmsref
      //     .snapshots()
      //     .where('timestamp', isGreaterThanOrEqualTo: firstDayOfMonth)
      //     .where('timestamp', isLessThanOrEqualTo: lastDayOfMonth)
      //     .get();
      final snapshot = await _firestore
          .collection('alarms')
          .where('uid', isEqualTo: userid)
          .where('timestamp', isGreaterThanOrEqualTo: firstDayOfMonth)
          .where('timestamp', isLessThanOrEqualTo: lastDayOfMonth)
          .get();

      List<double> weeklySleepCycles = [
        0,
        0,
        0,
        0
      ]; // Sum of sleep cycles for each week

      for (var alarm in snapshot.docs) {
        String bedtimeString = alarm['bedtime'];
        String wakeupTimeString = alarm['wakeup_time'];
        String cyclesString = alarm['num_of_cycles'];

        // Parse times with AM/PM format
        DateTime bedtime = DateFormat('hh:mm a').parse(bedtimeString);
        DateTime wakeupTime = DateFormat('hh:mm a').parse(wakeupTimeString);

        if (wakeupTime.isBefore(bedtime)) {
          wakeupTime = wakeupTime.add(Duration(days: 1));
        }

        double sleepDuration =
            wakeupTime.difference(bedtime).inHours.toDouble();
        int cycles = int.tryParse(cyclesString) ?? 0;

        sleepHoursMonth.add(sleepDuration);
        sleepCyclesMonth.add(cycles.toDouble());

        // Calculate weekly data
        int weekIndex = ((alarm['timestamp'].toDate().day - 1) / 7).floor();
        if (weekIndex < 4) {
          weeklySleepCycles[weekIndex] += cycles.toDouble();
        }
      }

      double totalSleepHours = sleepHoursMonth.fold(0.0, (a, b) => a + b);
      double averageSleepHoursMonth = sleepHoursMonth.isNotEmpty
          ? totalSleepHours / sleepHoursMonth.length
          : 0.0;

      setState(() {
        barGroupsMontt = List.generate(
          weeklySleepCycles
              .length, // Generate only for the length of weeklySleepCycles
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: weeklySleepCycles[index],
                color: Colors.blue,
                width: 16,
              ),
            ],
          ),
        );

        pieSectionsMonth = List.generate(
          4,
          (index) => PieChartSectionData(
            value: weeklySleepCycles[index], // Total sleep cycles for the week
            color: montColors[index],
            title: 'Wk ${index + 1}:${weeklySleepCycles[index]}C',
            radius: 60,
          ),
        );
      });
    } catch (e) {
      print('Error occurred: $e');
      // Handle the error appropriately
    }
  }

  int _selectedIndex = 0;

  Widget build(BuildContext context) {
    // week
    final List<String> formattedDates = getFormattedDatesForWeek();
    // end week
    // Moth info
    final now = DateTime.now(); // Make sure 'now' is declared
    final lastDayOfMonth = DateTime(
        now.year, now.month + 1, 0); // Make sure 'lastDayOfMonth' is declared

    List<String> ranges = [
      '01/${now.month.toString().padLeft(2, '0')} - 07/${now.month.toString().padLeft(2, '0')}',
      '08/${now.month.toString().padLeft(2, '0')} - 14/${now.month.toString().padLeft(2, '0')}',
      '15/${now.month.toString().padLeft(2, '0')} - 21/${now.month.toString().padLeft(2, '0')}',
      '22/${now.month.toString().padLeft(2, '0')} - ${lastDayOfMonth.day}/${now.month.toString().padLeft(2, '0')}',
    ];
    double maxSleepHours = sleepHoursMonth.isNotEmpty
        ? sleepHoursMonth.reduce((a, b) => a > b ? a : b)
        : 10.0;

// Set the maxY to a value slightly higher than the maximum sleep hours
    double chartMaxY = maxSleepHours + 9; // Adjust +2 as needed for padding

    double maxweekSleepHours = sleepHours.isNotEmpty
        ? sleepHours.reduce((a, b) => a > b ? a : b)
        : 10.0;
    double chartMaxYweek =
        maxweekSleepHours + 2; // Adjust +2 as needed for padding
    // End Month info

    // final List<SleepData> sleepDataList;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF004AAD),
          bottom: PreferredSize(
            preferredSize:
                const Size.fromHeight(60.0), // adjust the height as needed
            child: Column(
              children: [
                const Column(
                  children: [
                    Text(
                      'Statistics',
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
        // bottomNavigationBar: CustomBottomBar(),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            // Day view
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
                          title: 'Sleep hours',
                          value: sleepHoursDurationLastDay,
                        ),
                      ),
                      SizedBox(width: 16),
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
                          title: "Sleep cycles",
                          value: sleepCyclesLastDay,
                        ),
                      ),
                      SizedBox(width: 16),
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
                                    color: Color.fromRGBO(13, 238, 219, 1),
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
                  // const SizedBox(height: 10),
                  Text(weekRange,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.white)),
                  // const SizedBox(height: 10),
                  Text(
                      'Sleep average: ${averageSleepHours.toStringAsFixed(1)}h',
                      style:
                          const TextStyle(fontSize: 16, color: Colors.white)),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: chartMaxYweek,
                        backgroundColor: const Color.fromRGBO(187, 222, 251, 1),
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  // child: Text(
                                  //   formattedDates[value.toInt()],
                                  //   style: const TextStyle(
                                  //     fontWeight: FontWeight.bold,
                                  //     color: Colors.white,
                                  //     backgroundColor:
                                  //         Color.fromARGB(0, 49, 202, 192),
                                  //     fontSize: 14,
                                  //   ),
                                  // ),
                                  child: Text(
                                    value.toInt() < formattedDates.length
                                        ? formattedDates[value.toInt()]
                                        : 'Invalid Date', // Fallback for out-of-range values
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      backgroundColor:
                                          Color.fromARGB(0, 49, 202, 192),
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 2,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Text(
                                  '     ${value.toInt()}h',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.white),
                                );
                              },
                              reservedSize: 34,
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: const FlGridData(show: true),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                              color: Colors.black,
                              width: 1,
                              strokeAlign: BorderSide.strokeAlignInside),
                        ),
                        barGroups: barGroups,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    // flex: 1,
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFFBBDEFB),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 250,
                                  height: 150,
                                  child: PieChart(
                                    PieChartData(
                                      sections: pieSections,
                                      centerSpaceRadius: 23,
                                      sectionsSpace: 2,
                                      borderData: FlBorderData(show: false),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(
                                7,
                                (index) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 3, vertical: 1),
                                  child: Indicator(
                                    color: weekColors[index],
                                    text: [
                                      'Sun',
                                      'Mon',
                                      'Tue',
                                      'Wed',
                                      'Thu',
                                      'Fri',
                                      'Sat'
                                    ][index],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // // Month view
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
                  // const SizedBox(height: 20),
                  Text(monthName,
                      style:
                          const TextStyle(fontSize: 18, color: Colors.white)),
                  // const SizedBox(height: 10),
                  Text(
                      'Sleep average: ${averageSleepHoursMonth.toStringAsFixed(1)}h',
                      style:
                          const TextStyle(fontSize: 16, color: Colors.white)),
                  const SizedBox(height: 5),
                  Expanded(
                    flex: 2,
                    child:
                        // Calculate the maximum sleep hours in the data
                        BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: chartMaxY, // Use the adjusted maxY
                        backgroundColor: Color(0xFFBBDEFB),
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                int startDay = (value.toInt() * 7) + 1;
                                int endDay = startDay + 6;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    '$startDay/$endDay',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 2,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Text(
                                  '${value.toInt()}h',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.white),
                                );
                              },
                              reservedSize: 40,
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: const FlGridData(show: true),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        barGroups: barGroupsMontt,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFFBBDEFB),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 250,
                                  height: 150,
                                  child: PieChart(
                                    PieChartData(
                                      sections: pieSectionsMonth,
                                      centerSpaceRadius: 20,
                                      sectionsSpace: 2,
                                      borderData: FlBorderData(show: false),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(
                                4,
                                (index) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 3),
                                  child: Indicator(
                                    color: montColors[index],
                                    text: 'Avg Week ${index + 1}',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
