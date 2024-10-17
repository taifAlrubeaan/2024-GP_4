import 'package:flutter/material.dart';
// import 'package:flutter_blue/flutter_blue.dart';  // مكتبة Bluetooth
import 'dart:convert'; // لتحويل البيانات إلى JSON
import 'package:http/http.dart' as http;
// class AddDevicesScreen1 extends StatefulWidget {
//   @override
//   _AddDevicesScreen1State createState() => _AddDevicesScreen1State();
// }

// class _AddDevicesScreen1State extends State<AddDevicesScreen1> {
//   FlutterBlue flutterBlue = FlutterBlue.instance;
//   List<BluetoothDevice> devicesList = [];

//   @override
//   void initState() {
//     super.initState();
//     scanForDevices(); // بدء البحث عند تحميل الصفحة
//   }

//   void scanForDevices() {
//     flutterBlue.scan().listen((scanResult) {
//       setState(() {
//         if (!devicesList.contains(scanResult.device)) {
//           devicesList.add(scanResult.device);
//         }
//       });
//     });
//   }

//   void connectToDevice(BluetoothDevice device) async {
//     await device.connect();
//     // بمجرد الاتصال، قم بقراءة البيانات من الحساسات وإرسالها إلى Firebase
//     readSensorData(device);
//   }

//   void readSensorData(BluetoothDevice device) {
//     // كتابة المنطق لقراءة البيانات من الحساس هنا
//     // يمكن أن يعتمد على الخدمة والخاصية التي يقدمها الحساس
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add Devices'),
//       ),
//       body: Column(
//         children: [
//           ElevatedButton(
//             onPressed: scanForDevices, // إعادة البحث عن الأجهزة
//             child: Text('Scan for Devices'),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: devicesList.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(devicesList[index].name),
//                   subtitle: Text(devicesList[index].id.toString()),
//                   onTap: () {
//                     connectToDevice(devicesList[index]);
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class AddDevicesScreen extends StatefulWidget {
  @override
  _AddDevicesScreenState createState() => _AddDevicesScreenState();
}

class _AddDevicesScreenState extends State<AddDevicesScreen> {
  final String serverUrl =
      "https://sleepwell-2d0c4-default-rtdb.asia-southeast1.firebasedatabase.app/"; // عنوان السيرفر
  int heartRate = 75; // معدل ضربات القلب (كمثال)
  int spO2 = 98; // مستوى الأكسجين في الدم (كمثال)

  // دالة لإرسال بيانات الحساس إلى السيرفر
  Future<void> addDevice() async {
    try {
      // إعداد بيانات الحساس للإرسال
      String postData = jsonEncode({
        'heartRate': heartRate,
        'spO2': spO2,
      });

      // إرسال طلب HTTP Post إلى السيرفر
      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: postData,
      );

      if (response.statusCode == 200) {
        // تم إرسال البيانات بنجاح
        print('Device added successfully: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Device added successfully')),
        );
      } else {
        // حدث خطأ أثناء الإرسال
        print('Error adding device: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding device')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Devices'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Heart Rate: $heartRate'),
            Text('SpO2: $spO2'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: addDevice, // إضافة جهاز جديد
              child: const Text('Add Device'),
            ),
          ],
        ),
      ),
    );
  }
}
