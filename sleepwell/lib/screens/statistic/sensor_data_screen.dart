import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SensorDataScreen extends StatefulWidget {
  const SensorDataScreen({super.key});

  @override
  _SensorDataScreenState createState() => _SensorDataScreenState();
}

class _SensorDataScreenState extends State<SensorDataScreen> {
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('data2');
  double heartRate = 0;
  double spO2 = 0;
  double temperature = 0;

  @override
  void initState() {
    super.initState();

    // قراءة البيانات من الريل تايم داتابيس
    _database.onValue.listen((DatabaseEvent event) {
      print(
          "Event received: ${event.snapshot.value}"); // طباعة البيانات المستلمة
      final data = event.snapshot.value;
      if (data != null && data is Map<dynamic, dynamic>) {
        setState(() {
          heartRate = data['Heart rate']?.toDouble() ?? 0;
          spO2 = data['SpO2']?.toDouble() ?? 0;
          temperature = data['Temperatura']?.toDouble() ?? 0;

          print("HeartRate: $heartRate");
          print("SpO2: $spO2");
          print("Temperature: $temperature");
        });
      } else {
        print("No data available or wrong structure.");
      }
    }, onError: (error) {
      print("Error reading data: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SensoRr Data')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                print("Button Pressed: Fetching data...");

                _database.once().then((DatabaseEvent event) {
                  final data = event.snapshot.value;
                  print(
                      "Data fetched on button press: $data"); // طباعة البيانات عند الضغط على الزر
                  if (data != null && data is Map<dynamic, dynamic>) {
                    setState(() {
                      heartRate = data['Heart rate']?.toDouble() ?? 0;
                      spO2 = data['SpO2']?.toDouble() ?? 0;
                      temperature = data['Temperatura']?.toDouble() ?? 0;

                      print("HeartRate: $heartRate");
                      print("SpO2: $spO2");
                      print("Temperature: $temperature");
                    });
                  } else {
                    print("No data available or wrong structure.");
                  }
                }).catchError((error) {
                  print("Error fetching data: $error");
                });
              },
              child: const Text("Show Data"),
            ),
            Text('Heart Rate: $heartRate bpm',
                style: const TextStyle(fontSize: 24)),
            Text('SpO2: $spO2 %', style: const TextStyle(fontSize: 24)),
            Text('Temperature: $temperature °C',
                style: const TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
