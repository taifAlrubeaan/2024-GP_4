// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
// import 'alarm_screen.dart';
// import 'profile_screen.dart';
// import 'statistic_screen.dart';
// import 'dashboard_screen.dart';

// class MainScreen extends StatefulWidget {
//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   int _currentIndex = 2; // Start with the Alarm page

//   final List<Widget> _pages = [
//     ProfileScreen(),
//     StatisticScreen(),
//     AlarmScreen(),
//     DashboardScreen(),
//   ];

//   void onTabTapped(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_currentIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         onTap: onTabTapped,
//         currentIndex: _currentIndex,
//         backgroundColor: Color(0xFF040E3B),
//         type: BottomNavigationBarType.fixed,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person_outlined, color: Colors.white),
//             activeIcon: Icon(Icons.person, color: Colors.white),
//             label: 'Profile',
//           ),
//           BottomNavigationBarItem(
//             icon:
//                 Icon(Icons.align_vertical_bottom_outlined, color: Colors.white),
//             activeIcon: Icon(Icons.align_vertical_bottom, color: Colors.white),
//             label: 'Statistic',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.access_alarm_outlined, color: Colors.white),
//             activeIcon: Icon(Icons.access_alarm, color: Colors.white),
//             label: 'Alarm',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.dashboard_customize_outlined, color: Colors.white),
//             activeIcon: Icon(Icons.dashboard_customize, color: Colors.white),
//             label: 'Dashboard',
//           ),
//         ],
//       ),
//     );
//   }
// }
