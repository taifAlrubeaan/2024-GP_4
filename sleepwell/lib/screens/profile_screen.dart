import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class ProfileScreen extends StatefulWidget {
  static String RouteScreen ='profile_screen';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _profileScreenState();
}

class _profileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SafeArea(
        child: ListView(
        padding: EdgeInsets.all(24),
        children: [
         SettingsGroup(
          title: 'Setting',
           children: const <Widget>[

           ],
           ),
        ],
      ),
      ),
    );
  }
}