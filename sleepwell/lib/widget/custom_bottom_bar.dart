// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:sleepwell/screens/alarm_screen.dart';
// import '../screens/dashboard_screen.dart';
// import '../screens/profile_screen.dart';
// import '../screens/statistic/statistic_sleepwell_screen.dart';

// class CustomBottomBar extends StatefulWidget {
//   @override
//   _CustomBottomBarState createState() => _CustomBottomBarState();
// }

// class _CustomBottomBarState extends State<CustomBottomBar> {
//   int index = 2;

//   void onTabTapped(int currentIndexselected) {
//     setState(() {
//       index = currentIndexselected;
//     });

//     if (index == 0) {
//       Get.offAll(() => const ProfileScreen());
//       // (index) => setState(() => this.index = index);
//     } else if (index == 1) {
//       Get.offAll(() => const StatisticSleepWellScreen());
//       // (index) => setState(() => this.index = index);
//     } else if (index == 2) {
//       Get.offAll(() => AlarmScreen());
//       // (index) => setState(() => this.index = index);
//     } else if (index == 3) {
//       Get.offAll(() => DashboardScreen());
//       // (index) => setState(() => this.index = index);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       backgroundColor: const Color(0xFF040E3B),
//       currentIndex: index,
//       onTap: onTabTapped,
//       selectedItemColor: Colors.blue,
//       unselectedItemColor: Colors.white,
//       items: const [
//         BottomNavigationBarItem(
//           icon: Icon(Icons.person_outlined),
//           activeIcon: Icon(Icons.person),
//           label: 'Profile',
//           backgroundColor: const Color(0xFF040E3B),
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.align_vertical_bottom_outlined),
//           activeIcon: Icon(Icons.align_vertical_bottom),
//           label: 'Statistic',
//           backgroundColor: const Color(0xFF040E3B),
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.access_alarm_outlined),
//           activeIcon: Icon(Icons.access_alarm),
//           label: 'Alarm',
//           backgroundColor: const Color(0xFF040E3B),
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.dashboard_customize_outlined),
//           activeIcon: Icon(Icons.dashboard_customize),
//           label: 'Dashboard',
//           backgroundColor: Color(0xFF040E3B),
//         ),
//       ],
//     );
// return BottomNavigationBar(
//   backgroundColor: const Color(0xFF040E3B),
//   showSelectedLabels: true,
//   showUnselectedLabels: true,
//   currentIndex: index,

//   selectedItemColor: Colors.blue, // لون العنصر المحدد

//   unselectedItemColor: Colors.white, // لون النص والايقونة الغير محددة
//   type: BottomNavigationBarType.fixed,
//   items: const [
//     BottomNavigationBarItem(
//       icon: Icon(Icons.person_outlined, color: Colors.white),
//       activeIcon: Icon(Icons.person, color: Colors.blue),
//       label: 'Profile',
//     ),
//     BottomNavigationBarItem(
//       icon: Icon(Icons.align_vertical_bottom_outlined, color: Colors.white),
//       activeIcon: Icon(Icons.align_vertical_bottom, color: Colors.blue),
//       label: 'Statistic',
//     ),
//     BottomNavigationBarItem(
//       icon: Icon(Icons.access_alarm_outlined, color: Colors.white),
//       activeIcon: Icon(Icons.access_alarm, color: Colors.blue),
//       label: 'Alarm',
//     ),
//     BottomNavigationBarItem(
//       icon: Icon(Icons.dashboard_customize_outlined, color: Colors.white),
//       activeIcon: Icon(Icons.dashboard_customize, color: Colors.blue),
//       label: 'Dashboard',
//     ),
//   ],
//   onTap: onTabTapped,
//   //  => setState(() => this.index = index),
// );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sleepwell/screens/alarm_screen.dart';
import 'package:sleepwell/screens/dashboard_screen.dart';
import 'package:sleepwell/screens/profile_screen.dart';
import 'package:sleepwell/screens/statistic/statistic_sleepwell_screen.dart';

class CustomBottomBar extends StatefulWidget {
  const CustomBottomBar({Key? key}) : super(key: key);

  @override
  _CustomBottomBarState createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  int index = 2; // يبدأ عند "Alarm" كالشاشة الافتراضية

