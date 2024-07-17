import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sleepwell/widget/info_card.dart';
import '../widget/custom_bottom_bar.dart';
import '../widget/indicator.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({
    super.key,
  });

  @override
  _StatisticScreenState createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  int _selectedIndex = 0;

  List<BarChartGroupData> get barGroups => [
        BarChartGroupData(
            x: 0,
            barRods: [BarChartRodData(toY: 8, color: Colors.lightBlueAccent)]),
        BarChartGroupData(
            x: 1,
            barRods: [BarChartRodData(toY: 10, color: Colors.lightBlueAccent)]),
        BarChartGroupData(
            x: 2,
            barRods: [BarChartRodData(toY: 9, color: Colors.lightBlueAccent)]),
        BarChartGroupData(
            x: 3,
            barRods: [BarChartRodData(toY: 7, color: Colors.lightBlueAccent)]),
        BarChartGroupData(
            x: 4,
            barRods: [BarChartRodData(toY: 5, color: Colors.lightBlueAccent)]),
        BarChartGroupData(
            x: 5,
            barRods: [BarChartRodData(toY: 6, color: Colors.lightBlueAccent)]),
        BarChartGroupData(
            x: 6,
            barRods: [BarChartRodData(toY: 4, color: Colors.lightBlueAccent)]),
      ];
  List<PieChartSectionData> showingSections() {
    return [
      PieChartSectionData(
        color: Colors.blue,
        value: 20,
        title: '20%',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: 15,
        title: '15%',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.grey,
        value: 15,
        title: '15%',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.yellow,
        value: 10,
        title: '10%',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.green,
        value: 15,
        title: '15%',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.brown,
        value: 10,
        title: '10%',
        radius: 50,
      ),
      PieChartSectionData(
        color: const Color.fromRGBO(41, 232, 85, 1),
        value: 15,
        title: '15%',
        radius: 50,
      ),
    ];
  }

  List<PieChartSectionData> showingSectionsMonths() {
    return [
      PieChartSectionData(
        color: Colors.blue,
        value: 30,
        title: '30%',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: 40,
        title: '40%',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.grey,
        value: 20,
        title: '20%',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.yellow,
        value: 10,
        title: '10%',
        radius: 50,
      ),
    ];
  }

  // String firstName = '';
  // final _auth = FirebaseAuth.instance;
  // late User signInUser;
  // late String email;
  // late String lastName;
  // late String userId;
  // @override
  // void initState() {
  //   super.initState();
  //   _fetchUserData();
  // }
  // Future<void> _fetchUserName() async {
  //   try {
  //     DocumentSnapshot userDoc = await FirebaseFirestore.instance
  //         .collection('Users')
  //         .doc(widget.userId)
  //         .get();
  //     if (userDoc.exists) {
  //       final userData = userDoc.data() as Map<String, dynamic>?;
  //       if (userData != null) {
  //         setState(() {
  //           firstName = userData['Fname'] ?? '';
  //         });
  //       }
  //     }
  //   } catch (error) {
  //     print('Error fetching user data: $error');
  //   }
  // }
  // void getCurrentUser() {
  //   try {
  //     final user = _auth.currentUser;
  //     if (user != null) {
  //       setState(() {
  //         signInUser = user;
  //         userId = user.uid;
  //         email = user.email!;
  //       });
  //       _fetchUserData();
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }
  // void _fetchUserData() async {
  //   try {
  //     final userData = await FirebaseFirestore.instance
  //         .collection('Users')
  //         .doc(userId)
  //         .get();
  //     if (userData.exists) {
  //       setState(() {
  //         firstName = userData['Fname'] ?? '';
  //         lastName = userData['Lname'] ?? '';
  //       });
  //     } else {
  //       print('User data does not exist');
  //     }
  //   } catch (e) {
  //     print('Error fetching user data: $e');
  //   }
  // }

  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          // title: const Text('Hi firstNames!'),
          bottom: PreferredSize(
            preferredSize:
                const Size.fromHeight(80.0), // adjust the height as needed
            child: Column(
              children: [
                // FutureBuilder<DocumentSnapshot>(
                //   future: FirebaseFirestore.instance
                //       .collection('Users')
                //       .doc(userId)
                //       .get(),
                //   builder: (BuildContext context,
                //       AsyncSnapshot<DocumentSnapshot> snapshot) {
                //     if (snapshot.connectionState == ConnectionState.waiting) {
                //       // Show a loading indicator while fetching data
                //       return const CircularProgressIndicator();
                //     } else if (snapshot.hasError) {
                //       // Handle error state
                //       return Text('Error: ${snapshot.error}');
                //     } else {
                //       // Data has been fetched successfully
                //       final userData =
                //           snapshot.data?.data() as Map<String, dynamic>?;
                //       if (userData != null) {
                //         firstName = userData['Fname'] ?? '';
                //         lastName = userData['Lname'] ?? '';
                //       }
                //       return Column(
                //         children: [
                //           if (firstName != null)
                //             Text(
                //               'Hi $firstName!',
                //               style: const TextStyle(
                //                 color: Colors.white,
                //                 fontSize: 30,
                //                 fontWeight: FontWeight.bold,
                //               ),
                //             ),
                //           // ElevatedButton(
                //           //   onPressed: () {
                //           //     Get.to(UserProfilePage(
                //           //       userId: userId,
                //           //     ));
                //           //   },
                //           //   child: Text('hg'),
                //           // ),
                //         ],
                //       );
                //     }
                //   },
                // ),
                const Column(
                  children: [
                    Text(
                      'Statistics',
                      style: TextStyle(
                        color: Colors.black,
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
        bottomNavigationBar: CustomBottomBar(),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            // Day view
            Column(
              children: [
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Expanded(
                      child: InfoCard(
                        title: 'Sleep hours duration',
                        value: '8h',
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: InfoCard(
                        title: 'Sleep time (actual)',
                        value: '6h',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Expanded(
                      child: InfoCard(
                        title: "Sleep cycles",
                        value: "8h",
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: InfoCard(
                        title: "Wake up time",
                        value: "6h",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  color: Colors.white,
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
                          ),
                        ),
                        const SizedBox(height: 16),
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
                                          return const Text('Awake',
                                              style: TextStyle(fontSize: 14));
                                        case 1:
                                          return const Text('Light Sleep',
                                              style: TextStyle(fontSize: 14));
                                        case 2:
                                          return const Text('Deep Sleep',
                                              style: TextStyle(fontSize: 14));
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
                                      return Text('h${value.toInt() + 1}',
                                          style: const TextStyle(fontSize: 14));
                                    },
                                    interval: 1,
                                  ),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: false,
                                  ),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: false,
                                  ),
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
                                    color: Colors.grey,
                                    strokeWidth: 0.5,
                                  );
                                },
                                getDrawingVerticalLine: (value) {
                                  return const FlLine(
                                    color: Colors.grey,
                                    strokeWidth: 0.5,
                                  );
                                },
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border:
                                    Border.all(color: Colors.black, width: 1),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  isCurved: true,
                                  spots: [
                                    FlSpot(0, 0),
                                    FlSpot(1, 1),
                                    FlSpot(2, 0),
                                    FlSpot(3, 2),
                                    FlSpot(4, 0),
                                    FlSpot(5, 1),
                                  ],
                                  color: Colors.blue,
                                  barWidth: 3,
                                  belowBarData: BarAreaData(show: false),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Week view
            Column(
              children: [
                const SizedBox(height: 10),
                const Text('1 Jan - 1 Feb', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                const Text('Sleep average: 8h', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Expanded(
                  flex: 2,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 10,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              switch (value.toInt()) {
                                case 0:
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text('04/15',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                  );
                                case 1:
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text('04/16',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                  );
                                case 2:
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text('04/17',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                  );
                                case 3:
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text('04/18',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                  );
                                case 4:
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text('04/19',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                  );
                                case 5:
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text('04/20',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                  );
                                case 6:
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text('04/21',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                  );
                                default:
                                  return Container();
                              }
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 2,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              switch (value.toInt()) {
                                case 0:
                                  return const Text('0h',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12));
                                case 2:
                                  return const Text('2h',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12));
                                case 4:
                                  return const Text('4h',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12));
                                case 6:
                                  return const Text('6h',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12));
                                case 8:
                                  return const Text('8h',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12));
                                case 10:
                                  return const Text('10h',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12));
                                default:
                                  return Container();
                              }
                            },
                            reservedSize: 28,
                          ),
                        ),
                      ),
                      gridData: const FlGridData(show: true),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      barGroups: barGroups,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 250,
                                height: 150,
                                child: PieChart(
                                  PieChartData(
                                    sections: showingSections(),
                                    centerSpaceRadius: 0,
                                    sectionsSpace: 0,
                                    borderData: FlBorderData(show: false),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // const SizedBox(width: 20),
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Indicator(
                                color: Colors.blue,
                                text: 'Sun',
                              ),
                              SizedBox(height: 6),
                              Indicator(
                                color: Colors.orange,
                                text: 'Man',
                              ),
                              SizedBox(height: 6),
                              Indicator(
                                color: Colors.grey,
                                text: 'Tues',
                              ),
                              SizedBox(height: 6),
                              Indicator(
                                color: Colors.yellow,
                                text: 'Wednes',
                              ),
                              SizedBox(height: 6),
                            ],
                          ),
                          // const SizedBox(height: 10),
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 20),
                              Indicator(
                                color: Colors.green,
                                text: 'Thurs',
                              ),
                              SizedBox(height: 6),
                              Indicator(
                                color: Colors.brown,
                                text: 'Fri',
                              ),
                              SizedBox(height: 6),
                              Indicator(
                                color: Color.fromRGBO(41, 232, 85, 1),
                                text: 'Sat',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Month view
            Column(
              children: [
                const SizedBox(height: 20),
                const Text('January', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                const Text('Sleep average: 7.5h',
                    style: TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                Expanded(
                  flex: 2,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 10,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              switch (value.toInt()) {
                                case 0:
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text('04/15',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                  );
                                case 1:
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text('04/16',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                  );
                                case 2:
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text('04/17',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                  );
                                case 3:
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text('04/18',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                  );
                                case 4:
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text('04/19',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                  );
                                case 5:
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text('04/20',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                  );
                                case 6:
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text('04/21',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                  );
                                default:
                                  return Container();
                              }
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 2,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              switch (value.toInt()) {
                                case 0:
                                  return const Text('0h',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12));
                                case 2:
                                  return const Text('2h',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12));
                                case 4:
                                  return const Text('4h',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12));
                                case 6:
                                  return const Text('6h',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12));
                                case 8:
                                  return const Text('8h',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12));
                                case 10:
                                  return const Text('10h',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12));
                                default:
                                  return Container();
                              }
                            },
                            reservedSize: 28,
                          ),
                        ),
                      ),
                      gridData: const FlGridData(show: true),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      barGroups: barGroups,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 200,
                                height: 100,
                                child: PieChart(
                                  PieChartData(
                                    sections: showingSectionsMonths(),
                                    centerSpaceRadius: 0,
                                    sectionsSpace: 0,
                                    borderData: FlBorderData(show: false),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Indicator(
                                color: Colors.blue,
                                text: 'Avg Week 1',
                              ),
                              SizedBox(height: 8),
                              Indicator(
                                color: Colors.orange,
                                text: 'Avg Week 2',
                              ),
                              SizedBox(height: 8),
                              Indicator(
                                color: Colors.grey,
                                text: 'Avg Week 3',
                              ),
                              SizedBox(height: 8),
                              Indicator(
                                color: Colors.yellow,
                                text: 'Avg Week 4',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
