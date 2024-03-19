import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sleepwell/screens/home_screen.dart';
import 'package:sleepwell/screens/signup_screen.dart';
import 'package:sleepwell/widget/regsterbutton.dart';

class SignInScreen extends StatefulWidget {
  static String RouteScreen = 'signin_screen';
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
    Color myColor = Color.fromARGB(255, 0, 74, 173);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: myColor,
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
            padding: EdgeInsets.all(20),
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
                    'Welcome  back!',
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
                  color: Color(0xffd5defe),
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
                        Navigator.pushNamed(context, MyHomePage.RouteScreen);
                        setState(() {
                          showSpinner = false;
                        });
                      }
                    } catch (e) {
                      print(e);
                      setState(() {
                        showSpinner = false;
                      });
                      String errorMessage = 'An error occurred! Please try again.';
                      if (e is FirebaseAuthException) {
                        switch (e.code) {
                          case 'user-not-found':
                            errorMessage = 'User not found! Please check your email and try again.';
                            break;
                          case 'wrong-password':
                            errorMessage = 'Incorrect password! Please try again.';
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpScreen()),
                        );
                      },
                      child: const Text(
                        'SignUp',
                        style: TextStyle(
                          color: Color.fromARGB(241, 230, 158, 3),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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