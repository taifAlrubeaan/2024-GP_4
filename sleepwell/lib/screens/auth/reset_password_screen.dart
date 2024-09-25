import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../public_methods.dart';

class ResetPasswordScreen extends StatelessWidget {
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  final TextEditingController bvnController = TextEditingController();
  late UserCredential userCredential;
  var u_email;
  final RxBool isWaiting = false.obs;

  ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF004AAD), Color(0xFF040E3B)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter your email'.tr,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20.0),
            Container(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formstate,
                child: TextFormField(
                  onSaved: (val) {
                    u_email = val;
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email'.tr,
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  cursorColor: const Color.fromRGBO(33, 243, 37, 1),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Required field".tr;
                    }
                    if (!val.isEmail) {
                      return "Please enter a valid email".tr;
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Obx(
              () => ElevatedButton(
                onPressed: () async {
                  Get.focusScope?.unfocus();
                  final formKey = formstate.currentState;
                  if (!(formKey?.validate() ?? true)) return;
                  isWaiting.value = true;
                  formKey?.save();
                  if (await sendResetPassLink(u_email)) {
                    showAwesomeDialog(
                      "Successfull".tr,
                      "Open your email to get link to reset your password".tr,
                      dialogType: DialogType.success,
                    ).then((value) => Get.back());
                  }
                  isWaiting.value = false;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffd5defe),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 80.0, vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  foregroundColor: Colors.black,
                ),
                child: isWaiting.value
                    ? const CircularProgressIndicator()
                    : Text(
                        'Verify'.tr,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Validate BVN (for demonstration purposes)
  bool isValidBVN(String bvn) {
    // In a real application, you would perform server-side validation
    // with a secure backend service.
    return bvn.length == 12 && int.tryParse(bvn) != null;
  }

  bool isValidBVEmail(String bvn) {
    // In a real application, you would perform server-side validation
    // with a secure backend service.

    return (bvn.length > 12);
  }
}

Future<bool> sendResetPassLink(String email) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    return true;
  } on FirebaseException catch (e) {
    print("Error: $e");
    showAwesomeDialog("Error", handleFirebaseException(e));
  }
  return false;
}
