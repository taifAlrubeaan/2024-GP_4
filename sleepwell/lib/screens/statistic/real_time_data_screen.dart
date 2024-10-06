// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class RealTimeDataScreen extends StatefulWidget {
//   @override
//   _RealTimeDataScreenState createState() => _RealTimeDataScreenState();
// }

// class _RealTimeDataScreenState extends State<RealTimeDataScreen> {
//   late String userId;
//   final _auth = FirebaseAuth.instance;
//   late User signInUser;
//   late String email;

//   // Data from the database
//   Map<String, dynamic> realTimeData = {};

//   @override
//   void initState() {
//     super.initState();
//     getCurrentUser();
//   }

//   void getCurrentUser() async {
//     try {
//       final user = _auth.currentUser;
//       if (user != null) {
//         setState(() {
//           signInUser = user;
//           userId = user.uid;
//           email = user.email!;
//         });
//         await saveUserIdToPrefs(userId);
//         _fetchUserData(); // Fetch data after setting userId
//       }
//     } catch (e) {
//       print(e);
//     }
//   }

//   Future<void> saveUserIdToPrefs(String userId) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('userId', userId);
//   }

//   void _fetchUserData() {
//     print("Fetching user data...");
//     print("User id is:$userId::::::::::::::::::");

//     final DatabaseReference databaseReference =
//         FirebaseDatabase.instance.ref('users/$userId'); // Use the userId here

//     databaseReference.onValue.listen((event) {
//       if (event.snapshot.exists) {
//         final data = event.snapshot.value;
//         print('Fetched data from Firebase: $data');

//         if (data != null && data is Map<dynamic, dynamic>) {
//           setState(() {
//             realTimeData = Map<String, dynamic>.from(data);
//             print("Heart rate: ${realTimeData['Heart rate']}");
//             print("SpO2: ${realTimeData['SpO2']}");
//             print("Temperatura: ${realTimeData['Temperatura']}");
//           });
//         } else {
//           print('No data available or data is not a Map.');
//         }
//       } else {
//         print('Snapshot does not exist. Path might be incorrect.');
//       }
//     }, onError: (error) {
//       print('Error fetching data: $error');
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Real-Time Data Screen'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Heart rate: ${realTimeData['Heart rate'] ?? 'No data'}',
//               style: const TextStyle(fontSize: 18),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               'SpO2: ${realTimeData['SpO2'] ?? 'No data'}',
//               style: const TextStyle(fontSize: 18),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               'Temperatura: ${realTimeData['Temperatura'] ?? 'No data'}',
//               style: const TextStyle(fontSize: 18),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
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
  }

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
        _fetchUserData(); // جلب البيانات بعد تعيين userId
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> saveUserIdToPrefs(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  void _fetchUserData() {
    print("Fetching user data...");
    print("User id is: $userId");

    final DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref('users/$userId'); // Use the userId here

    print('Checking path: users/$userId');

    databaseReference.onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value;
        print('Fetched data from Firebase: $data');

        if (data != null && data is Map<dynamic, dynamic>) {
          setState(() {
            realTimeData = Map<String, dynamic>.from(data)
              ..remove('uid'); // Remove 'uid' from the data
          });
        } else {
          print('No data available or data is not a Map.');
        }
      } else {
        print('Snapshot does not exist at path: users/$userId');
      }
    }, onError: (error) {
      print('Error fetching data: $error');
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
        child: Column(
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
              'Temperatura: ${realTimeData['Temperatura'] ?? 'No data'}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