  void onTabTapped(int currentIndexselected) {
    setState(() {
      index = currentIndexselected;
    });

    if (index == 0) {
      Get.offAll(() => const ProfileScreen());
      // (index) => setState(() => this.index = index);
    } else if (index == 1) {
      Get.offAll(() => const StatisticSleepWellScreen());
      // (index) => setState(() => this.index = index);
    } else if (index == 2) {
      Get.offAll(() => AlarmScreen());
      // (index) => setState(() => this.index = index);
    } else if (index == 3) {
      Get.offAll(() => DashboardScreen());
      // (index) => setState(() => this.index = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF040E3B),
      currentIndex: index,
      onTap: onTabTapped,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.white,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outlined),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
          backgroundColor: const Color(0xFF040E3B),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.align_vertical_bottom_outlined),
          activeIcon: Icon(Icons.align_vertical_bottom),
          label: 'Statistic',
          backgroundColor: const Color(0xFF040E3B),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.access_alarm_outlined),
          activeIcon: Icon(Icons.access_alarm),
          label: 'Alarm',
          backgroundColor: const Color(0xFF040E3B),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_customize_outlined),
          activeIcon: Icon(Icons.dashboard_customize),
          label: 'Dashboard',
          backgroundColor: Color(0xFF040E3B),
        ),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:sleepwell/screens/alarm_screen.dart';
// import 'package:sleepwell/screens/dashboard_screen.dart';
// import 'package:sleepwell/screens/profile_screen.dart';
// import 'package:sleepwell/screens/statistic/statistic_sleepwell_screen.dart';

// class CustomBottomBar extends StatefulWidget {
//   const CustomBottomBar({Key? key}) : super(key: key);

//   @override
//   _CustomBottomBarState createState() => _CustomBottomBarState();
// }

// class _CustomBottomBarState extends State<CustomBottomBar> {
//   int index = 2; // يبدأ عند "Alarm" كالشاشة الافتراضية

//   final List<Widget> _screens = [
//     const ProfileScreen(),
//     const StatisticSleepWellScreen(),
//     AlarmScreen(),
//     DashboardScreen(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(
//         index: index,
//         children: _screens,
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: const Color(0xFF040E3B),
//         currentIndex: index,
//         onTap: (currentIndex) {
//           setState(() {
//             index = currentIndex;
//           });
//         },
//         selectedItemColor: Colors.blue,
//         unselectedItemColor: Colors.white,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person_outlined),
//             activeIcon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.align_vertical_bottom_outlined),
//             activeIcon: Icon(Icons.align_vertical_bottom),
//             label: 'Statistic',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.access_alarm_outlined),
//             activeIcon: Icon(Icons.access_alarm),
//             label: 'Alarm',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.dashboard_customize_outlined),
//             activeIcon: Icon(Icons.dashboard_customize),
//             label: 'Dashboard',
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:sleepwell/screens/alarm_screen.dart';
// import '../screens/dashboard_screen.dart';
// import '../screens/profile_screen.dart';
// import '../screens/statistic/statistic_sleepwell_screen.dart';

// class CustomBottomBar extends StatefulWidget {
//   @override
//   _CustomBottomBarState createState() => _CustomBottomBarState();
// }

// class _CustomBottomBarState extends State<CustomBottomBar> {
//   int index = 2; // يبدأ عند "Alarm" كالشاشة الافتراضية

//   final List<Widget> _screens = [
//     const ProfileScreen(),
//     const StatisticSleepWellScreen(),
//     AlarmScreen(),
//     DashboardScreen(),
//   ];

//   void onTabTapped(int currentIndexselected) {
//     setState(() {
//       index = currentIndexselected;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           child: _screens[index], // عرض الشاشة المحددة
//         ),
//         BottomNavigationBar(
//           backgroundColor: const Color(0xFF040E3B),
//           showSelectedLabels: true,
//           showUnselectedLabels: true,
//           currentIndex: index, // يحدد العنصر الذي يجب تمييزه
//           type: BottomNavigationBarType.fixed,
//           selectedItemColor: Colors.blue, // لون العنصر المحدد
//           unselectedItemColor: Colors.white, // لون العناصر غير المحددة
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.person_outlined),
//               activeIcon: Icon(Icons.person),
//               label: 'Profile',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.align_vertical_bottom_outlined),
//               activeIcon: Icon(Icons.align_vertical_bottom),
//               label: 'Statistic',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.access_alarm_outlined),
//               activeIcon: Icon(Icons.access_alarm),
//               label: 'Alarm',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.dashboard_customize_outlined),
//               activeIcon: Icon(Icons.dashboard_customize),
//               label: 'Dashboard',
//             ),
//           ],
//           onTap: onTabTapped, // استدعاء عند النقر لتغيير الشاشة
//         ),
//       ],
//     );
//   }
// }
