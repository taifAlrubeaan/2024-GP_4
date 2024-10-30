import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart'; // إضافة مكتبة UUID لتوليد معرف فريد

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          final String userId = user.uid;
          final String email = user.email ?? '';
          final String name = user.displayName ?? '';
          final String? token = await user.getIdToken();

          final userDoc =
              await _firestore.collection('Users').doc(userId).get();

          // إذا لم تكن البيانات موجودة، قم بإنشاء مستند جديد بالمعلومات المطلوبة
          if (!userDoc.exists) {
            // توليد UUID فريد لحساب جوجل الجديد
            final String newUserId = const Uuid().v4();
            final token = await FirebaseMessaging.instance.getToken();

            print(":::::::::::::::::::::::::::::::$newUserId");
            await _firestore.collection('Users').doc(userId).set({
              'UserId': newUserId,
              'Email': email,
              'Fname': name.split(" ").first,
              'Lname': name.split(" ").last,
              'Age': '',
              'Password': '',
              'FCM_Token': token,
            });
          }
        } else {
          throw FirebaseAuthException(
              code: 'user-null', message: 'User ID not found!');
        }
      } else {
        throw FirebaseAuthException(
            code: 'sign-in-canceled', message: 'Google Sign-In canceled.');
      }
    } catch (e) {
      print('Error occurred during Google Sign-In: $e');
      throw e;
    }
  }
}
