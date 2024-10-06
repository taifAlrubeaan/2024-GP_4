import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleepwell/main.dart';
import 'package:sleepwell/screens/auth/reset_password_screen.dart';
import 'package:sleepwell/screens/auth/signup_screen.dart';
import 'package:sleepwell/screens/home_screen.dart';
import 'package:sleepwell/widget/regsterbutton.dart';
import '../../controllers/auth/auth_service.dart';
import '../../locale/local_controller.dart';
import '../../widget/choice_chip_widget.dart';
import '../../widget/square_tile.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  late String email;
  late String password;

  final FirebaseAuth auth = FirebaseAuth.instance;
  String? userid;

  void getCurrentUser() async {
    try {
      final user = auth.currentUser;
      if (user != null) {
        setState(() {
          userid = user.uid; // تهيئة userid
        });
        // قم بتخزين الـ userid في SharedPreferences
        await storeUserIdInSharedPreferences(userid!);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

// دالة لتخزين الـ userid في SharedPreferences
  Future<void> storeUserIdInSharedPreferences(String userid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userid', userid);
    print('User ID stored in SharedPreferences: $userid');
  }

  // دالة لاسترجاع الـ userid من SharedPreferences
  Future<String?> getUserIdFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userid');
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    Color myColor = const Color.fromARGB(255, 0, 74, 173);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: myColor,
        title: const Text(''),
        automaticallyImplyLeading: false, // This removes the arrow
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PopupMenuButton<int>(
              icon: const Icon(
                Icons.language,
                color: Colors.white,
              ),
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<int>(
                    // value: 1,
                    child: ChoiceChipWidget(
                      choices: ["Arabic".tr, "English".tr],
                      initialSelected: Get.locale?.languageCode == 'en' ? 1 : 0,
                      changeSelected: (selectedValue) {
                        print(":::::::::::::::::::::$selectedValue");
                        final AppLocalelcontroller locallcontroller =
                            Get.find();
                        Get.back();
                        if (selectedValue == 0 &&
                            locallcontroller.language.languageCode == 'en') {
                          locallcontroller.changeLanguage('ar');
                        } else if (selectedValue == 1 &&
                            locallcontroller.language.languageCode == 'ar') {
                          locallcontroller.changeLanguage('en');
                        }
                      },
                    ),
                  ),
                ];
              },
            ),
          ),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF004AAD), Color(0xFF040E3B)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              shrinkWrap: true,
              children: [
                const SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: Image(
                    image: AssetImage('assets/logo2.png'),
                  ),
                ),
                Center(
                  child: Text(
                    'Welcome back!'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'start exploring our platform today!'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    // هنا يتم حفظ قيمة البريد الإلكتروني من المستخدم
                    email = value;
                  },
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    suffixIcon: const Icon(Icons.email),
                    hintText: 'Email'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                  keyboardType: TextInputType.visiblePassword,
                  onChanged: (value) {
                    // هنا يتم حفظ قيمة كلمة المرور من المستخدم
                    password = value;
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    suffixIcon: const Icon(
                      Icons.key,
                    ),
                    hintText: 'Password'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                regsterbutton(
                  color: const Color(0xffd5defe),
                  title: 'Sign In'.tr,
                  onPressed: () async {
                    setState(() {
                      showSpinner = true;
                    });
                    try {
                      final user = await _auth.signInWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      // الانتقال إلى الشاشة التالية بعد تسجيل الدخول بنجاح
                      Get.offAll(const HomeScreen());
                      prefs.setBool("isLogin", true);
                    } catch (e) {
                      String errorMessage = 'An error occurred';
                      if (e is FirebaseAuthException) {
                        switch (e.code) {
                          case 'user-not-found':
                            errorMessage =
                                'User not found! Please check your email and try again.';
                            break;
                          case 'wrong-password':
                            errorMessage =
                                'Incorrect password! Please try again.';
                            break;
                          case 'permission-denied':
                            errorMessage =
                                'You do not have permission to access this resource.';
                            break;
                          default:
                            errorMessage = e.message ?? errorMessage;
                            break;
                        }
                      } else {
                        errorMessage = e.toString();
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorMessage),
                        ),
                      );
                    } finally {
                      setState(() {
                        showSpinner = false;
                      });
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Get.to(() => ResetPasswordScreen());
                  },
                  child: Text(
                    'Forget Password?'.tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'New user ?'.tr,
                      style: const TextStyle(color: Colors.white, fontSize: 22),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.offAll(const SignUpScreen());
                      },
                      child: Text(
                        'Sign Up'.tr,
                        style: const TextStyle(
                          color: Color.fromARGB(240, 180, 168, 142),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 5),
                Text(
                  'Or sign in with Google'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // زر تسجيل الدخول باستخدام Google
                    SquareTile(
                      onTap: () async {
                        setState(() {
                          showSpinner = true;
                        });
                        try {
                          await AuthService().signInWithGoogle();
                          Get.offAll(const HomeScreen());
                        } catch (e) {
                          String errorMessage =
                              'An error occurred! Please try again.';
                          if (e is PlatformException) {
                            if (e.code == 'sign_in_failed') {
                              errorMessage =
                                  'Sign-in failed. Please check your Google account credentials.';
                            }
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                            ),
                          );
                        } finally {
                          setState(() {
                            showSpinner = false;
                          });
                        }
                      },
                      imagePath: 'assets/googleLogo.png',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
