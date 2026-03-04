import 'package:avislap/controllers/login_controller.dart';
import 'package:avislap/views/auth/comon_widets.dart';
import 'package:avislap/views/auth/reset_successful.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordScreen extends StatelessWidget {
  final controller = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const SizedBox(height: 60),
            buildCircularLogo(),
            const SizedBox(height: 40),
            buildHeader("Reset Password", "Enter new password & confirm the password to set a new password"),
            const SizedBox(height: 40),
            buildInputLabel("New Password"),
            Obx(() => buildTextField(
              hint: "Enter new password",
              obscureText: !controller.isNewPasswordVisible.value,
              suffixIcon: IconButton(
                icon: Icon(controller.isNewPasswordVisible.value ? Icons.visibility : Icons.visibility_off),
                onPressed: controller.toggleNewPassword,
              ),
            )),
            const SizedBox(height: 20),
            buildInputLabel("Confirm Password"),
            Obx(() => buildTextField(
              hint: "Confirm password",
              obscureText: !controller.isConfirmPasswordVisible.value,
              suffixIcon: IconButton(
                icon: Icon(controller.isConfirmPasswordVisible.value ? Icons.visibility : Icons.visibility_off),
                onPressed: controller.toggleConfirmPassword,
              ),
            )),
            const SizedBox(height: 100),
            buildPrimaryButton("SUBMIT", () {
              Get.to(()=> ResetSuccessScreen());
            }),
          ],
        ),
      ),
    );
  }
}