import 'package:avislap/utils/app_colors.dart';
import 'package:avislap/utils/app_icons.dart';
import 'package:avislap/utils/app_text.dart';
import 'package:avislap/views/auth/ResetPassword.dart';
import 'package:avislap/views/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'comon_widets.dart';

class ResetSuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildCircularLogo(),
            const SizedBox(height: 50),
            SvgPicture.asset(AppIcons.successful, width: 80, height: 80, colorFilter: ColorFilter.mode(AppColors.mainAppColor, BlendMode.srcIn)),
            const SizedBox(height: 20),
            AppText("Password Reset Successful", fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.mainAppColor, textAlign: TextAlign.center,),
            const SizedBox(height: 10),
            AppText("You can now login with your new password", color: Colors.grey, textAlign: TextAlign.center),
            const SizedBox(height: 100),
            buildPrimaryButton("GO TO SIGN IN", () {
              Get.to(() => LoginScreen());
            }),
          ],
        ),
      ),
    );
  }
}