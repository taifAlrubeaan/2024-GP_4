import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showAwesomeDialog(String title, String message,
    {DialogType dialogType = DialogType.error}) async {
  await AwesomeDialog(
    padding: const EdgeInsets.all(10),
    context: Get.context!,
    dialogType: dialogType,
    animType: AnimType.rightSlide,
    title: title.tr,
    alignment: AlignmentDirectional.center,
    desc: message.tr,
    btnOk: ElevatedButton(
      child: Text("Ok".tr),
      onPressed: () => Get.back(),
    ),
  ).show();
}

String handleFirebaseException(FirebaseException e) {
  if (e.code == 'weak-password') {
    return 'Password is To weak.....'.tr;
  } else if (e.code == 'email-already-in-use') {
    return "The account already exists for that email".tr;
  } else if (e.code == 'user-not-found') {
    return "No user found for that email.".tr;
  } else if (e.code == 'wrong-password') {
    return "Wrong password provided for that user.".tr;
  } else {
    return "Oops! Some thing error! check your data and try again.".tr;
  }
}
