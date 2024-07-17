import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sleepwell/signup/question.dart';
import 'package:sleepwell/widget/regsterbutton.dart';
import 'package:get/get.dart';
class SignUpScreen extends StatefulWidget {
  static String RouteScreen = 'signup_screen';
  const SignUpScreen({
    super.key,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
// why late because i well not give  it a value new
  late String name;
  late String Lname;
  late String email;
  late String password;
  late String cpassword;
  late String age;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 74, 173),
        title: const Text(''),
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
                  height: 15,
                ),
                const Center(
                  child: Text(
                    'Let’s create your account!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  '  Names should be in English ',
                  style: TextStyle(
                      color: Color.fromARGB(241, 230, 158, 3),
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  keyboardType: TextInputType.name,
                  onChanged: (value) {
                    // here i save the  value of name from user
                    name = value;
                  },
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    suffixIcon: const Icon(Icons.person),
                    hintText: ' First Name ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                  keyboardType: TextInputType.name,
                  onChanged: (value) {
                    // here i save the  value of name from user
                    Lname = value;
                  },
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    suffixIcon: const Icon(Icons.person),
                    hintText: ' Last Name ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                  keyboardType: TextInputType.name,
                  onChanged: (value) {
                    // here i save the  value of age from user
                    age = value;
                  },
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    suffixIcon: const Icon(Icons.date_range),
                    hintText: ' your Age ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
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
                    hintText: 'Email Address',
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
                    // here i save the  value of password from user
                    password = value;
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    suffixIcon: const Icon(Icons.key),
                    hintText: 'Password',
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
                    // here i save the  value of cpassword from user
                    cpassword = value;
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    suffixIcon: const Icon(Icons.key),
                    hintText: 'Confirm Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  '- Password should be Identical.',
                  style: TextStyle(
                      color: Color.fromARGB(241, 230, 158, 3),
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
                const Text(
                  '- At least 8 characters long.',
                  style: TextStyle(
                      color: Color.fromARGB(241, 230, 158, 3),
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
                const Text(
                  '- Password should contain numbers & characters.',
                  style: TextStyle(
                      color: Color.fromARGB(241, 230, 158, 3),
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                regsterbutton(
                  color: const Color(0xffd5defe),
                  title: 'Create Account',
                  onPressed: () async {
                    if (password.length >= 8 &&
                        password.contains(RegExp(r'[a-zA-Z]')) &&
                        password.contains(RegExp(r'[0-9]')) &&
                        password == cpassword) {
                      try {
                        setState(() {
                          showSpinner = true;
                        });
                        final newUser =
                            await _auth.createUserWithEmailAndPassword(
                                email: email, password: password);
                        if (newUser != null) {
                          final userId = newUser.user
                              ?.uid; // Access the UID of the newly created user
                          await _firestore.collection('Users').doc(userId).set({
                            'UserId': userId,
                            'Email': email,
                            'Fname': name,
                            'Lname': Lname,
                            'Age': age,
                            'Password': password,
                          });

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Great job!'),
                                titleTextStyle: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                content: const Text(
                                    'Your are almost there! Just a few more steps and you will be completely signed up with us.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      // Navigator.of(context).pop();
                                      Get.back();
                                      // Navigator.pushNamed(
                                      //   context,
                                      //   QuestionScreen.RouteScreen,
                                      // );
                                       Get.offAll(QuestionScreen());
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                        setState(() {
                          showSpinner = false;
                        });
                      } catch (e) {
                        setState(() {
                          showSpinner = false;
                        });
                        String errorMessage = '';
                        if (e is FirebaseAuthException) {
                          if (e.code == 'weak-password') {
                            errorMessage = 'Cause: Password is too weak.';
                          } else if (e.code == 'email-already-in-use') {
                            errorMessage = ' Email is already in use.';
                          } else {
                            errorMessage = ' Emil format not correct';
                          }
                        } else {
                          errorMessage =
                              ' An error occurred. Please try again later.';
                        }
                        print('Sign-up error: $errorMessage');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMessage),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Something went wrong with the password ! Make sure the conditions are met.',
                          ),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
