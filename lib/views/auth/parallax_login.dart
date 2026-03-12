import 'package:avislap/utils/app_colors.dart';
import 'package:avislap/views/auth/trouble_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:avislap/views/dashboard/dashboard_screen.dart';
import 'package:avislap/views/auth/forget.dart';
import 'package:avislap/views/select_station/select_station.dart';

// =====================
// COLORS
// =====================
class _C {
  static const Color blue = Color(0xFF3D5AFE);
  static const Color ink = Color(0xFF0E0E10);
  static const Color white = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFF8891A4);
  static const Color border = Color(0xFFEAECF2);
  static const Color bg = Color(0xFFF7F8FC);
  static const Color placeholder = Color(0xFFC8CDD9);
}

// =====================
// SPLASH SCREEN
// =====================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _logoSlide;

  late AnimationController _bar1Ctrl;
  late AnimationController _bar2Ctrl;
  late AnimationController _bar3Ctrl;
  late Animation<double> _bar1Scale;
  late Animation<double> _bar2Scale;
  late Animation<double> _bar3Scale;

  late AnimationController _wordCtrl;
  late Animation<Offset> _wordSlide;

  late AnimationController _exitCtrl;
  late Animation<double> _exitOpacity;
  late Animation<double> _exitScale;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(_logoCtrl);
    _logoSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutExpo));

    _bar1Ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _bar2Ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _bar3Ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _bar1Scale = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _bar1Ctrl, curve: Curves.easeOutExpo));
    _bar2Scale = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _bar2Ctrl, curve: Curves.easeOutExpo));
    _bar3Scale = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _bar3Ctrl, curve: Curves.easeOutExpo));

    _wordCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _wordSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _wordCtrl, curve: Curves.easeOutExpo));

    _exitCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
    _exitOpacity = Tween<double>(begin: 1, end: 0).animate(_exitCtrl);
    _exitScale = Tween<double>(begin: 1, end: 1.03).animate(_exitCtrl);

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 250));
    _bar1Ctrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _bar2Ctrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _bar3Ctrl.forward();
    _wordCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1400));
    _exitCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 520));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionDuration: Duration.zero,
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _bar1Ctrl.dispose();
    _bar2Ctrl.dispose();
    _bar3Ctrl.dispose();
    _wordCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.white,
      body: AnimatedBuilder(
        animation: _exitCtrl,
        builder: (context, child) => Opacity(
          opacity: _exitOpacity.value,
          child: Transform.scale(scale: _exitScale.value, child: child),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _logoCtrl,
            builder: (context, _) => FadeTransition(
              opacity: _logoOpacity,
              child: SlideTransition(
                position: _logoSlide,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLogoMark(),
                    SizedBox(height: 14.h),
                    ClipRect(
                      child: SizedBox(
                        height: 40.h,
                        child: SlideTransition(
                          position: _wordSlide,
                          child: Text(
                            'Parallax',
                            style: GoogleFonts.dmSans(
                              fontSize: 30.sp,
                              fontWeight: FontWeight.w400,
                              color: _C.ink,
                              letterSpacing: -0.6,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoMark() {
    return SizedBox(
      height: 38.h,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildBar(_bar1Scale, 38.h, 1.0),
          SizedBox(width: 6.w),
          _buildBar(_bar2Scale, 30.h, 0.38),
          SizedBox(width: 6.w),
          _buildBar(_bar3Scale, 22.h, 0.14),
        ],
      ),
    );
  }

  Widget _buildBar(Animation<double> scale, double height, double opacity) {
    return AnimatedBuilder(
      animation: scale,
      builder: (_, __) => Align(
        alignment: Alignment.bottomCenter,
        child: Transform.scale(
          scaleY: scale.value,
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 8.w,
            height: height,
            decoration: BoxDecoration(
              color: _C.blue.withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(2.5.r),
            ),
          ),
        ),
      ),
    );
  }
}

// =====================
// LOGIN SCREEN
// =====================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _userIdCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  late AnimationController _heroCtrl;
  late Animation<double> _heroOpacity;
  late Animation<Offset> _heroSlide;

  late AnimationController _formCtrl;
  late List<Animation<double>> _itemOpacity;
  late List<Animation<Offset>> _itemSlide;

  late AnimationController _shimmerCtrl;
  late Animation<double> _shimmerAnim;

  // ✅ Fast pulse controller — each circle blinks on/off from fixed position
  late AnimationController _waveCtrl;
  late Animation<double> _c2Opacity;
  late Animation<double> _c3Opacity;

  @override
  void initState() {
    super.initState();

    _heroCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _heroOpacity = Tween<double>(begin: 0, end: 1).animate(_heroCtrl);
    _heroSlide =
        Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero).animate(
            CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutExpo));

    _formCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _itemOpacity = List.generate(
        5,
            (i) => Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
          parent: _formCtrl,
          curve: Interval(i * 0.1, i * 0.1 + 0.55,
              curve: Curves.easeOutExpo),
        )));
    _itemSlide = List.generate(
        5,
            (i) =>
            Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
                .animate(CurvedAnimation(
              parent: _formCtrl,
              curve: Interval(i * 0.1, i * 0.1 + 0.55,
                  curve: Curves.easeOutExpo),
            )));

    _shimmerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3200))
      ..repeat();
    _shimmerAnim =
        Tween<double>(begin: -1.5, end: 2.5).animate(_shimmerCtrl);

    // ✅ Fast pulse — 1.4s cycle, circles blink on/off from their fixed positions
    _waveCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat();

    // Circle 2: opens first (early fade-in), closes together with C3
    _c2Opacity = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.0), weight: 10), // fade in (early)
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 40), // ON
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.0), weight: 10), // fade out TOGETHER
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 40), // OFF
    ]).animate(_waveCtrl);

    // Circle 3: opens later (delayed fade-in), closes at same time as C2
    _c3Opacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 25), // OFF (wait)
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.0), weight: 10), // fade in (late)
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 15), // ON
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.0), weight: 10), // fade out TOGETHER
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 40), // OFF
    ]).animate(_waveCtrl);

    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) {
        _heroCtrl.forward();
        _formCtrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _userIdCtrl.dispose();
    _passwordCtrl.dispose();
    _heroCtrl.dispose();
    _formCtrl.dispose();
    _shimmerCtrl.dispose();
    _waveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          FadeTransition(
            opacity: _heroOpacity,
            child: SlideTransition(
              position: _heroSlide,
              child: _buildHero(size),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Transform.translate(
                offset: const Offset(0, -150),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 28.h),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormItem(index: 0, child: _buildUserIdField()),
                      SizedBox(height: 16.h),
                      _buildFormItem(index: 1, child: _buildPasswordField()),
                      SizedBox(height: 14.h),
                      _buildFormItem(index: 2, child: _buildRememberRow()),
                      SizedBox(height: 24.h),
                      _buildFormItem(index: 3, child: _buildSignInButton()),
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

  // ── Hero ─────────────────────────────────────────────────
  Widget _buildHero(Size size) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 180.h),
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
          Positioned(
            top: -size.width * 0.06,
            right: -size.width * 0.06,
            child: Container(
              width: size.width * 0.38,
              height: size.width * 0.38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.30),
                  width: 1.5,
                ),
              ),
            ),
          ),


          // Circle 2 — medium (0.62w), opens first — same as parallax_login
          Positioned(
            top: -size.width * 0.16,
            right: -size.width * 0.16,
            child: AnimatedBuilder(
              animation: _waveCtrl,
              builder: (_, __) => Opacity(
                opacity: _c2Opacity.value.clamp(0.0, 1.0),
                child: Container(
                  width: size.width * 0.62,
                  height: size.width * 0.62,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.20),
                        width: 1.5),
                  ),
                ),
              ),
            ),
          ),

          // Circle 3 — biggest (0.90w), opens late — same as parallax_login
          Positioned(
            top: -size.width * 0.28,
            right: -size.width * 0.28,
            child: AnimatedBuilder(
              animation: _waveCtrl,
              builder: (_, __) => Opacity(
                opacity: _c3Opacity.value.clamp(0.0, 1.0),
                child: Container(
                  width: size.width * 0.90,
                  height: size.width * 0.90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.13),
                        width: 1.5),
                  ),
                ),
              ),
            ),
          ),

          // ── Content ──
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
                SizedBox(height: 24.h),
                Text(
                  'Sign in to\nyour Account',
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
          _heroBar(18.h, 1.0),
          SizedBox(width: 3.w),
          _heroBar(13.h, 0.4),
          SizedBox(width: 3.w),
          _heroBar(9.h, 0.15),
        ],
      ),
    );
  }

  Widget _heroBar(double h, double opacity) => Container(
    width: 4.w,
    height: h,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(2.r),
    ),
  );

  Widget _buildFormItem({required int index, required Widget child}) {
    return FadeTransition(
      opacity: _itemOpacity[index],
      child: SlideTransition(position: _itemSlide[index], child: child),
    );
  }

  Widget _buildUserIdField() => _buildField(
      label: 'User ID',
      child: _buildInput(controller: _userIdCtrl, hint: 'Enter your User ID'));

  Widget _buildPasswordField() => _buildField(
    label: 'New Password',
    child: _buildInput(
      controller: _passwordCtrl,
      hint: 'Enter new password',
      obscure: _obscurePassword,
      suffixIcon: GestureDetector(
        onTap: () =>
            setState(() => _obscurePassword = !_obscurePassword),
        child: Icon(
          _obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: _C.muted,
          size: 20.sp,
        ),
      ),
    ),
  );

  Widget _buildRememberRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 20.w,
              height: 20.h,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (v) => setState(() => _rememberMe = v!),
                activeColor: _C.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.r)),
                side: BorderSide(color:AppColors.mainAppColor),
              ),
            ),
            SizedBox(width: 8.w),
            Text('Remember me',
                style: GoogleFonts.dmSans(fontSize: 13.sp, color:AppColors.mainAppColor)),
          ],
        ),
        GestureDetector(
          onTap: () => Get.to(() => const TroubleScreen()),

          child: Text('Trouble Signing in?',
              style: GoogleFonts.dmSans(
                  fontSize: 13.sp,
                  color: _C.blue,
                  fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildField({required String label, required Widget child}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: _C.blue)),
        SizedBox(height: 6.h),
        child,
      ]);

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    Widget? suffixIcon,
  }) =>
      Container(
        height: 52.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(color: _C.border, width: 1.5),
        ),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          style: GoogleFonts.dmSans(fontSize: 15.sp, color: _C.ink),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
            GoogleFonts.dmSans(fontSize: 15.sp, color: _C.placeholder),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
            suffixIcon: suffixIcon != null
                ? Padding(
                padding: EdgeInsets.only(right: 8.w), child: suffixIcon)
                : null,
          ),
        ),
      );

  Widget _buildSignInButton() {
    return GestureDetector(
      // onTap: () => Get.to(() => DashboardScreen()),
      onTap: () => Get.to(() => StationSelectionScreen()),
      child: AnimatedBuilder(
        animation: _shimmerAnim,
        builder: (_, __) => Container(
          height: 54.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: _C.blue,
            borderRadius: BorderRadius.circular(30.r),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.transparent
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(
                      _shimmerAnim.value * MediaQuery.of(context).size.width,
                      0),
                  child: FractionallySizedBox(
                    widthFactor: 0.4,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.2),
                          Colors.transparent,
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
              Text('SIGN IN',
                  style: GoogleFonts.dmSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.2)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeIndicator() => Padding(
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

// =====================
// GRID PAINTER
// =====================
class _GridPainter extends CustomPainter {
  final double offset;
  _GridPainter({required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    const step = 32.0;
    for (double x = -step + (offset % step); x < size.width + step; x += step)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = -step + (offset % step); y < size.height + step; y += step)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.offset != offset;
}