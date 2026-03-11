import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class _C {
  static const Color blue = Color(0xFF3D5AFE);
  static const Color ink = Color(0xFF0E0E10);
}

class OtpSuccessScreen extends StatefulWidget {
  const OtpSuccessScreen({super.key});

  @override
  State<OtpSuccessScreen> createState() => _OtpSuccessScreenState();
}

class _OtpSuccessScreenState extends State<OtpSuccessScreen>
    with SingleTickerProviderStateMixin {

  // ✅ Wave circles — same as all auth screens
  late AnimationController _waveCtrl;
  late Animation<double> _c2Scale, _c2Opacity, _c3Scale, _c3Opacity;

  // ✅ Check icon animation
  late AnimationController _checkCtrl;
  late Animation<double> _checkScale;
  late Animation<double> _checkOpacity;

  @override
  void initState() {
    super.initState();

    // Wave
    _waveCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3800))
      ..repeat();

    _c2Scale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.35, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOutCubic)),
          weight: 40),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 15),
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.35)
              .chain(CurveTween(curve: Curves.easeInCubic)),
          weight: 20),
      TweenSequenceItem(tween: ConstantTween(0.35), weight: 25),
    ]).animate(_waveCtrl);

    _c2Opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 30),
    ]).animate(_waveCtrl);

    _c3Scale = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.35), weight: 42),
      TweenSequenceItem(
          tween: Tween(begin: 0.35, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOutCubic)),
          weight: 28),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 10),
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.35)
              .chain(CurveTween(curve: Curves.easeInCubic)),
          weight: 20),
    ]).animate(_waveCtrl);

    _c3Opacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 38),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 14),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 24),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 24),
    ]).animate(_waveCtrl);

    // ✅ Check icon bounce-in animation
    _checkCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut));
    _checkOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _checkCtrl,
            curve: const Interval(0.0, 0.4, curve: Curves.easeIn)));

    // Start check after short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _checkCtrl.forward();
    });
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _checkCtrl.dispose();
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
          // ── Blue Hero ──────────────────────────────────
          _buildHero(size, c1Size, c2Size, c3Size),

          // ── White Card ────────────────────────────────
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                padding: EdgeInsets.fromLTRB(24.w, 40.h, 24.w, 36.h),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ✅ Animated check icon
                    AnimatedBuilder(
                      animation: _checkCtrl,
                      builder: (_, __) => Opacity(
                        opacity: _checkOpacity.value,
                        child: Transform.scale(
                          scale: _checkScale.value,
                          child: Container(
                            width: 72.w,
                            height: 72.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                              Border.all(color: _C.blue, width: 2.5),
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              color: _C.blue,
                              size: 36.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Title
                    Text(
                      'OTP Verification\nSuccessful',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: _C.blue,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Subtitle
                    Text(
                      'You can now reset your password',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 13.sp,
                        color: Colors.grey.shade500,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // GO TO PASSWORD RESET button
                    GestureDetector(
                      onTap: () {
                        // Navigate back to login, clearing stack
                        Get.offAllNamed('/login');
                        // or: Get.offAll(() => const LoginScreen());
                      },
                      child: Container(
                        height: 54.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _C.blue,
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'GO TO PASSWORD RESET',
                          style: GoogleFonts.dmSans(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          _buildHomeIndicator(),
        ],
      ),
    );
  }

  // ── Hero ─────────────────────────────────────────────────
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
          // Circle 1 — fixed
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

          // Circle 3 — wave big
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

          // Circle 2 — wave medium
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
                SizedBox(height: 8.h),
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
                SizedBox(height: 24.h),
                Text(
                  'OTP Verification',
                  style: GoogleFonts.dmSans(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.8,
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