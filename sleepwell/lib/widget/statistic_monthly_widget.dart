import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatisticsMonthlyWidget extends StatelessWidget {
  final List<BarChartGroupData> barGroups;
  final List<PieChartSectionData> pieSections;
  final double chartMaxYMonthly;
  final double averageMonthlySleepHours;
  final String monthName;

  StatisticsMonthlyWidget({
    Key? key,
    required this.barGroups,
    required this.pieSections,
    required this.chartMaxYMonthly,
    required this.averageMonthlySleepHours,
    required this.monthName,
  }) : super(key: key);

  final List<String> weeksOfMonth = [
    'Avg W1',
    'Avg W2',
    'Avg W3',
    'Avg W4',
  ];

  late List<String> formattedDatesWeeks;

  List<String> getFormattedDatesForMonth() {
    final now = DateTime.now();
    final DateTime monthStart = DateTime(now.year, now.month, 1); // بداية الشهر
    final int daysInMonth =
        DateTime(now.year, now.month + 1, 0).day; // عدد أيام الشهر

    formattedDatesWeeks = []; // تهيئة القائمة

    for (int i = 0; i < 4; i++) {
      final int weekStartDay = i * 7 + 1;
      final int weekEndDay =
          (i + 1) * 7 > daysInMonth ? daysInMonth : (i + 1) * 7;

      // صياغة النطاق الأسبوعي مثل "01-07/10"
      String formattedRange = '$weekStartDay/$weekEndDay-${now.month}';
      formattedDatesWeeks.add(formattedRange);
    }

    return formattedDatesWeeks;
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
              child: Text(monthName,
                  style: const TextStyle(fontSize: 16, color: Colors.white)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  'Sleep average hours: ${averageMonthlySleepHours.toStringAsFixed(1)}h',
                  style: const TextStyle(fontSize: 16, color: Colors.white)),
            ),
            Expanded(
              flex: 2,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: chartMaxYMonthly,
                  backgroundColor: const Color.fromRGBO(187, 222, 251, 1),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();

                          final List<String> formattedDatesWeeks =
                              getFormattedDatesForMonth();

                          return Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text(
                              index < formattedDatesWeeks.length
                                  ? formattedDatesWeeks[index]
                                  : 'Invalid Date', // في حالة تجاوز النطاق
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
                              color: Colors.white,
                            ),
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
                          'Average Number Of Sleep Cycle:',
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
                                          weeksOfMonth[index],
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
