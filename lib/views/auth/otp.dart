import 'package:avislap/utils/app_colors.dart';
import 'package:avislap/utils/app_images.dart';
import 'package:avislap/utils/app_text.dart';
import 'package:avislap/views/auth/comon_widets.dart';
import 'package:avislap/views/auth/login.dart';
import 'package:avislap/views/auth/opt_successful.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

class OTPVerificationScreen extends StatelessWidget {
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
            AppText("OTP Verification", fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.mainAppColor),
            const SizedBox(height: 10),
            AppText("Enter the otp sent to your email address to reset your old password", textAlign: TextAlign.center, color: Colors.grey),

            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) => _buildOTPBox()),
            ),

            const SizedBox(height: 20),
            TextButton(onPressed: () {}, child: AppText("Resend OTP", color: AppColors.mainAppColor, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () => Get.offAll(() => LoginScreen()), child: AppText("Back to Sign In", color: AppColors.mainAppColor, fontWeight: FontWeight.bold)),

            const Spacer(),
            _buildPrimaryButton("CONTINUE", () {
              Get.to(() => OTPSuccessScreen());
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOTPBox() {
    return SizedBox(
      width: 50,
      child: TextField(
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: "",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(String label, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.mainAppColor,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: AppText(label, color: Colors.white, fontWeight: FontWeight.bold),
    );
  }


}