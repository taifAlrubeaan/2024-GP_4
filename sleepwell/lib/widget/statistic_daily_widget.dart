import 'package:flutter/material.dart';
import '../../widget/info_card.dart';

class StatisticDailyWidget extends StatelessWidget {
  final String sleepHoursDuration;
  final String wakeup_time;
  final String numOfCycles;
  final String actualSleepTime;

  const StatisticDailyWidget({
    super.key,
    required this.sleepHoursDuration,
    required this.wakeup_time,
    required this.numOfCycles,
    required this.actualSleepTime,
  });

  Map<String, dynamic> calculateSleepStages(String numCycles) {
    int cycles = int.tryParse(numCycles) ?? 0;

    // المدة لكل مرحلة بناءً على عدد الدورات
    int lightSleepMin = (45 * cycles); // 45 دقيقة لكل دورة
    int deepSleepMin = (18 * cycles); // 18 دقيقة لكل دورة
    int remSleepMin = (18 * cycles); // 18 دقيقة لكل دورة

    // المجموع الكلي للدقائق
    int totalMinutes = lightSleepMin + deepSleepMin + remSleepMin;

    // حساب النسبة المئوية لكل مرحلة
    double lightSleepPercentage = (lightSleepMin / totalMinutes) * 100;
    double deepSleepPercentage = (deepSleepMin / totalMinutes) * 100;
    double remSleepPercentage = (remSleepMin / totalMinutes) * 100;

    String lightSleepDuration = _convertMinutesToHours(lightSleepMin);
    String deepSleepDuration = _convertMinutesToHours(deepSleepMin);
    String remSleepDuration = _convertMinutesToHours(remSleepMin);

    return {
      "Light": {
        "duration": lightSleepDuration,
        "percentage": lightSleepPercentage
      },
      "Deep": {
        "duration": deepSleepDuration,
        "percentage": deepSleepPercentage
      },
      "REM": {"duration": remSleepDuration, "percentage": remSleepPercentage},
    };
  }

  String _convertMinutesToHours(int minutes) {
    int hours = minutes ~/ 60;
    int mins = minutes % 60;
    return '$hours h $mins m';
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> sleepStages = calculateSleepStages(numOfCycles);

    return Container(
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
                  value: sleepHoursDuration,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: InfoCard(
                  title: 'Actual Sleep Time:',
                  value: actualSleepTime,
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
                  value: '$numOfCycles Cycles',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InfoCard(
                  title: "Wake up Time:",
                  value: wakeup_time,
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
                  buildSleepStageRow(
                      context,
                      'REM',
                      sleepStages["REM"]["percentage"],
                      sleepStages["REM"]["duration"],
                      Colors.lightBlue[200]!),
                  buildSleepStageRow(
                      context,
                      'Light',
                      sleepStages["Light"]["percentage"],
                      sleepStages["Light"]["duration"],
                      Colors.blue[400]!),
                  buildSleepStageRow(
                      context,
                      'Deep',
                      sleepStages["Deep"]["percentage"],
                      sleepStages["Deep"]["duration"],
                      const Color.fromARGB(224, 13, 20, 161)!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSleepStageRow(BuildContext context, String stage,
      double percentage, String duration, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          stage,
          style: const TextStyle(color: Colors.white),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: Stack(
            alignment: Alignment.center,
            children: [
              LinearProgressIndicator(
                value: percentage / 100.0,
                backgroundColor: Colors.grey[300],
                color: color,
                minHeight: 15,
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ],
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
