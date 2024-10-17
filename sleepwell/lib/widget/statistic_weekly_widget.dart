import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatisticsWeeklyWidget extends StatelessWidget {
  final List<BarChartGroupData> barGroups;
  final List<PieChartSectionData> pieSections;
  final double chartMaxYweek;
  final double averageSleepHours;
  final String weekRange;

  StatisticsWeeklyWidget({
    Key? key,
    required this.barGroups,
    required this.pieSections,
    required this.chartMaxYweek,
    required this.averageSleepHours,
    required this.weekRange,
  }) : super(key: key);

  final List<String> daysOfWeek = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  late List<String> formattedDatesDay;

  List<String> getFormattedDatesForWeek() {
    final now = DateTime.now();
    final weekStart = now.subtract(const Duration(days: 7)); // 7 days ago

    formattedDatesDay = []; // Initialize the list

    for (int i = 0; i < 7; i++) {
      DateTime date = weekStart.add(Duration(days: i));

      // Store the formatted date (e.g., 01/10) in formattedDatesDay
      String formattedDate = DateFormat('dd/MM').format(date);
      formattedDatesDay.add(formattedDate);
    }

    return formattedDatesDay;
  }

  @override
  Widget build(BuildContext context) {
    // Initialize the formattedDatesDay list before building the widget
    // getFormattedDatesForWeek();

    return SafeArea(
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(weekRange,
                  style: const TextStyle(fontSize: 16, color: Colors.white)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  'Sleep average hours: ${averageSleepHours.toStringAsFixed(1)}h',
                  style: const TextStyle(fontSize: 16, color: Colors.white)),
            ),
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
                          final index = value.toInt();

                          final List<String> formattedDatesDayes =
                              getFormattedDatesForWeek();

                          return Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text(
                              index < formattedDatesDayes.length
                                  ? formattedDatesDayes[index]
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
                      sideTitles: SideTitles(showTitles: false),
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
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                  ),
                  barGroups: barGroups,
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                color: const Color(0xFFBBDEFB),
                child: Center(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10, top: 10),
                        child: Text(
                          'Number Of Sleep Cycle:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 200,
                            height: 80,
                            child: PieChart(
                              PieChartData(
                                sections: pieSections,
                                centerSpaceRadius: 8,
                                sectionsSpace: 2,
                                borderData: FlBorderData(show: false),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(
                                  4, // First 4 days (Sun, Mon, Tue, Wed)
                                  (index) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          color: pieSections[index].color,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          daysOfWeek[index],
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(
                                  3, // Remaining 3 days (Thu, Fri, Sat)
                                  (index) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          color: pieSections[index + 4].color,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          daysOfWeek[index + 4],
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
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
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
