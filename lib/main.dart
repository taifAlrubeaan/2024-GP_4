import 'package:flutter/material.dart';
import 'package:sleepwell/screens/home_screen.dart';
import 'package:sleepwell/screens/signin_screen.dart';
import 'package:sleepwell/screens/signup_screen.dart';
import 'package:sleepwell/screens/splash_screen.dart';
import 'package:sleepwell/widget/tabbar_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SleepWell',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
     initialRoute:SignInScreen.RouteScreen,
     routes:<String, WidgetBuilder>{
      SignInScreen.RouteScreen : (context)=> const SignInScreen(),
      MyHomePage.RouteScreen : (context)=> const MyHomePage(),
      SignUpScreen.RouteScreen : (context)=> const SignUpScreen(),
      SplashScreen.RouteScreen : (context)=> const SplashScreen(),
      TabBarExample.RouteScreen : (context)=> const TabBarExample(),

     
     },
    );
  }
}

