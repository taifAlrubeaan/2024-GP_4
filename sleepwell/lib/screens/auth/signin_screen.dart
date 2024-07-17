import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sleepwell/main.dart';
import 'package:sleepwell/screens/auth/signup_screen.dart';
import 'package:sleepwell/widget/regsterbutton.dart';
import '../../controllers/auth/auth_service.dart';
import '../../widget/square_tile.dart';
import '../alarm_screen.dart';

//import 'package:sleepwell/services/auth_service.dart';
// import 'package:flutter/services.dart';
//import 'package:sleepwell/widget/square_tile.dart';

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

  @override
  Widget build(BuildContext context) {
    Color myColor = const Color.fromARGB(255, 0, 74, 173);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: myColor,
        title: const Text(''),
        automaticallyImplyLeading: false, // This removes the arrow
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
                const Center(
                  child: Text(
                    'Welcome back!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    '  start exploring our platform today!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    // here i save the  value of email from user
                    email = value;
                  },
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    suffixIcon: const Icon(Icons.email),
                    hintText: 'Email',
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
                    // here i save the  value of pssword from user
                    password = value;
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    suffixIcon: const Icon(
                      Icons.key,
                    ),
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                regsterbutton(
                  color: const Color(0xffd5defe),
                  title: 'Sign In',
                  onPressed: () async {
                    setState(() {
                      showSpinner = true;
                    });
                    try {
                      final user = await _auth.signInWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      if (user != null) {
                        // Navigator.pushNamed(context, MyHomePage.RouteScreen);
                        Get.offAll(AlarmScreen());
                        setState(() {
                          showSpinner = false;
                        });
                        prefs.setBool("isLogin", true);
                      }
                    } catch (e) {
                      setState(() {
                        showSpinner = false;
                      });
                      String errorMessage = 'Email format not correct';
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
                          // Add more cases for specific error codes if needed
                        }
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorMessage),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'New user ?  ',
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => SignUpScreen()),
                        // );
                        Get.offAll(const SignUpScreen());
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Color.fromARGB(241, 230, 158, 3),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(),
                SizedBox(height: 10),
                Text(
                  'Or sign in with Google',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    //fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //google button
                    SquareTile(
                      onTap: () async {
                        setState(() {
                          showSpinner = true;
                        });
                        try {
                          await AuthServise().signInWithGoogle();
                          Get.offAll(AlarmScreen());
                          setState(() {
                            showSpinner = false;
                          });
                        } catch (e) {
                          setState(() {
                            showSpinner = false;
                          });
                          print('Error occurred: $e');
                          String errorMessage =
                              'An error occurred! Please try again.';
                          if (e is PlatformException) {
                            if (e.code == 'sign_in_failed') {
                              errorMessage =
                                  'Sign-in failed. Please check your Google account credentials.';
                            }
                            // Add more specific error handling for other possible error codes if needed
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                            ),
                          );
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
