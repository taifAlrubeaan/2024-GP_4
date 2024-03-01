import 'package:flutter/material.dart';

class MyHomePage extends StatelessWidget {
   static String RouteScreen ='home_screen';
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Flutter Demo Home Page')),
     
      );
  } 
}
