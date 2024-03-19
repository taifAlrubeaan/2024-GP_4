import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:sleepwell/screens/signin_screen.dart';
import 'package:sleepwell/widget/iconwidget.dart';

class ProfileScreen extends StatefulWidget {
  static const String RouteScreen = 'profile_screen';

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth=FirebaseAuth.instance;
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(15, 220, 201, 201),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            SettingsGroup(
              title: 'Personal',
              children: <Widget>[
                // Add your personal settings widgets here
                 Account() ,
                 AboutYou(),
                 
              ],
            ),
            SettingsGroup(
              title: 'Alarm',
              children: <Widget>[
                // Add your alarm settings widgets here
                AlarmSound(),
                Snooze(),
              ],
            ),
            SettingsGroup(
              title: 'Setting',
              children: <Widget>[
                // Add your general settings widgets here
                Sleepgoal(),
              ],
            ),
            SettingsGroup(
              title: 'Other',
              children:  <Widget>[
                buildLogOut(),
              ],
            ),
          ],
        ),
      ),
    );
  }

 Widget buildLogOut() => SimpleSettingsTile(
  title: 'Sign Out',
  leading: IconWidget(icon: Icons.logout, color: const Color.fromARGB(241, 230, 158, 3)),
  onTap: () {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:const Text( 
                    'Confirm Sign Out',
                    style: TextStyle(
                     color: Color.fromARGB(255, 152, 15, 5),
                     fontSize: 24,
                     fontWeight: FontWeight.bold
                      ),),
          content:const Text( 
                    'Are you sure you want to sign out?',
                    style: TextStyle(
                     color: Colors.black,
                     fontSize: 18,
                      ),),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Sign Out'),
              onPressed: () {
                _auth.signOut();
                Navigator.pushNamed(context, SignInScreen.RouteScreen);
              },
            ),
          ],
        );
      },
    );
  },
);

      Widget Account() => SimpleSettingsTile(
        title: 'Account',
        leading: IconWidget(icon: Icons.person, color: const Color(0xFF040E3B)),
        onTap: () {
          // Handle sign out logic here
        },
        
      );

      Widget AboutYou() => SimpleSettingsTile(
        title: 'About you',
        leading: IconWidget(icon: Icons.assessment_outlined, color: const Color(0xFF040E3B)),
        onTap: () {
          // Handle sign out logic here
        },
      );
      Widget AlarmSound() => SimpleSettingsTile(
        title: 'Alarm sound',
        leading: IconWidget(icon: Icons.music_note_outlined, color: const Color(0xFF040E3B)),
        onTap: () {
          // Handle sign out logic here
        },
      );
      Widget Snooze() => SimpleSettingsTile(
        title: 'Snooze',
        leading: IconWidget(icon: Icons.snooze ,color: const Color(0xFF040E3B)),
        onTap: () {
          // Handle sign out logic here
        },
      );

       Widget Sleepgoal() => SimpleSettingsTile(
        title: 'Sleep Goal',
        leading: IconWidget(icon: Icons.location_searching_sharp, color: const Color(0xFF040E3B)),
        onTap: () {
          // Handle sign out logic here
        },
      );
}
