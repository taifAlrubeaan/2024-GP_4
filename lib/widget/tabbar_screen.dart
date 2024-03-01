import 'package:flutter/material.dart';
import 'package:sleepwell/screens/signin_screen.dart';
import 'package:sleepwell/screens/signup_screen.dart';


class TabBarApp extends StatelessWidget {
  const TabBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const TabBarExample(),
    );
  }
}

class TabBarExample extends StatelessWidget {
  static String RouteScreen ='tabbar_screen';
  const TabBarExample({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 4, 19, 102),
          title: const Text(''),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.login , color: Colors.white),
              ),
              Tab(
                icon: Icon(Icons.app_registration , color: Colors.white),
              ),
            ],
            
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            SignInScreen(),
            SignUpScreen(),
          ],
        ),
      ),
    );
  }
}

//not used anymore 