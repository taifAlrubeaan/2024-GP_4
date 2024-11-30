import 'package:get/get.dart';
import 'package:sleepwell/signup/question.dart';

import '../../services/signupt_service.dart';

class SignUpController extends GetxController {
  final SignUpService _authService = SignUpService();
  var isLoading = false.obs;

  Future<void> signUp(String email, String password, String cpassword,
      String firstName, String lastName, String age) async {
    if (password != cpassword) {
      Get.snackbar('Error', 'Passwords do not match');
      return;
    }

    try {
      isLoading.value = true;
      await _authService.createUser(email, password, firstName, lastName, age);
      Get.snackbar('Success', 'Account created successfully');
      Get.offAll(const QuestionScreen());
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
