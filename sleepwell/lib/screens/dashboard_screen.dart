import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/get_navigation.dart';
import '../widget/custom_bottom_bar.dart';
import 'statistic/statistic_screen.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DashboardS',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF004AAD),
      ),
      // bottomNavigationBar: CustomBottomBar(),
      body: Container(
        height: MediaQuery.of(context).size.height,
        // padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF004AAD), Color(0xFF040E3B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
            // child: Text(
            //   'Dashboard Screen',
            //   style: TextStyle(
            //     color: Colors.white,
            //   ),

            // ),
            //   child: ElevatedButton(
            //       onPressed: () {
            //         Get.offAll(const StatisticScreen());
            //       },
            //       child: const Text("StatisticScreen")),
            // ),
            ),
      ),
    );
  }
}
