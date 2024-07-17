import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widget/custom_bottom_bar.dart';
import 'alarm/alarm_setup_screen.dart';
import 'feedback/feedback_page.dart';

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
      bottomNavigationBar: CustomBottomBar(),
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
        child: Center(
          // child: Text(
          //   'Dashboard Screen',
          //   style: TextStyle(
          //     color: Colors.white,
          //   ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Get.to(const FeedbackPage());
                    },
                    child: const Text(
                      "GoTo Feedback",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     ElevatedButton(
              //       onPressed: () {
              //         Get.to(GetFeedBackSleepWellQualityScreen());
              //       },
              //       child: const Text('GetFeedBack SleepWell Quality Screen'),
              //     ),
              //   ],
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     ElevatedButton(
              //       onPressed: () {
              //         Get.to(ScheduleNotificationPage());
              //       },
              //       child: const Text('Schedule Notification'),
              //     ),
              //   ],
              // ),

              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     ElevatedButton(
              //       onPressed: () {
              // Get.to(const Prediction());
              //       },
              //       child: const Text('Prediction'),
              //     ),
              //   ],
              // ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Get.to(AlarmSetupScreen());
                    },
                    child: const Text('AlarmSetupScreen'),
                  ),
                ],
              ),
            ],
          ),
        ),

        // child: FloatingActionButton(
        //   onPressed: () {
        //     Get.off(const FeedbackPage());
        //   },
        //   child: const Icon(Icons.add),
        // ),
      ),
    );
  }
}
