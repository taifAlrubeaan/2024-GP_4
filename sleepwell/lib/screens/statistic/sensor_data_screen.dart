import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SensorDataScreen extends StatefulWidget {
  const SensorDataScreen({super.key});

  @override
  _SensorDataScreenState createState() => _SensorDataScreenState();
}

class _SensorDataScreenState extends State<SensorDataScreen> {
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('data');
  // final DatabaseReference sensorsDatabase =
  //     FirebaseDatabase.instance.ref().child('sensors');
  // final DatabaseReference usersSensors =
  //     FirebaseDatabase.instance.ref().child('usersSensors');
  double heartRate = 0;
  double spO2 = 0;
  double temperature = 0;
  double previousHeartRate = 0;
  double previousTemperature = 0;
  String alertTime = "";

  @override
  void initState() {
    super.initState();

    // Read data from the real-time database
    // _database.onValue.listen((DatabaseEvent event) {
    //   final data = event.snapshot.value;
    //   if (data != null && data is Map<dynamic, dynamic>) {
    //     setState(() {
    //       heartRate = data['Heart rate']?.toDouble() ?? 0;
    //       spO2 = data['SpO2']?.toDouble() ?? 0;
    //       temperature = data['Temperatura']?.toDouble() ?? 0;

    //       // Check for heart rate drop
    //       if (previousHeartRate != 0 && heartRate < previousHeartRate * 0.8) {
    //         alertTime = DateTime.now().toString(); // Record time of alert
    //         print("Heart rate dropped: $heartRate at $alertTime");
    //       }

    //       // Check for temperature drop
    //       if (previousTemperature != 0 &&
    //           temperature < previousTemperature - 0.5) {
    //         alertTime = DateTime.now().toString(); // Record time of alert
    //         print("Temperature dropped: $temperature at $alertTime");
    //       }

    //       // Update previous values
    //       previousHeartRate = heartRate;
    //       previousTemperature = temperature;
    //     });
    //   } else {
    //     print("No data available or wrong structure.");
    //   }
    // }, onError: (error) {
    //   print("Error reading data: $error");
    // });

    _database.onValue.listen((DatabaseEvent event) {
      try {
        final data = event.snapshot.value;
        if (data != null && data is Map<dynamic, dynamic>) {
          setState(() {
            heartRate = data['Heart rate']?.toDouble() ?? 0;
            spO2 = data['SpO2']?.toDouble() ?? 0;
            temperature = data['Temperatura']?.toDouble() ?? 0;

            // Check for heart rate drop
            if (previousHeartRate != 0 &&
                heartRate < previousHeartRate * 0.20) {
              alertTime = DateTime.now().toString(); // Record time of alert
              print("::::::::::::::::::::::::::::::::::::::::::::::::;");
              print("Heart rate dropped: $heartRate at $alertTime");
              print("::::::::::::::::::::::::::::::::::::::::::::::::;");
            }

            // Check for temperature drop
            if (previousTemperature != 0 &&
                temperature < previousTemperature - 0.5) {
              alertTime = DateTime.now().toString(); // Record time of alert
              print("::::::::::::::::::::::::::::::::::::::::::::::::;");
              print("Temperature dropped: $temperature at $alertTime");
              print("::::::::::::::::::::::::::::::::::::::::::::::::;");
            }

            // Update previous values
            previousHeartRate = heartRate;
            previousTemperature = temperature;
          });
        } else {
          print("No data available or wrong structure.");
        }
      } catch (error) {
        print("Error processing data: $error");
      }
    }, onError: (error) {
      print("Error reading data: $error");
    });
//
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sensor Data')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Heart Rate: $heartRate bpm',
                style: const TextStyle(fontSize: 24)),
            Text('SpO2: $spO2 %', style: const TextStyle(fontSize: 24)),
            Text('Temperature: $temperature °C',
                style: const TextStyle(fontSize: 24)),
            if (alertTime.isNotEmpty) // Display alert time if set
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Alert Time: $alertTime',
                  style: const TextStyle(fontSize: 20, color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
