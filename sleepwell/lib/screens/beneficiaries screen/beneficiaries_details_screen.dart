import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/alarms_controller.dart';
import '../../models/alarm_model.dart';
import '../../widget/indicator.dart';
import '../../widget/info_card.dart';
import '../alarm/alarm_setup_screen.dart';

class BeneficiaryDetailsScreen extends StatefulWidget {
  final String beneficiaryId;

  const BeneficiaryDetailsScreen({Key? key, required this.beneficiaryId})
      : super(key: key);

  @override
  State<BeneficiaryDetailsScreen> createState() =>
      _BeneficiaryDetailsScreenState();
}

class _BeneficiaryDetailsScreenState extends State<BeneficiaryDetailsScreen> {
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  String beneficiaryName = 'Loading...';
  Map<String, dynamic>? sleepData; // لحفظ البيانات التي تم جلبها
  bool isLoading = true;
  Future<void> loadBeneficiaryDetails() async {
    try {
      // جلب بيانات المستفيد
      final docSnapshot = await FirebaseFirestore.instance
          .collection('beneficiaries')
          .doc(widget.beneficiaryId)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          beneficiaryName = docSnapshot['name'] ?? 'No Name';
        });
        final now = DateTime.now();
        final startOfDay = DateTime(now.year, now.month, now.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        // جلب بيانات النوم المرتبطة بالمستفيد
        final sleepSnapshot = await FirebaseFirestore.instance
            .collection('alarms')
            .where('beneficiaryId', isEqualTo: widget.beneficiaryId)
            .where('isForBeneficiary', isEqualTo: false)
            .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
            .where('timestamp', isLessThan: endOfDay)
            .get();

        if (sleepSnapshot.docs.isNotEmpty) {
          setState(() {
            sleepData = sleepSnapshot.docs.first.data();

            // طباعة جميع البيانات في console
            print('Sleep Data: $sleepData');

            // تحقق من النوع الصحيح لـ num_of_cycles
            int numOfCycles = sleepData!['num_of_cycles'] is int
                ? sleepData!['num_of_cycles']
                : int.tryParse(sleepData!['num_of_cycles'].toString()) ?? 0;

            // حساب عدد ساعات النوم
            String bedtime = sleepData!['bedtime'];
            String wakeupTime = sleepData!['wakeup_time'];
            double sleepHoursDuration =
                calculateSleepHours(bedtime, wakeupTime);
            print('Num of Sleep Hours (calculated): $sleepHoursDuration hours');

            // حساب الوقت الفعلي للنوم
            double actualSleepTime =
                calculateActualSleepTime(sleepHoursDuration, numOfCycles);
            print('Actual Sleep Time (calculated): $actualSleepTime hours');

            // تخزين القيم المحسوبة في sleepData
            sleepData!['sleepHoursDuration'] = sleepHoursDuration;
            sleepData!['actualSleepTime'] = actualSleepTime;

            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          beneficiaryName = 'No beneficiary found';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching beneficiary details: $e');
      setState(() {
        beneficiaryName = 'Error loading name';
        isLoading = false;
      });
    }
  }

  // دالة لحساب عدد ساعات النوم
  double calculateSleepHours(String bedtime, String wakeupTime) {
    DateTime bedTime = DateFormat('HH:mm').parse(bedtime);
    DateTime wakeTime = DateFormat('HH:mm').parse(wakeupTime);
    Duration sleepDuration = wakeTime.difference(bedTime);

    // إذا كانت النتيجة بالسالب، نضيف 24 ساعة
    if (sleepDuration.isNegative) {
      sleepDuration = sleepDuration + const Duration(hours: 24);
    }
    return sleepDuration.inMinutes / 60.0;
  }

  // دالة لحساب الوقت الفعلي للنوم بناءً على عدد الدورات المكتملة
  double calculateActualSleepTime(double sleepHours, int numOfCycles) {
    // نفترض أن كل دورة نوم تستغرق 90 دقيقة (1.5 ساعة)
    const double cycleDuration = 1.5;
    double actualSleepTime = cycleDuration * numOfCycles;

    // إذا كانت ساعات النوم الفعلية أقل من المدة المتوقعة للدورات، نعود للمدة الفعلية للنوم
    if (actualSleepTime > sleepHours) {
      actualSleepTime = sleepHours;
    }

    // نطرح بعض الدقائق (مثل 10 دقائق) إذا استيقظ المستخدم قبل إتمام الدورة
    if (actualSleepTime < sleepHours) {
      actualSleepTime = actualSleepTime - 0.15; // نطرح 10 دقائق
    }

    return actualSleepTime;
  }

  String? beneficiaryId;
  // final AlarmsController alarmsController = Get.find();
  @override
  void initState() {
    super.initState();
    beneficiaryId = widget.beneficiaryId;
    loadBeneficiaryDetails();
    // loadDataWeek();
    // alarmsController.fetchBeneficiaryLastWeekAlarms(beneficiaryId!);
  }

  // final AlarmModel _model = AlarmModel();

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

  // Future<void> loadDataWeek() async {
  //   final now = DateTime.now();
  //   final weekEnd = now.subtract(
  //       const Duration(days: 1)); // Today is the end of the 7-day period
  //   final weekStart = now.subtract(
  //       const Duration(days: 7)); // 6 days ago is the start of the 7-day period

  //   // Format the week range for display
  //   weekRange =
  //       '${DateFormat('d MMM').format(weekStart)} - ${DateFormat('d MMM').format(weekEnd)}';

  //   final data = await _model.fetchAlarmDataBeneficiary(weekStart, weekEnd);

  //   setState(() {
  //     sleepHours = data['sleepHours'] ?? [];
  //     sleepCycles = data['sleepCycles'] ?? [];
  //     averageSleepHours = data['averageSleepHours'] ?? 0.0;

  //     barGroups = List.generate(7, (index) {
  //       double value = (index < sleepHours.length) ? sleepHours[index] : 0.0;
  //       return BarChartGroupData(
  //         x: index,
  //         barRods: [
  //           BarChartRodData(
  //             toY: value,
  //             color: Colors.blue,
  //             width: 16,
  //           ),
  //         ],
  //       );
  //     });

  //     pieSections = List.generate(7, (index) {
  //       double value = (index < sleepCycles.length) ? sleepCycles[index] : 0.0;
  //       return PieChartSectionData(
  //         value: value,
  //         color: weekColors[index % weekColors.length],
  //         title: '$value',
  //         radius: 60,
  //       );
  //     });
  //   });
  // }

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

  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    double maxweekSleepHours = sleepHours.isNotEmpty
        ? sleepHours.reduce((a, b) => a > b ? a : b)
        : 10.0;
    double chartMaxYweek = maxweekSleepHours + 2;
    final List<String> formattedDates = getFormattedDatesForWeek();
    return

        //  DefaultTabController(
        //   length: 3,
        //   child:

        Scaffold(
      appBar: AppBar(
        title: Text(
          '$beneficiaryName Profile',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF004AAD),
        iconTheme: const IconThemeData(color: Colors.white),
        // bottom: PreferredSize(
        //   preferredSize:
        //       const Size.fromHeight(60.0), // adjust the height as needed
        //   child: Column(
        //     children: [
        //       // const Column(
        //       //   children: [
        //       //     Text(
        //       //       'Statistics',
        //       //       style: TextStyle(
        //       //         color: Colors.white,
        //       //         fontSize: 30,
        //       //         fontWeight: FontWeight.bold,
        //       //       ),
        //       //     ),
        //       //   ],
        //       // ),
        //       TabBar(
        //         onTap: (index) {
        //           setState(() {
        //             _selectedIndex = index;
        //           });
        //         },
        //         indicatorColor: Colors.white,
        //         labelColor: Colors.white,
        //         unselectedLabelColor: Colors.grey,
        //         tabs: const [
        //           Tab(text: 'Day'),
        //           Tab(text: 'Week'),
        //           Tab(text: 'Month'),
        //         ],
        //       ),
        //     ],
        //   ),
        // ),
      ),
      body:
          // IndexedStack(
          //   index: _selectedIndex,
          //   children: [
          Container(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : sleepData != null
                ? SingleChildScrollView(
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF004AAD), Color(0xFF040E3B)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: InfoCard(
                                  title: 'Num of Sleep Hours:',
                                  value:
                                      '${sleepData!['sleepHoursDuration']} h',
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: InfoCard(
                                  title: 'Actual Sleep Time:',
                                  value: '${sleepData!['actualSleepTime']} PM',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Expanded(
                                child: InfoCard(
                                  title: "Num Of Sleep Cycles:",
                                  value:
                                      '${sleepData!['num_of_cycles']} Cycles',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: InfoCard(
                                  title: "Wake up Time:",
                                  value: '${sleepData!['wakeup_time']}',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Card(
                            color: const Color.fromARGB(255, 6, 96, 187),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Time spent in each stage of Light and Deep Sleep Cycles',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  buildSleepStageRow('REM', 22, '1h 44m',
                                      Colors.lightBlue[100]!),
                                  const SizedBox(height: 10),
                                  buildSleepStageRow(
                                      'Light', 56, '4h 30m', Colors.blue[300]!),
                                  const SizedBox(height: 10),
                                  buildSleepStageRow('Deep', 18, '1h 27m',
                                      const Color.fromARGB(224, 13, 20, 161)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Divider(color: Colors.white),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Set new alarm for your follower ',
                                style: TextStyle(color: Colors.white),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AlarmSetupScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  backgroundColor: const Color(0xFF21E6C1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text(
                                  'Set Alarm',
                                  style: TextStyle(fontSize: 18),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF004AAD), Color(0xFF040E3B)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Set new alarm for your follower ',
                            style: TextStyle(color: Colors.white),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AlarmSetupScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              backgroundColor: const Color(0xFF21E6C1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Set Alarm',
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
      ),

      // Container(
      //   height: MediaQuery.of(context).size.height,
      //   // padding: const EdgeInsets.all(30),
      //   decoration: const BoxDecoration(
      //     gradient: LinearGradient(
      //       colors: [Color(0xFF004AAD), Color(0xFF040E3B)],
      //       begin: Alignment.topCenter,
      //       end: Alignment.bottomCenter,
      //     ),
      //   ),
      //   child: Column(
      //     children: [
      //       // const SizedBox(height: 10),
      //       Text(weekRange,
      //           style:
      //               const TextStyle(fontSize: 16, color: Colors.white)),
      //       // const SizedBox(height: 10),
      //       Text(
      //           'Sleep average hours: ${averageSleepHours.toStringAsFixed(1)}h',
      //           style:
      //               const TextStyle(fontSize: 16, color: Colors.white)),
      //       // const SizedBox(width: 10),
      //       Expanded(
      //         flex: 2,
      //         child: BarChart(
      //           BarChartData(
      //             alignment: BarChartAlignment.spaceAround,
      //             maxY: chartMaxYweek,
      //             backgroundColor: const Color.fromRGBO(187, 222, 251, 1),
      //             barTouchData: BarTouchData(enabled: false),
      //             titlesData: FlTitlesData(
      //               show: true,
      //               bottomTitles: AxisTitles(
      //                 sideTitles: SideTitles(
      //                   showTitles: true,
      //                   getTitlesWidget: (double value, TitleMeta meta) {
      //                     return Padding(
      //                       padding: const EdgeInsets.only(top: 5.0),
      //                       // child: Text(
      //                       //   formattedDates[value.toInt()],
      //                       //   style: const TextStyle(
      //                       //     fontWeight: FontWeight.bold,
      //                       //     color: Colors.white,
      //                       //     backgroundColor:
      //                       //         Color.fromARGB(0, 49, 202, 192),
      //                       //     fontSize: 14,
      //                       //   ),
      //                       // ),
      //                       child: Text(
      //                         value.toInt() < formattedDates.length
      //                             ? formattedDates[value.toInt()]
      //                             : 'Invalid Date', // Fallback for out-of-range values
      //                         style: const TextStyle(
      //                           fontWeight: FontWeight.bold,
      //                           color: Colors.white,
      //                           backgroundColor:
      //                               Color.fromARGB(0, 49, 202, 192),
      //                           fontSize: 14,
      //                         ),
      //                       ),
      //                     );
      //                   },
      //                 ),
      //               ),
      //               leftTitles: AxisTitles(
      //                 sideTitles: SideTitles(
      //                   showTitles: true,
      //                   interval: 2,
      //                   getTitlesWidget: (double value, TitleMeta meta) {
      //                     return Text(
      //                       '     ${value.toInt()}h',
      //                       style: const TextStyle(
      //                           fontWeight: FontWeight.bold,
      //                           fontSize: 12,
      //                           color: Colors.white),
      //                     );
      //                   },
      //                   reservedSize: 34,
      //                 ),
      //               ),
      //               rightTitles: const AxisTitles(
      //                 sideTitles: SideTitles(
      //                   showTitles: false,
      //                 ),
      //               ),
      //               topTitles: const AxisTitles(
      //                 sideTitles: SideTitles(showTitles: false),
      //               ),
      //             ),
      //             gridData: const FlGridData(show: true),
      //             borderData: FlBorderData(
      //               show: true,
      //               border: Border.all(
      //                   color: Colors.black,
      //                   width: 1,
      //                   strokeAlign: BorderSide.strokeAlignInside),
      //             ),
      //             barGroups: barGroups,
      //           ),
      //         ),
      //       ),
      //       Expanded(
      //         child: Container(
      //           width: double.infinity,
      //           color: const Color(0xFFBBDEFB),
      //           child: Center(
      //             child: Column(
      //               children: [
      //                 const Padding(
      //                   padding: EdgeInsets.only(
      //                       bottom: 10), // مسافة بين العنوان والمخطط
      //                   child: Text(
      //                     'Number Of Sleep Cycle:', // النص الذي يمثل العنوان
      //                     style: TextStyle(
      //                       fontSize: 16,
      //                       fontWeight: FontWeight.bold,
      //                       color: Colors.black,
      //                     ),
      //                   ),
      //                 ),
      //                 const SizedBox(height: 10.0),
      //                 Row(
      //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                   children: [
      //                     Column(
      //                       // mainAxisAlignment: MainAxisAlignment.center,
      //                       children: [
      //                         SizedBox(
      //                           width: 200,
      //                           height: 80,
      //                           child: PieChart(
      //                             PieChartData(
      //                               sections: pieSections,
      //                               centerSpaceRadius: 8,
      //                               sectionsSpace: 2,
      //                               borderData: FlBorderData(show: false),
      //                             ),
      //                           ),
      //                         ),
      //                       ],
      //                     ),
      //                     Row(
      //                       mainAxisAlignment: MainAxisAlignment.center,
      //                       children: [
      //                         Column(
      //                           crossAxisAlignment:
      //                               CrossAxisAlignment.start,
      //                           children: List.generate(
      //                             4, // أول 4 عناصر (Sun, Mon, Tue, Wed)
      //                             (index) => Padding(
      //                               padding: const EdgeInsets.symmetric(
      //                                   horizontal: 3, vertical: 1),
      //                               child: Indicator(
      //                                 color: weekColors[index],
      //                                 text: [
      //                                   'Sun',
      //                                   'Mon',
      //                                   'Tue',
      //                                   'Wed'
      //                                 ][index],
      //                               ),
      //                             ),
      //                           ),
      //                         ),
      //                         const SizedBox(
      //                             width: 20), // مسافة بين العمودين
      //                         Column(
      //                           crossAxisAlignment:
      //                               CrossAxisAlignment.start,
      //                           children: List.generate(
      //                             3, // العناصر الثلاثة الباقية (Thu, Fri, Sat)
      //                             (index) => Padding(
      //                               padding: const EdgeInsets.symmetric(
      //                                   horizontal: 3, vertical: 1),
      //                               child: Indicator(
      //                                 color: weekColors[
      //                                     index + 4], // نبدأ من Thu
      //                                 text: ['Thu', 'Fri', 'Sat'][index],
      //                               ),
      //                             ),
      //                           ),
      //                         ),
      //                       ],
      //                     )
      //                   ],
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),

      // // Container(),
      // // Container(),
      // Container(),
      //   ],
      // ),
    );
    // );
  }

  Widget buildSleepStageRow(
      String stage, int percentage, String duration, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          stage,
          style: const TextStyle(color: Colors.white),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: LinearProgressIndicator(
            value: percentage / 100.0,
            backgroundColor: Colors.grey[300],
            color: color,
            minHeight: 15,
          ),
        ),
        Text(
          duration,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
