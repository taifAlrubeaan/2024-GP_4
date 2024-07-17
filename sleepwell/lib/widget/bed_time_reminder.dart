import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../main.dart';

class BedTimeReminder extends StatefulWidget {
  @override
  _BedTimeReminderState createState() => _BedTimeReminderState();
}

class _BedTimeReminderState extends State<BedTimeReminder> {
  bool isSwitched = false;
  TimeOfDay? selectedTime;

  @override
  Widget build(BuildContext context) {
    double newValue = (prefs.getInt('bedtime') ?? 1).toDouble();
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Bed Time Reminder',
            style: TextStyle(
              fontSize: 22,
              color: Colors.black,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bed time Reminder',
                style: TextStyle(fontSize: 24),
              ),
              Switch(
                value: isSwitched,
                onChanged: (value) {
                  setState(() {
                    isSwitched = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (isSwitched) ...[
            const Text(
              'Select Bed time',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  setState(() {
                    selectedTime = pickedTime;
                  });
                }
              },
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  selectedTime != null
                      ? selectedTime!.format(context)
                      : 'Select Bed time',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      prefs.setInt("snooze", newValue.toInt());
                      print("--- success save snooze value $newValue");
                      Get.back();
                    },
                    child: const Text("Save"),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Bed Time Reminder'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Bed time Reminder',
//                   style: TextStyle(fontSize: 24),
//                 ),
//                 Switch(
//                   value: isSwitched,
//                   onChanged: (value) {
//                     setState(() {
//                       isSwitched = value;
//                     });
//                   },
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             if (isSwitched) ...[
//               const Text(
//                 'Select Bed time',
//                 style: TextStyle(fontSize: 18),
//               ),
//               const SizedBox(height: 10),
//               GestureDetector(
//                 onTap: () async {
//                   TimeOfDay? pickedTime = await showTimePicker(
//                     context: context,
//                     initialTime: TimeOfDay.now(),
//                   );
//                   if (pickedTime != null) {
//                     setState(() {
//                       selectedTime = pickedTime;
//                     });
//                   }
//                 },
//                 child: Container(
//                   width: double.infinity,
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.black),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     selectedTime != null
//                         ? selectedTime!.format(context)
//                         : 'Select Bed time',
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                 ),
//               ),
//             ],
//             Padding(
//               padding: const EdgeInsets.all(10),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () => Get.back(),
//                       child: const Text("Cancel"),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         prefs.setInt("snooze", newValue.toInt());
//                         print("--- success save snooze value $newValue");
//                         Get.back();
//                       },
//                       child: const Text("Save"),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

 