import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/alarm_data.dart';

class AlarmListWidget extends StatelessWidget {
  final AlarmData alarm;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const AlarmListWidget({
    Key? key,
    required this.alarm,
    required this.onDelete,
    required this.onTap,
  }) : super(key: key);

  String calculateSleepCycles(String bedtime, String wakeTime) {
    try {
      final bedtimeDate = DateFormat("hh:mm a").parse(bedtime);
      final wakeTimeDate = DateFormat("hh:mm a").parse(wakeTime);

      final bedtimeInMinutes = bedtimeDate.hour * 60 + bedtimeDate.minute;
      final wakeTimeInMinutes = wakeTimeDate.hour * 60 + wakeTimeDate.minute;

      final durationInMinutes = (wakeTimeInMinutes >= bedtimeInMinutes)
          ? wakeTimeInMinutes - bedtimeInMinutes
          : (1440 - bedtimeInMinutes) + wakeTimeInMinutes;

      final cycles = durationInMinutes ~/ 90;

      return cycles == 1 ? "$cycles cycle" : "$cycles cycles";
    } catch (e) {
      print("Error in calculateSleepCycles: $e");
      return "Invalid time format";
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: const Color(0xFF2E4E7E),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alarm.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Bedtime: ${alarm.bedtime}\nOptimal Wake Time: ${alarm.optimalWakeTime}",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "Sleep Cycles: ${calculateSleepCycles(alarm.bedtime, alarm.optimalWakeTime)}",
                      style: const TextStyle(
                        color: Colors.lightBlue,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.redAccent,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
