import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/user_model.dart';

class SignUpService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> createUser(String email, String password, String firstName,
      String lastName, String age) async {
    try {
      final newUser = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final userId = newUser.user?.uid;
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (userId == null) return null;

      final user = UserModel(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        age: age,
        fcmToken: fcmToken!,
      );

      await _firestore.collection('Users').doc(userId).set(user.toMap());
      return user;
    } catch (e) {
      throw e;
    }
  }

  Future<String?> getToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    return token;
  }
}
