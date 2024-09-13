import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:sleepwell/push_notification_service.dart';
import '../widget/custom_bottom_bar.dart';
=======
import 'package:get/get.dart';
import 'package:get/get_navigation/get_navigation.dart';
import '../widget/custom_bottom_bar.dart';
import 'statistic/statistic_screen.dart';
>>>>>>> 57a32500fe48722d7f984497618ff113dac572fc

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
<<<<<<< HEAD
          child: Text(
            'Dashboard Screen',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
=======
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
>>>>>>> 57a32500fe48722d7f984497618ff113dac572fc
      ),
    );
  }
}
