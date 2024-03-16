import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sleepwell/screens/alarm_screen.dart';
import 'package:sleepwell/screens/profile_screen.dart';

class MyHomePage extends StatefulWidget {
   static String RouteScreen ='home_screen';
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _auth= FirebaseAuth.instance;
late User signInUser ;
 
 @override
  void initState() {
    super.initState();
    getCurrentUser();
  }
  void getCurrentUser(){
    // check is the user sign up or not ? 
   try {
    final user =_auth.currentUser;
   // if rutern 0 no user found if not will rutern the email and the password
   if (user !=null){
    signInUser= user;
    // should be deleted now just for testing
    print(signInUser.email);
   } 
   } catch (e) {
     print(e);
   }
  }
  int index =2;
  final pages =[
    ProfileScreen(),
    const Center(child: Text('Hello  statistic  ')),
    AlarmScreen(),
    const Center(child: Text('Hello Dashboard')),
  ];
  
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 162, 165, 180),
          title: Text(''),
        ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (index) => setState(()=> this.index = index) ,
        backgroundColor: Color.fromARGB(255, 162, 165, 180),
        height: 70,
        destinations: const [
          NavigationDestination(
            icon:Icon( Icons.person_outlined ),
            selectedIcon:Icon( Icons.person ), 
            label:'profile',
            ),
             NavigationDestination(
            icon:Icon( Icons.align_vertical_bottom_outlined ),
            selectedIcon:Icon( Icons.align_vertical_bottom ), 
            label:'Statistic',
            ),
             NavigationDestination(
            icon:Icon( Icons.access_alarm_outlined ),
            selectedIcon:Icon( Icons.access_alarm ), 
            label:'Alarm',
            ),
             NavigationDestination(
            icon:Icon( Icons.dashboard_customize_outlined ),
            selectedIcon:Icon( Icons.dashboard_customize ), 
            label:'Dashboard',
            ),
        ],
      ),
     
     body:pages[index],
    
   
      );
  } 
}
