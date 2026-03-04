import 'package:avislap/utils/app_colors.dart';
import 'package:avislap/utils/app_images.dart';
import 'package:avislap/utils/app_text.dart';
import 'package:avislap/views/auth/comon_widets.dart';
import 'package:avislap/views/auth/otp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const SizedBox(height: 60),
            buildCircularLogo(),
            const SizedBox(height: 40),
            AppText("Forgot Password", fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.mainAppColor),
            const SizedBox(height: 10),
            AppText("Enter your email address and we'll send you a link to reset your password", textAlign: TextAlign.center, color: Colors.grey),

            const SizedBox(height: 40),
            buildInputLabel("Email"),
            SizedBox(height: 10),
            buildTextField(hint: "Enter your email"),

            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Get.back(),
              child: AppText("Back to Sign In", color: AppColors.mainAppColor, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            buildPrimaryButton("SEND RESET LINK", () {
              Get.to(() => OTPVerificationScreen());
            }),
          ],
        ),
      ),
    );
  }

}