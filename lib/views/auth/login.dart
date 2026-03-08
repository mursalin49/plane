import 'package:avislap/controllers/login_controller.dart';
import 'package:avislap/utils/app_colors.dart';
import 'package:avislap/utils/app_images.dart';
import 'package:avislap/utils/app_text.dart';
import 'package:avislap/views/CabinAudit.dart';
import 'package:avislap/views/auth/comon_widets.dart';
import 'package:avislap/views/auth/trouble.dart';
import 'package:avislap/views/dashboard/dashboard_screen.dart';
import 'package:avislap/views/extra/CabinQualityAuditList.dart';
import 'package:avislap/views/extra/CabinSecurityTrainingScreen.dart';
import 'package:avislap/views/extra/EndOfShiftReportScreen.dart';
import 'package:avislap/views/extra/LavSafetyObservationScreen.dart';
import 'package:avislap/views/extra/employee_one_screen.dart';
import 'package:avislap/views/extra/new_search_bottom_sheet.dart';
import 'package:avislap/views/home/LAVSafety.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  final controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 80),
            // 🔹 Circular Logo
            Center(
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.mainAppColor, width: 2),
                ),
                child: Image.asset(AppImages.logo, height: 80),
              ),
            ),
            const SizedBox(height: 40),
            AppText("Welcome Back", fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.mainAppColor),
            AppText("Sign in to access your account", color: Colors.grey),

            const SizedBox(height: 40),
            _buildLabel("User ID"),
            SizedBox(height: 10),
            _buildTextField("Enter your User ID"),

            const SizedBox(height: 20),
            _buildLabel("New Password"),
            SizedBox(height: 10),
            Obx(() => _buildTextField(
              "Enter new password",
              isPassword: true,
              obscureText: !controller.isPasswordVisible.value,
              suffixIcon: IconButton(
                icon: Icon(controller.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off),
                onPressed: controller.togglePassword,
              ),
            )),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Obx(() => Checkbox(
                      value: controller.rememberMe.value,
                      onChanged: (v) => controller.rememberMe.value = v!,
                      activeColor: AppColors.mainAppColor,
                    )),
                    AppText("Remember me", fontSize: 13, color: AppColors.mainAppColor),
                  ],
                ),
                TextButton(
                  onPressed: () => Get.to(() => trouble()),
                  child: AppText("Trouble Signing in?", fontSize: 13, color: AppColors.mainAppColor),
                ),
              ],
            ),

            const SizedBox(height: 60),
            buildPrimaryButton("SIGN IN", () {
              Get.to(()=> DashboardScreen());
              // Get.to(()=>LAVSafetyScreen());
              // Get.to(()=> LavSafetyObservationScreen());
              // Get.to(() => const CabinSecurityScreen());
              // Get.to(() => const EndOfShiftReportScreen());
              // Get.to(() => const NewSearchBottomSheet());
              // Get.to(() => const EmployeeOneOnOneScreen());
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Align(
    alignment: Alignment.centerLeft,
    child: AppText(text, fontWeight: FontWeight.bold, color: AppColors.mainAppColor, fontSize: 14),
  );

  Widget _buildTextField(String hint, {bool isPassword = false, bool obscureText = false, Widget? suffixIcon}) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
    );
  }
}