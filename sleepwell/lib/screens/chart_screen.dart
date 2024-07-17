import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// class SleepChart extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         children: [
//           Text(
//             'Light and Deep Sleep Cycles',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 16),
//           Expanded(
//             child: LineChart(
//               LineChartData(
//                 gridData: FlGridData(show: false),
//                 titlesData: FlTitlesData(
//                   leftTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       getTitlesWidget: (value, meta) {
//                         switch (value.toInt()) {
//                           case 0:
//                             return Text('Awake');
//                           case 1:
//                             return Text('Light Sleep');
//                           case 2:
//                             return Text('Deep Sleep');
//                           default:
//                             return Text('');
//                         }
//                       },
//                       interval: 1,
//                       reservedSize: 80,
//                     ),
//                   ),
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       getTitlesWidget: (value, meta) {
//                         return Text('h${value.toInt() + 1}');
//                       },
//                       interval: 1,
//                     ),
//                   ),
//                 ),
//                 borderData: FlBorderData(show: true),
//                 lineBarsData: [
//                   LineChartBarData(
//                     isCurved: true,
//                     spots: [
//                       FlSpot(0, 0),
//                       FlSpot(1, 1),
//                       FlSpot(2, 0),
//                       FlSpot(3, 2),
//                       FlSpot(4, 0),
//                       FlSpot(5, 1),
//                     ],
//                     color: Colors.blue,
//                     barWidth: 3,
//                     belowBarData: BarAreaData(show: false),
//                   ),
//                 ],
//                 minX: 0,
//                 maxX: 5,
//                 minY: 0,
//                 maxY: 2,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
class SleepChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.white,
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 2),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Light and Deep Sleep Cycles',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              switch (value.toInt()) {
                                case 0:
                                  return Text('Awake',
                                      style: TextStyle(fontSize: 14));
                                case 1:
                                  return Text('Light Sleep',
                                      style: TextStyle(fontSize: 14));
                                case 2:
                                  return Text('Deep Sleep',
                                      style: TextStyle(fontSize: 14));
                                default:
                                  return Text('');
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
                                  style: TextStyle(fontSize: 14));
                            },
                            interval: 1,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
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
                      minX: 0,
                      maxX: 5,
                      minY: 0,
                      maxY: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Container(
        //   width: double.infinity,
        //   height: 200,
        //   padding: const EdgeInsets.all(16),
        //   decoration: BoxDecoration(
        //     border: Border.all(color: Colors.grey),
        //     borderRadius: BorderRadius.circular(8),
        //     color: Colors.blue[50],
        //   ),
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       const Text(
        //         'Light and Deep Sleep Cycles',
        //         style: TextStyle(
        //             fontSize: 16, fontWeight: FontWeight.bold),
        //       ),
        //       const SizedBox(height: 8),
        //       Expanded(
        //         child: LineChart(
        //           LineChartData(
        //             gridData: const FlGridData(show: false),
        //             titlesData: FlTitlesData(
        //               leftTitles: AxisTitles(
        //                 sideTitles: SideTitles(
        //                   showTitles: true,
        //                   getTitlesWidget: (value, meta) {
        //                     switch (value.toInt()) {
        //                       case 0:
        //                         return const Text('Deep Sleep');
        //                       case 1:
        //                         return const Text('Light Sleep');
        //                       case 2:
        //                         return const Text('Awake');
        //                       default:
        //                         return const Text('');
        //                     }
        //                   },
        //                 ),
        //               ),
        //               bottomTitles: AxisTitles(
        //                 sideTitles: SideTitles(
        //                   showTitles: true,
        //                   getTitlesWidget: (value, meta) {
        //                     switch (value.toInt()) {
        //                       case 0:
        //                         return const Text('0h');
        //                       case 1:
        //                         return const Text('1h');
        //                       case 2:
        //                         return const Text('2h');
        //                       case 3:
        //                         return const Text('3h');
        //                       case 4:
        //                         return const Text('4h');
        //                       case 5:
        //                         return const Text('5h');
        //                       case 6:
        //                         return const Text('6h');
        //                       default:
        //                         return const Text('');
        //                     }
        //                   },
        //                 ),
        //               ),
        //             ),
        //             borderData: FlBorderData(
        //               show: true,
        //               border:
        //                   Border.all(color: Colors.black, width: 1),
        //             ),
        //             minX: 0,
        //             maxX: 6,
        //             minY: 0,
        //             maxY: 2,
        //             lineBarsData: [
        //               LineChartBarData(
        //                 spots: sleepData,
        //                 isCurved: true,
        //                 color: Colors.blue,
        //                 barWidth: 4,
        //                 isStrokeCapRound: true,
        //                 belowBarData: BarAreaData(show: false),
        //               ),
        //             ],
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),

        // Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: Column(
        //     children: [
        //       Text(
        //         'Light and Deep Sleep Cycles',
        //         style: TextStyle(
        //           fontSize: 24,
        //           fontWeight: FontWeight.bold,
        //         ),
        //       ),
        //       SizedBox(height: 16),
        //       Expanded(
        //         child: LineChart(
        //           LineChartData(
        //             gridData: FlGridData(show: false),
        //             titlesData: FlTitlesData(
        //               leftTitles: AxisTitles(
        //                 sideTitles: SideTitles(
        //                   showTitles: true,
        //                   getTitlesWidget: (value, meta) {
        //                     switch (value.toInt()) {
        //                       case 0:
        //                         return Text('Awake',
        //                             style: TextStyle(fontSize: 14));
        //                       case 1:
        //                         return Text('Light Sleep',
        //                             style: TextStyle(fontSize: 14));
        //                       case 2:
        //                         return Text('Deep Sleep',
        //                             style: TextStyle(fontSize: 14));
        //                       default:
        //                         return Text('');
        //                     }
        //                   },
        //                   interval: 1,
        //                   reservedSize:
        //                       100, // زيادة الحجم المحجوز للعنوان الجانبي
        //                 ),
        //               ),
        //               bottomTitles: AxisTitles(
        //                 sideTitles: SideTitles(
        //                   showTitles: true,
        //                   getTitlesWidget: (value, meta) {
        //                     return Text('h${value.toInt() + 1}',
        //                         style: TextStyle(fontSize: 14));
        //                   },
        //                   interval: 1,
        //                 ),
        //               ),
        //             ),
        //             borderData: FlBorderData(show: true),
        //             lineBarsData: [
        //               LineChartBarData(
        //                 isCurved: true,
        //                 spots: [
        //                   FlSpot(0, 0),
        //                   FlSpot(1, 1),
        //                   FlSpot(2, 0),
        //                   FlSpot(3, 2),
        //                   FlSpot(4, 0),
        //                   FlSpot(5, 1),
        //                 ],
        //                 color: Colors.blue,
        //                 barWidth: 3,
        //                 belowBarData: BarAreaData(show: false),
        //               ),
        //             ],
        //             minX: 0,
        //             maxX: 5,
        //             minY: 0,
        //             maxY: 2,
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),

        // Container(
        //   color: Colors.white,
        //   constraints: BoxConstraints(
        //       maxHeight: MediaQuery.of(context).size.height / 2),
        //   child: Padding(
        //     padding: const EdgeInsets.all(16.0),
        //     child: Column(
        //       children: [
        //         const Text(
        //           'Light and Deep Sleep Cycles',
        //           style: TextStyle(
        //             fontSize: 24,
        //             fontWeight: FontWeight.bold,
        //           ),
        //         ),
        //         // SizedBox(height: 16),
        //         Expanded(
        //           child: LineChart(
        //             LineChartData(
        //               gridData: FlGridData(show: false),
        //               titlesData: FlTitlesData(
        //                 leftTitles: AxisTitles(
        //                   sideTitles: SideTitles(
        //                     showTitles: true,
        //                     getTitlesWidget: (value, meta) {
        //                       switch (value.toInt()) {
        //                         case 0:
        //                           return Text('Awake',
        //                               style: TextStyle(fontSize: 14));
        //                         case 1:
        //                           return Text('Light Sleep',
        //                               style: TextStyle(fontSize: 14));
        //                         case 2:
        //                           return Text('Deep Sleep',
        //                               style: TextStyle(fontSize: 14));
        //                         default:
        //                           return Text('');
        //                       }
        //                     },
        //                     interval: 1,
        //                     reservedSize: 100,
        //                   ),
        //                 ),
        //                 bottomTitles: AxisTitles(
        //                   sideTitles: SideTitles(
        //                     showTitles: true,
        //                     getTitlesWidget: (value, meta) {
        //                       return Text('h${value.toInt() + 1}',
        //                           style: TextStyle(fontSize: 14));
        //                     },
        //                     interval: 1,
        //                   ),
        //                 ),
        //               ),
        //               borderData: FlBorderData(show: true),
        //               lineBarsData: [
        //                 LineChartBarData(
        //                   isCurved: true,
        //                   spots: [
        //                     FlSpot(0, 0),
        //                     FlSpot(1, 1),
        //                     FlSpot(2, 0),
        //                     FlSpot(3, 2),
        //                     FlSpot(4, 0),
        //                     FlSpot(5, 1),
        //                   ],
        //                   color: Colors.blue,
        //                   barWidth: 3,
        //                   belowBarData: BarAreaData(show: false),
        //                 ),
        //               ],
        //               minX: 0,
        //               maxX: 5,
        //               minY: 0,
        //               maxY: 2,
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),

        // Container(
        //   color: Colors.white,
        //   constraints: BoxConstraints(
        //     maxHeight: MediaQuery.of(context).size.height / 3,
        //   ),
        //   child: Padding(
        //     padding: const EdgeInsets.all(16.0),
        //     child: Column(
        //       children: [
        //         const Text(
        //           'Light and Deep Sleep Cycles',
        //           style: TextStyle(
        //             fontSize: 24,
        //             fontWeight: FontWeight.bold,
        //           ),
        //         ),
        //         const SizedBox(height: 16),
        //         Expanded(
        //           child: LineChart(
        //             LineChartData(
        //               lineBarsData: [
        //                 LineChartBarData(
        //                   isCurved: true,
        //                   spots: [
        //                     const FlSpot(0, 0),
        //                     const FlSpot(1, 1),
        //                     const FlSpot(2, 0),
        //                     const FlSpot(3, 2),
        //                     const FlSpot(4, 0),
        //                     const FlSpot(5, 1),
        //                   ],
        //                   color: Colors.blue,
        //                   barWidth: 3,
        //                   belowBarData: BarAreaData(show: false),
        //                 ),
        //               ],
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// class SleepChart extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               Text(
//                 'Light and Deep Sleep Cycles',
//                 style: TextStyle(
//                   fontSize: 24.0,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 16.0),
//               Flexible(
//                 fit: FlexFit.loose,
//                 child: Container(
//                   height: 200.0, // Adjust the height as needed
//                   color: Colors.blue,
//                   child: Center(
//                     child: Text(
//                       'Sleep Data',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 16.0),
//               Flexible(
//                 fit: FlexFit.loose,
//                 child: Container(
//                   height: 200.0, // Adjust the height as needed
//                   color: Colors.green,
//                   child: Center(
//                     child: Text(
//                       'More Sleep Data',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// void main() => runApp(MaterialApp(home: StatisticsScreen()));
