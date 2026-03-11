import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class _C {
  static const Color blue = Color(0xFF3D5AFE);
  static const Color ink = Color(0xFF0E0E10);
  static const Color border = Color(0xFFEAECF2);
  static const Color placeholder = Color(0xFFC8CDD9);
}

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with SingleTickerProviderStateMixin {

  // ── OTP fields ───────────────────────────────────────────
  final int _otpLength = 5;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  // ── Resend timer ─────────────────────────────────────────
  Timer? _timer;
  int _secondsLeft = 0; // 0 = show "Resend OTP", >0 = show "wait for X.XX sec"
  bool _canResend = true;

  // ── Wave circles ─────────────────────────────────────────
  late AnimationController _waveCtrl;
  late Animation<double> _c2Scale;
  late Animation<double> _c2Opacity;
  late Animation<double> _c3Scale;
  late Animation<double> _c3Opacity;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());

    // Wave animation — same as login/trouble/forget
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

    // Focus first box
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  // ── Resend timer logic ───────────────────────────────────
  void _startResendTimer() {
    setState(() {
      _secondsLeft = 60; // 60 seconds countdown
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _secondsLeft -= 1;
        if (_secondsLeft <= 0) {
          _secondsLeft = 0;
          _canResend = true;
          t.cancel();
        }
      });
    });
  }

  String get _timerText {
    final secs = (_secondsLeft / 10).floor();
    final tenths = _secondsLeft % 10;
    return 'wait for $secs.$tenths sec';
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _timer?.cancel();
    _waveCtrl.dispose();
    super.dispose();
  }

  // ── OTP input handler ────────────────────────────────────
  void _onOtpChanged(String value, int index) {
    if (value.length == 1) {
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
  }

  void _onKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
    }
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
                      // Subtitle
                      Text(
                        'Enter the otp sent to your email address\nto reset your old password',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 13.sp,
                          color: Colors.grey.shade500,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // OTP boxes
                      _buildOtpRow(),
                      SizedBox(height: 28.h),

                      // Continue button
                      _buildContinueButton(),
                      SizedBox(height: 16.h),

                      // Resend / Timer
                      _canResend
                          ? GestureDetector(
                        onTap: _startResendTimer,
                        child: Text(
                          'Resend OTP',
                          style: GoogleFonts.dmSans(
                            fontSize: 14.sp,
                            color: _C.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                          : Text(
                        _timerText,
                        style: GoogleFonts.dmSans(
                          fontSize: 14.sp,
                          color: _C.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Back to Sign In
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

  // ── OTP Row ───────────────────────────────────────────────
  Widget _buildOtpRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_otpLength, (i) => _buildOtpBox(i)),
    );
  }

  Widget _buildOtpBox(int index) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (e) => _onKeyEvent(e, index),
      child: SizedBox(
        width: 52.w,
        height: 58.h,
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.dmSans(
            fontSize: 22.sp,
            fontWeight: FontWeight.w600,
            color: _C.ink,
          ),
          onChanged: (v) => _onOtpChanged(v, index),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: _C.border, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: _C.blue, width: 2),
            ),
          ),
        ),
      ),
    );
  }

  // ── Continue Button ───────────────────────────────────────
  Widget _buildContinueButton() {
    return GestureDetector(
      onTap: () {
        final otp = _controllers.map((c) => c.text).join();
        // handle OTP verification
        // Get.to(() => NextScreen());
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