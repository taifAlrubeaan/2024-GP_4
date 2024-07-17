import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../widget/indicator.dart';

class PieChartSample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pie Chart Example'),
      ),
      body: Center(
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
                      sections: showingSections(),
                      centerSpaceRadius: 0,
                      sectionsSpace: 0,
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
                width: 20), // قم بضبط العرض بين المخطط والنصوص إذا لزم الأمر
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start, // محاذاة النصوص إلى اليسار
              children: [
                Indicator(
                  color: Colors.blue,
                  text: 'Survey Question 1',
                ),
                SizedBox(height: 8),
                Indicator(
                  color: Colors.orange,
                  text: 'Survey Question 2',
                ),
                SizedBox(height: 8),
                Indicator(
                  color: Colors.grey,
                  text: 'Survey Question 3',
                ),
                SizedBox(height: 8),
                Indicator(
                  color: Colors.yellow,
                  text: 'Survey Question 4',
                ),
                SizedBox(height: 8),
                Indicator(
                  color: Colors.brown,
                  text: 'Survey Question 5',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return [
      PieChartSectionData(
        color: Colors.blue,
        value: 20,
        title: '',
        radius: 100,
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: 30,
        title: '',
        radius: 100,
      ),
      PieChartSectionData(
        color: Colors.grey,
        value: 25,
        title: '',
        radius: 100,
      ),
      PieChartSectionData(
        color: Colors.yellow,
        value: 15,
        title: '',
        radius: 100,
      ),
      PieChartSectionData(
        color: Colors.brown,
        value: 10,
        title: '',
        radius: 100,
      ),
    ];
  }
}
