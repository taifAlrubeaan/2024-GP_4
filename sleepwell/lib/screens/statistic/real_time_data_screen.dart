import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RealTimeDataScreen extends StatefulWidget {
  @override
  _RealTimeDataScreenState createState() => _RealTimeDataScreenState();
}

class _RealTimeDataScreenState extends State<RealTimeDataScreen> {
  late String userId;
  final _auth = FirebaseAuth.instance;
  late User signInUser;
  late String email;

  // بيانات من قاعدة البيانات
  Map<String, dynamic> realTimeData = {};

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    print("::::::::::::::::::::ffffff:::::::::::::::::::");
    print(userId);
    print("::::::::::::::::::::ffffff:::::::::::::::::::");
  }

  // جلب المستخدم الحالي
  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        setState(() {
          signInUser = user;
          userId = user.uid;
          email = user.email!;
        });
        await saveUserIdToPrefs(userId);
        _fetchUserData(); // استدعاء جلب البيانات بعد استرجاع userId
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> saveUserIdToPrefs(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  // جلب البيانات من Firebase Realtime Database
  void _fetchUserData() {
    print("::::::::::::::::Start:::::::::::::::::::::::");
    final DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref().child('users');

    databaseReference.onValue.listen((event) {
      final data = event.snapshot.value;
      print("::::::::::::::::::::======:::::::::::::::::::");
      print(
          'Fetched data from Firebase: $data'); // طباعة البيانات في الـ console
      print(":::::::::::::::::::::::::::::::::::::::");
      if (data != null && data is Map<dynamic, dynamic>) {
        setState(() {
          // تخزين البيانات في الخريطة realTimeData
          realTimeData = Map<String, dynamic>.from(data);

          // طباعة البيانات في console
          print("Heart rate: ${realTimeData['Heart rate']}");
          print("SpO2: ${realTimeData['SpO2']}");
          print("Temperature: ${realTimeData['Temperatura']}");
        });
      } else {
        print('Fetched data from Firebase: $data');

        print('No data available or data is not a Map.');
      }
    }, onError: (error) {
      print('Error fetching data: $error');
      print(":::::::::::::::::::::::::::::::::::::::");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time Data Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: realTimeData.isEmpty
            ? const Center(
                child: CircularProgressIndicator()) // عرض مؤشر التحميل
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Heart rate: ${realTimeData['Heart rate'] ?? 'No data'}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'SpO2: ${realTimeData['SpO2'] ?? 'No data'}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Temperature: ${realTimeData['Temperatura'] ?? 'No data'}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
      ),
    );
  }
}
