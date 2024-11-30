import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  /// Get the current user's ID
  String? getUserId() {
    log("getting user id");
    return currentUser?.uid;
  }

  /// Set the user ID if the user is already logged in or upon login/signup
  Future<void> setUserId() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if the user is already logged in
    final bool loginStatus = prefs.getBool("isLogin") ?? false;

    if (loginStatus) {
      // If already logged in, set the user ID
      final userId = getUserId();
      if (userId != null) {
        await prefs.setString("userId", userId);
        print("User ID set in SharedPreferences: $userId");
      } else {
        print("No logged-in user found.");
      }
    } else {
      // When logging in or creating an account
      _firebaseAuth.authStateChanges().listen((user) async {
        if (user != null) {
          // Set the user ID in SharedPreferences
          await prefs.setString("userId", user.uid);
          await prefs.setBool("isLogin", true);
          print("User ID saved on login/signup: ${user.uid}");
        } else {
          print("User not logged in yet.");
        }
      });
    }
  }
}
