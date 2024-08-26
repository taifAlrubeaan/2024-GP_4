// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class AuthServise {
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();

//   Future<void> signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser != null) {
//         final GoogleSignInAuthentication googleSignInAuthentication =
//             await googleUser.authentication;
//         final AuthCredential credential = GoogleAuthProvider.credential(
//           accessToken: googleSignInAuthentication.accessToken,
//           idToken: googleSignInAuthentication.idToken,
//         );

//         final UserCredential userCredential =
//             await _firebaseAuth.signInWithCredential(credential);
//         final User? user = userCredential.user;

//         // Now the signed-in user's data is stored in Firebase
//         // You can access the user's information through the `user` object
//       }
//     } catch (e) {
//       print('Error occurred during Google Sign-In: $e');
//       // Handle sign-in error
//     }
//   }
// }

// /*
// class AuthServise {
//   //Google sign in
//   /*Future<void> signinWithGoogle() async {
//     // Begin interactive sign in process
//     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

//     // Obtain auth details from request
//     final GoogleSignInAuthentication googleAuth =
//         await googleUser!.authentication;

//     // Create a new credential for user
//     final OAuthCredential credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );

//     // Let's sign in
//     await FirebaseAuth.instance.signInWithCredential(credential);
//   }*/
//   Future<void> signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//       if (googleUser != null) {
//         // Perform sign-in with the obtained Google user data
//         // You can access the name, gender, email, and other details from the googleUser object
//         final GoogleSignInAuthentication googleSignInAuthentication =
//             await googleUser.authentication;
//         final AuthCredential credential = GoogleAuthProvider.credential(
//           accessToken: googleSignInAuthentication.accessToken,
//           idToken: googleSignInAuthentication.idToken,
//         );

//         final UserCredential userCredential =
//             await FirebaseAuth.instance.signInWithCredential(credential);
//         final User? user = userCredential.user;
//       }
//     } catch (e) {
//       print('Error occurred during Google Sign-In: $e');
//       // Handle sign-in error
//     }
//   }
// }*/
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          print('Signed in successfully: ${user.email}');
          // يمكنك التعامل مع بيانات المستخدم هنا
          // مثلاً، يمكنك تخزين بعض البيانات في SharedPreferences أو معالجة التوجيه داخل التطبيق
        } else {
          print('User is null');
        }
      } else {
        print('Google user is null');
      }
    } catch (e) {
      print('Error occurred during Google Sign-In: $e');
      // تعامل مع الأخطاء هنا، قد ترغب في إظهار رسالة للمستخدم
    }
  }
}
