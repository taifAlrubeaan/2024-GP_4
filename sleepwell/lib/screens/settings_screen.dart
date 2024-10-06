import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleepwell/main.dart';
import 'package:sleepwell/screens/account_screen.dart';
import 'package:sleepwell/screens/auth/signin_screen.dart';
import 'package:sleepwell/screens/feedback/feedbacke_notification_screen.dart';
import 'package:sleepwell/screens/settings/language_screen.dart';
import 'package:sleepwell/widget/counter_widget.dart';
import '../widget/bed_time_reminder.dart';
import 'edite_alarm_screen.dart';
import 'profile/about_you_screen.dart';
import 'profile/more_about_you.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  RxBool isDarkMode = false.obs;
  final _auth = FirebaseAuth.instance;
  late User signInUser;
  late String userId;
  late String email;
  late String firstName;
  late String lastName;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    firstName = '';
    lastName = '';
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
        // تخزين userId في SharedPreferences
        await saveUserIdToPrefs(userId);
        _fetchUserData();
      }
    } catch (e) {
      print(e);
    }
  }

// دالة لتخزين userId في SharedPreferences
  Future<void> saveUserIdToPrefs(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

// دالة لاسترجاع userId من SharedPreferences
  Future<String?> getUserIdFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  void _fetchUserData() async {
    try {
      final userData = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();
      if (userData.exists) {
        final data = userData.data() as Map<String, dynamic>;
        setState(() {
          firstName = data['Fname'] ?? '';
          lastName = data['Lname'] ?? '';
        });
      } else {
        print('User data does not exist');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  // LocaleThemeController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    // isDarkMode.value = controller.themeMode.value == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF004AAD),
        elevation: 50,
        title: Text(
          'Profile'.tr,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF004AAD), Color(0xFF040E3B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(userId)
                    .get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Show a loading indicator while fetching data
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    // Handle error state
                    return Text('Error: ${snapshot.error}');
                  } else {
                    // Data has been fetched successfully
                    final userData =
                        snapshot.data?.data() as Map<String, dynamic>?;
                    if (userData != null) {
                      firstName = userData['Fname'] ?? '';
                      lastName = userData['Lname'] ?? '';
                    }

                    return Column(
                      children: [
                        Text(
                          'Hi $firstName!'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(color: Color.fromRGBO(9, 238, 13, 1)),
                        const SizedBox(
                          height: 25,
                        ),
                        // /////////////////////
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PERSONAL'.tr,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 92, 221, 169),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ListTile(
                                title: Text(
                                  'Account'.tr,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 22),
                                ),
                                leading: const Icon(Icons.person,
                                    color: Colors.white),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    color: Colors.white, size: 18),
                                onTap: () => {
                                      Get.to(const AccountScreen()),
                                    }),
                            ListTile(
                                leading: const Icon(Icons.assessment_outlined,
                                    color: Colors.white),
                                title: Text('About You'.tr,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 18)),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    color: Colors.white, size: 18),
                                onTap: () {
                                  Get.to(AboutYouPage());
                                }),
                            ListTile(
                              leading: const Icon(Icons.question_answer,
                                  color: Colors.white),
                              title: Text(
                                'More About You'.tr,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios,
                                  color: Colors.white, size: 18),
                              onTap: () {
                                Get.to(MoreAboutYouScreen());
                              },
                            ),

                            // const Divider(color: Color.fromRGBO(9, 238, 13, 1)),
                            // const Text(
                            //   'SETTINGS',
                            //   style: TextStyle(
                            //     fontSize: 22,
                            //     fontWeight: FontWeight.bold,
                            //     color: Color.fromARGB(255, 92, 221, 169),
                            //   ),
                            // ),
                            // const SizedBox(height: 10),
                            ListTile(
                              title: Text('Notification'.tr,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 18)),
                              leading: const Icon(Icons.notifications,
                                  color: Colors.white),
                              trailing: const Icon(Icons.arrow_forward_ios,
                                  color: Colors.white, size: 18),
                              onTap: () => Get.to(
                                  () => const FeedbackeNotificationsScreen()),
                            ),

                            const Divider(color: Color.fromRGBO(9, 238, 13, 1)),
                            Text(
                              'SETTINGS'.tr,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 92, 221, 169),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ListTile(
                                title: Text('Language'.tr,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 18)),
                                leading: const Icon(Icons.language,
                                    color: Colors.white),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    color: Colors.white, size: 18),
                                onTap: () {
                                  Get.to(const LangageScreen());
                                }
                                // => Get.to(() => NotificationScreen()),
                                ),
                            ListTile(
                                title: Text('Sensor Connection'.tr,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 18)),
                                leading:
                                    const Icon(Icons.usb, color: Colors.white),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    color: Colors.white, size: 18),
                                onTap: () {}
                                // => Get.to(() => NotificationScreen()),
                                ),
                            ListTile(
                                title: Text('Sleep Goal'.tr,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 18)),
                                leading: const Icon(
                                    Icons.location_searching_sharp,
                                    color: Colors.white),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    color: Colors.white, size: 18),
                                onTap: () {}
                                // => Get.to(() => NotificationScreen()),
                                ),
                            ListTile(
                                title: Text('Edit Alarm'.tr,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 18)),
                                leading:
                                    const Icon(Icons.edit, color: Colors.white),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    color: Colors.white, size: 18),
                                onTap: () {
                                  Get.to(() => const EditAlarmScreen());
                                }),
                            ListTile(
                                title: Text(
                                  'Snooze'.tr,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                                leading: const Icon(Icons.snooze,
                                    color: Colors.white),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    color: Colors.white, size: 18),
                                onTap: () {
                                  Get.dialog(const Dialog(
                                    child: CounterWidget(),
                                  ));
                                }),
                            ListTile(
                                title: Text(
                                  'BedTime'.tr,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                                leading: const Icon(Icons.bedtime,
                                    color: Colors.white),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    color: Colors.white, size: 18),
                                onTap: () {
                                  Get.dialog(const Dialog(
                                    child: BedTimeReminder(),
                                  ));
                                }),

                            const Divider(color: Color.fromRGBO(9, 238, 13, 1)),

                            const SizedBox(height: 20),

                            // Obx(
                            //   () => SwitchListTile(
                            //     title: Text('Dark Mode'.tr,
                            //         style: const TextStyle(color: Colors.white, fontSize: 18)),
                            //     value: isDarkMode.value,
                            //     onChanged: (value) {
                            //       isDarkMode.value = value;
                            //       // controller.saveUserThemeModeToCashe(
                            //       // value ? ThemeMode.dark : ThemeMode.light);
                            //     },
                            //   ),
                            // ),

                            Text(
                              'Account Actions'.tr,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 92, 221, 169),
                              ),
                            ),
                            // const SizedBox(height: 10),
                            ListTile(
                              title: Text('Logout'.tr,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 18)),
                              leading: Transform(
                                alignment: Alignment.center,
                                transform:
                                    Matrix4.rotationY(3.14), // معكوس لليسار
                                child: const Icon(Icons.logout,
                                    color: Colors.white),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios,
                                  color: Colors.white, size: 18),

                              //  trailing: const Icon(Icons.logout, color: Colors.white, size: 18),
                              onTap: () {
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.warning,
                                  animType: AnimType.bottomSlide,
                                  title: 'Confirm Sign Out',
                                  desc: 'Are you sure you want to sign out?',
                                  btnCancelText: "Cancel",
                                  btnOkText: "Sign Out",
                                  btnCancelOnPress: () {
                                    // Action when 'Cancel' is pressed
                                  },
                                  btnOkOnPress: () {
                                    _auth.signOut();
                                    prefs.setBool("isLogin", false);
                                    Get.offAll(() => const SignInScreen());
                                  },
                                ).show();
                              },
                            ),
                          ],
                        )
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLogOut() => ListTile(
        title: const Text(
          'Sign Out',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const Icon(
          Icons.logout,
          color: Color.fromARGB(241, 230, 158, 3),
        ),
        onTap: () {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.warning,
            animType: AnimType.bottomSlide,
            title: 'Confirm Sign Out',
            desc: 'Are you sure you want to sign out?',
            btnCancelText: "Cancel",
            btnOkText: "Sign Out",
            btnCancelOnPress: () {
              // Action when 'Cancel' is pressed
            },
            btnOkOnPress: () {
              _auth.signOut();
              prefs.setBool("isLogin", false);
              Get.offAll(() => const SignInScreen());
            },
          ).show();
        },
      );
}
