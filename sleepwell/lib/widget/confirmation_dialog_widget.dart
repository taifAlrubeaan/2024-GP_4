import 'package:flutter/material.dart';

class ConfirmationDialogWidget extends StatelessWidget {
  final String alarmFor;
  final String selectedDevice;
  final String wakeUpTime;
  final String bedTime;
  final int sleepCycle;
  final Function()? onPressed;
  final Function()? changeDevice;

  const ConfirmationDialogWidget({
    super.key,
    required this.alarmFor,
    required this.selectedDevice,
    required this.wakeUpTime,
    required this.bedTime,
    required this.sleepCycle,
    this.onPressed,
    this.changeDevice,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Center(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          width:
              mediaQuery.size.width * 0.9, // Adjust width based on screen size
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Confirmation',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Ensure text is visible
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildRow('Alarm For', alarmFor),
              _buildRow('Selected Device', selectedDevice),
              _buildRow('Wake Up Time', wakeUpTime),
              _buildRow('Bed Time', bedTime),
              _buildRow('Sleep Cycle', '$sleepCycle cycles'),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      minimumSize: Size(
                          mediaQuery.size.width * 0.35, 40), // Button width
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: changeDevice,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: Size(
                          mediaQuery.size.width * 0.35, 40), // Button width
                    ),
                    child: const Text(
                      'Change Device',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: Size(mediaQuery.size.width * 0.75,
                        40), // Full width cancel button
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              softWrap:
                  true, // Allows text to wrap to the next line if necessary
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
