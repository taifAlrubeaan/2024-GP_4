import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sleepwell/screens/alarm_screen.dart';
import 'package:sleepwell/screens/beneficiaries_screen.dart';

import 'package:sleepwell/screens/settings_screen.dart';
import 'package:sleepwell/screens/statistic/statistic_sleepwell_screen.dart';

class CustomBottomBar extends StatefulWidget {
  const CustomBottomBar({super.key});

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
      Get.offAll(() => SettingsScreen());
      // (index) => setState(() => this.index = index);
    } else if (index == 1) {
      Get.offAll(() => const StatisticSleepWellScreen());
      // (index) => setState(() => this.index = index);
    } else if (index == 2) {
      Get.offAll(() => AlarmScreen());
      // (index) => setState(() => this.index = index);
    } else if (index == 3) {
      Get.offAll(() => BeneficiariesScreen());
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
          backgroundColor: Color(0xFF040E3B),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.align_vertical_bottom_outlined),
          activeIcon: Icon(Icons.align_vertical_bottom),
          label: 'Statistic',
          backgroundColor: Color(0xFF040E3B),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.access_alarm_outlined),
          activeIcon: Icon(Icons.access_alarm),
          label: 'Alarm',
          backgroundColor: Color(0xFF040E3B),
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
