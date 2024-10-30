import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sleepwell/controllers/auth/signup_controller.dart';
import 'package:sleepwell/screens/auth/signin_screen.dart';

import '../../widget/regsterbutton.dart';
import '../../widget/text_field_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final SignUpController authController = Get.put(SignUpController());

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cpasswordController = TextEditingController();

  @override
  void dispose() {
    // Dispose of each controller when not in use
    firstNameController.dispose();
    lastNameController.dispose();
    ageController.dispose();
    emailController.dispose();
    passwordController.dispose();
    cpasswordController.dispose();
    super.dispose();
  }

  Widget buildInstractionSignUp() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10,
        ),
        Text(
          '- Password should be Identical.'.tr,
          style: const TextStyle(
              color: Color.fromARGB(241, 230, 158, 3),
              fontSize: 15,
              fontWeight: FontWeight.bold),
        ),
        Text(
          '- At least 8 characters long.'.tr,
          style: const TextStyle(
              color: Color.fromARGB(241, 230, 158, 3),
              fontSize: 15,
              fontWeight: FontWeight.bold),
        ),
        Text(
          '- Password should contain numbers & characters.'.tr,
          style: const TextStyle(
              color: Color.fromARGB(241, 230, 158, 3),
              fontSize: 15,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 74, 173),
        title: Text(
          'SignUp'.tr,
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        return ModalProgressHUD(
          inAsyncCall: authController.isLoading.value,
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF004AAD), Color(0xFF040E3B)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                Center(
                  child: Text(
                    'Let’s create your account!'.tr,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                TextFieldWidget(
                  controller: firstNameController,
                  hintText: 'First Name'.tr,
                  icon: Icons.person,
                ),
                const SizedBox(height: 20),
                TextFieldWidget(
                  controller: lastNameController,
                  hintText: 'Last Name'.tr,
                  icon: Icons.person,
                ),
                const SizedBox(height: 20),
                TextFieldWidget(
                  controller: ageController,
                  hintText: 'Your Age'.tr,
                  icon: Icons.date_range,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 20),
                TextFieldWidget(
                  controller: emailController,
                  hintText: 'Email Address'.tr,
                  icon: Icons.email,
                ),
                const SizedBox(height: 20),
                TextFieldWidget(
                  controller: passwordController,
                  hintText: 'Password'.tr,
                  icon: Icons.key,
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                TextFieldWidget(
                  controller: cpasswordController,
                  hintText: 'Confirm Password'.tr,
                  icon: Icons.key,
                  obscureText: true,
                ),
                buildInstractionSignUp(),
                RegisterButton(
                  color: const Color(0xffd5defe),
                  title: 'Create Account'.tr,
                  onPressed: () {
                    if (ageController.text.isEmpty ||
                        int.tryParse(ageController.text) == null ||
                        int.parse(ageController.text) <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid age.'),
                        ),
                      );
                      return;
                    }

                    authController.signUp(
                      emailController.text.trim(),
                      passwordController.text,
                      cpasswordController.text,
                      firstNameController.text.trim(),
                      lastNameController.text.trim(),
                      ageController.text.trim(),
                    );
                  },
                ),
                const SizedBox(height: 10.0),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    'Already have an account?'.tr,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      Get.offAll(const SignInScreen());
                      // Get.back();
                      // Get.back();
                    },
                    child: Text(
                      "Login".tr,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        );
      }),
    );
  }
}
