import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sleepwell/screens/alarm_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/statistic/statistic_sleepwell_screen.dart';

class CustomBottomBar extends StatefulWidget {
  @override
  _CustomBottomBarState createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  int index = 2;

  void onTabTapped(int currentIndexselected) {
    setState(() {
      index = currentIndexselected;
    });

    if (index == 0) {
      Get.off(() => const ProfileScreen());
      // (index) => setState(() => this.index = index);
    } else if (index == 1) {
      Get.off(() => const StatisticSleepWellScreen());
      // (index) => setState(() => this.index = index);
    } else if (index == 2) {
      Get.off(() => AlarmScreen());
      // (index) => setState(() => this.index = index);
    } else if (index == 3) {
      Get.off(() => DashboardScreen());
      // (index) => setState(() => this.index = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF040E3B),
      showSelectedLabels: true,
      showUnselectedLabels: false,
      currentIndex: index,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue, // لون العنصر المحدد
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outlined, color: Colors.white),
          activeIcon: Icon(Icons.person, color: Colors.blue),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.align_vertical_bottom_outlined, color: Colors.white),
          activeIcon: Icon(Icons.align_vertical_bottom, color: Colors.blue),
          label: 'Statistic',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.access_alarm_outlined, color: Colors.white),
          activeIcon: Icon(Icons.access_alarm, color: Colors.blue),
          label: 'Alarm',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_customize_outlined, color: Colors.white),
          activeIcon: Icon(Icons.dashboard_customize, color: Colors.blue),
          label: 'Dashboard',
        ),
      ],
      onTap: onTabTapped,
      //  => setState(() => this.index = index),
    );
  }
}
