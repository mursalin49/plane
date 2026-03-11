import 'package:avislap/controllers/login_controller.dart';
import 'package:avislap/views/auth/ResetPassword.dart';
import 'package:avislap/views/auth/forget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class _C {
  static const Color blue = Color(0xFF3D5AFE);
  static const Color ink = Color(0xFF0E0E10);
  static const Color white = Color(0xFFFFFFFF);
}

class TroubleScreen extends StatefulWidget {
  const TroubleScreen({super.key});

  @override
  State<TroubleScreen> createState() => _TroubleScreenState();
}

class _TroubleScreenState extends State<TroubleScreen>
    with SingleTickerProviderStateMixin {
  final controller = Get.put(AuthController());

  // ✅ Single wave controller — 3.8s repeating cycle (same as login)
  // C2: 0%→40% grow | 40%→55% hold | 55%→75% shrink | 75%→100% hidden
  // C3: 0%→42% hidden | 42%→70% grow | 70%→80% hold | 80%→100% shrink
  late AnimationController _waveCtrl;
  late Animation<double> _c2Scale;
  late Animation<double> _c2Opacity;
  late Animation<double> _c3Scale;
  late Animation<double> _c3Opacity;

  @override
  void initState() {
    super.initState();

    _waveCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3800))
      ..repeat();

    // Circle 2: medium — appear first (wave out from center)
    _c2Scale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.35, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOutCubic)),
          weight: 40), // grow
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 15), // hold
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.35)
              .chain(CurveTween(curve: Curves.easeInCubic)),
          weight: 20), // shrink
      TweenSequenceItem(tween: ConstantTween(0.35), weight: 25), // wait
    ]).animate(_waveCtrl);

    _c2Opacity = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.0), weight: 15), // fade in
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 40), // visible
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.0), weight: 15), // fade out
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 30), // hidden
    ]).animate(_waveCtrl);

    // Circle 3: biggest — appear after circle 2 closes (bigger wave)
    _c3Scale = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.35), weight: 42), // wait
      TweenSequenceItem(
          tween: Tween(begin: 0.35, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOutCubic)),
          weight: 28), // grow
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 10), // hold
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.35)
              .chain(CurveTween(curve: Curves.easeInCubic)),
          weight: 20), // shrink
    ]).animate(_waveCtrl);

    _c3Opacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 38), // hidden
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.0), weight: 14), // fade in
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 24), // visible
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.0), weight: 24), // fade out
    ]).animate(_waveCtrl);
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double c1Size = size.width * 0.90;
    final double c3Size = size.width * 0.70;
    final double c2Size = size.width * 0.48;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [
          _buildHero(size, c1Size, c2Size, c3Size),
          Expanded(
            child: SingleChildScrollView(
              child: Transform.translate(
                offset: const Offset(0, -30),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 28.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Please Select your issue',
                        style: GoogleFonts.dmSans(
                          fontSize: 14.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      _buildRadioOption("I don't know my used ID ?", "id_issue"),
                      SizedBox(height: 4.h),
                      _buildRadioOption("I don't know my Password ?", "pass_issue"),
                      SizedBox(height: 4.h),
                      _buildRadioOption(
                          "Doesn't have access to my Registered E-mail ID",
                          "email_issue"),
                      SizedBox(height: 24.h),
                      _buildContinueButton(),
                      SizedBox(height: 16.h),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Text(
                          'Back to Sign In',
                          style: GoogleFonts.dmSans(
                            fontSize: 14.sp,
                            color: _C.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _buildHomeIndicator(),
        ],
      ),
    );
  }

  Widget _buildHero(Size size, double c1Size, double c2Size, double c3Size) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 44.h),
      decoration: BoxDecoration(
        color: _C.blue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36.r),
          bottomRight: Radius.circular(36.r),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Circle 1 — fixed, outermost, always visible
          Positioned(
            top: -(c1Size * 0.38),
            right: -(c1Size * 0.30),
            child: Container(
              width: c1Size,
              height: c1Size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.18),
                  width: 1.5,
                ),
              ),
            ),
          ),

          // Circle 3 — wave big ring (opens after C2 closes)
          Positioned(
            top: -(c3Size * 0.38),
            right: -(c3Size * 0.30),
            child: AnimatedBuilder(
              animation: _waveCtrl,
              builder: (_, __) => Opacity(
                opacity: _c3Opacity.value,
                child: Transform.scale(
                  scale: _c3Scale.value,
                  alignment: Alignment.topRight,
                  child: Container(
                    width: c3Size,
                    height: c3Size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.30),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Circle 2 — wave medium ring (opens first)
          Positioned(
            top: -(c2Size * 0.38),
            right: -(c2Size * 0.30),
            child: AnimatedBuilder(
              animation: _waveCtrl,
              builder: (_, __) => Opacity(
                opacity: _c2Opacity.value,
                child: Transform.scale(
                  scale: _c2Scale.value,
                  alignment: Alignment.topRight,
                  child: Container(
                    width: c2Size,
                    height: c2Size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height:25.h),
                Row(
                  children: [
                    _buildHeroMark(),
                    SizedBox(width: 8.w),
                    Text(
                      'Parallax',
                      style: GoogleFonts.dmSans(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25.h),
                Text(
                  'Having Trouble\nSigning in?',
                  style: GoogleFonts.dmSans(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.8,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMark() {
    return SizedBox(
      height: 18.h,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _bar(18.h, 1.0),
          SizedBox(width: 3.w),
          _bar(13.h, 0.4),
          SizedBox(width: 3.w),
          _bar(9.h, 0.15),
        ],
      ),
    );
  }

  Widget _bar(double h, double opacity) => Container(
    width: 4.w,
    height: h,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(2.r),
    ),
  );

  Widget _buildRadioOption(String title, String value) {
    return Obx(() {
      final selected = controller.selectedIssue.value == value;
      return GestureDetector(
        onTap: () => controller.selectedIssue.value = value,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 22.w,
                height: 22.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? _C.blue : Colors.grey.shade400,
                    width: selected ? 5.5 : 1.5,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildContinueButton() {
    return GestureDetector(
      onTap: () => Get.to(() => ForgotPasswordScreen()),
      child: Container(
        height: 54.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _C.blue,
          borderRadius: BorderRadius.circular(30.r),
        ),
        alignment: Alignment.center,
        child: Text(
          'CONTINUE',
          style: GoogleFonts.dmSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildHomeIndicator() {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Center(
        child: Container(
          width: 134.w,
          height: 5.h,
          decoration: BoxDecoration(
            color: _C.ink.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(3.r),
          ),
        ),
      ),
    );
  }
}