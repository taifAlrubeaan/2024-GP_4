// import 'dart:async';

// import 'package:alarm/model/alarm_settings.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:sleepwell/alarm.dart';

// import 'package:sleepwell/screens/profile_screen.dart';
// import 'package:sleepwell/screens/statistic_screen.dart';

// import 'alarm_screen.dart';

// class MyHomePage extends StatefulWidget {
//   static String RouteScreen = 'home_screen';
//   const MyHomePage({super.key});

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   final _auth = FirebaseAuth.instance;
//   late User signInUser;
//   StreamSubscription<AlarmSettings>? subscription;
//   @override
//   void initState() {
//     super.initState();
//     AppAlarm.initAlarms();
//     getCurrentUser();
//   }

//   void getCurrentUser() {
//     // check is the user sign up or not ?
//     try {
//       final user = _auth.currentUser;
//       // if rutern 0 no user found if not will rutern the email and the password
//       if (user != null) {
//         signInUser = user;
//         // should be deleted now just for testing
//         print(signInUser.email);
//       }
//     } catch (e) {
//       print(e);
//     }
//   }

//   int index = 3;
//   final pages = [
//     const ProfileScreen(),
//     // const Center(child: Text('Hello  statistic  ')),
//     const StatisticScreen(),
//     // AlarmSetupScreen(),

//     AlarmScreen(),
//     const Center(child: Text('Hello Dashboard')),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: NavigationBar(
//         selectedIndex: index,
//         onDestinationSelected: (index) => setState(() => this.index = index),
//         backgroundColor: const Color(0xFF040E3B),
//         height: 70,
//         destinations: const [
//           NavigationDestination(
//             icon: Icon(Icons.person_outlined, color: Colors.white),
//             selectedIcon: Icon(Icons.person, color: Colors.white),
//             label: 'profile',
//           ),
//           NavigationDestination(
//             icon:
//                 Icon(Icons.align_vertical_bottom_outlined, color: Colors.white),
//             selectedIcon:
//                 Icon(Icons.align_vertical_bottom, color: Colors.white),
//             label: 'Statistic',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.access_alarm_outlined, color: Colors.white),
//             selectedIcon: Icon(Icons.access_alarm, color: Colors.white),
//             label: 'Alarm',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.dashboard_customize_outlined, color: Colors.white),
//             selectedIcon: Icon(Icons.dashboard_customize, color: Colors.white),
//             label: 'Dashboard',
//           ),
//         ],
//       ),
//       body: pages[index],
//     );
//   }
// }
