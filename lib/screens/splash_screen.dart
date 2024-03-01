import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sleepwell/screens/signin_screen.dart';

class SplashScreen extends StatefulWidget {
  static String RouteScreen ='splash_screen';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Call the _navigateToSignInScreen() function after a delay of 2 seconds
    Future.delayed(const Duration(seconds: 2), _navigateToSignInScreen);
  }

  void _navigateToSignInScreen() {
    // Navigate to the SignInScreen()
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF004AAD), Color(0xFF040E3B)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          const Center(
            child: SpinKitFadingCircle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}