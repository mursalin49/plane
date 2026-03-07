import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:avislap/views/dashboard/dashboard_screen.dart';
import 'package:avislap/views/auth/forget.dart';
import 'package:avislap/views/auth/trouble.dart';

// =====================
// COLORS
// =====================
class _C {
  static const Color blue = Color(0xFF0057FF);
  static const Color ink = Color(0xFF0E0E10);
  static const Color white = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFF8891A4);
  static const Color border = Color(0xFFEAECF2);
  static const Color bg = Color(0xFFF7F8FC);
  static const Color placeholder = Color(0xFFC8CDD9);
}

// =====================
// ENTRY POINT (add to main.dart)
// =====================
// void main() {
//   runApp(const ParallaxApp());
// }
//
// class ParallaxApp extends StatelessWidget {
//   const ParallaxApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: const Size(393, 852),
//       builder: (_, __) => const MaterialApp(
//         debugShowCheckedModeBanner: false,
//         home: SplashScreen(),
//       ),
//     );
//   }
// }

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
  // Logo reveal
  late AnimationController _logoCtrl;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _logoSlide;

  // Bars scale up
  late AnimationController _bar1Ctrl;
  late AnimationController _bar2Ctrl;
  late AnimationController _bar3Ctrl;
  late Animation<double> _bar1Scale;
  late Animation<double> _bar2Scale;
  late Animation<double> _bar3Scale;

  // Word slide up
  late AnimationController _wordCtrl;
  late Animation<Offset> _wordSlide;

  // Splash exit
  late AnimationController _exitCtrl;
  late Animation<double> _exitOpacity;
  late Animation<double> _exitScale;

  @override
  void initState() {
    super.initState();

    // Logo container
    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _logoOpacity =
        Tween<double>(begin: 0, end: 1).animate(_logoCtrl);
    _logoSlide = Tween<Offset>(
            begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _logoCtrl, curve: Curves.easeOutExpo));

    // Bars
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

    // Word
    _wordCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _wordSlide = Tween<Offset>(
            begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _wordCtrl, curve: Curves.easeOutExpo));

    // Exit
    _exitCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
    _exitOpacity =
        Tween<double>(begin: 1, end: 0).animate(_exitCtrl);
    _exitScale =
        Tween<double>(begin: 1, end: 1.03).animate(_exitCtrl);

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

    // Exit after total animation time
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
        builder: (context, child) {
          return Opacity(
            opacity: _exitOpacity.value,
            child: Transform.scale(
              scale: _exitScale.value,
              child: child,
            ),
          );
        },
        child: Center(
          child: AnimatedBuilder(
            animation: _logoCtrl,
            builder: (context, _) {
              return FadeTransition(
                opacity: _logoOpacity,
                child: SlideTransition(
                  position: _logoSlide,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo mark — 3 bars
                      _buildLogoMark(),
                      SizedBox(height: 14.h),
                      // Word "Parallax"
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
              );
            },
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
      builder: (_, __) {
        return Align(
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
        );
      },
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

  // Hero section animation
  late AnimationController _heroCtrl;
  late Animation<double> _heroOpacity;
  late Animation<Offset> _heroSlide;

  // Staggered form items
  late AnimationController _formCtrl;
  late List<Animation<double>> _itemOpacity;
  late List<Animation<Offset>> _itemSlide;

  // Shimmer on button
  late AnimationController _shimmerCtrl;
  late Animation<double> _shimmerAnim;

  // Grid drift
  late AnimationController _gridCtrl;

  @override
  void initState() {
    super.initState();

    // Hero
    _heroCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _heroOpacity =
        Tween<double>(begin: 0, end: 1).animate(_heroCtrl);
    _heroSlide = Tween<Offset>(
            begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _heroCtrl, curve: Curves.easeOutExpo));

    // Form stagger — 5 items
    _formCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _itemOpacity = List.generate(
        5,
        (i) => Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(
                parent: _formCtrl,
                curve: Interval(i * 0.1, i * 0.1 + 0.55,
                    curve: Curves.easeOutExpo),
              ),
            ));
    _itemSlide = List.generate(
        5,
        (i) => Tween<Offset>(
                begin: const Offset(0, 0.5), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _formCtrl,
                curve: Interval(i * 0.1, i * 0.1 + 0.55,
                    curve: Curves.easeOutExpo),
              ),
            ));

    // Shimmer
    _shimmerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3200))
      ..repeat();
    _shimmerAnim = Tween<double>(begin: -1.5, end: 2.5)
        .animate(_shimmerCtrl);

    // Grid drift
    _gridCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 18))
      ..repeat();

    // Start
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
    _gridCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      backgroundColor: _C.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // ── Hero Section ─────────────────────────
            FadeTransition(
              opacity: _heroOpacity,
              child: SlideTransition(
                position: _heroSlide,
                child: _buildHero(),
              ),
            ),

            // ── Form Body ────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding:
                    EdgeInsets.fromLTRB(28.w, 28.h, 28.w, 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Form intro
                    _buildFormItem(
                      index: 0,
                      child: _buildFormIntro(),
                    ),
                    SizedBox(height: 18.h),

                    // User ID field
                    _buildFormItem(
                      index: 1,
                      child: _buildUserIdField(),
                    ),
                    SizedBox(height: 14.h),

                    // Password field
                    _buildFormItem(
                      index: 2,
                      child: _buildPasswordField(),
                    ),
                    SizedBox(height: 18.h),

                    // Sign in button
                    _buildFormItem(
                      index: 3,
                      child: _buildSignInButton(),
                    ),
                    SizedBox(height: 14.h),

                    // Trouble link
                    _buildFormItem(
                      index: 4,
                      child: _buildFooterLinks(),
                    ),
                    SizedBox(height: 16.h),

                    // Terms
                    Center(
                      child: Text.rich(
                        TextSpan(
                          text: 'By signing in you agree to our ',
                          style: GoogleFonts.dmSans(
                            fontSize: 12.sp,
                            color: _C.placeholder,
                          ),
                          children: [
                            TextSpan(
                              text: 'Terms',
                              style: TextStyle(color: _C.muted),
                            ),
                            const TextSpan(text: ' & '),
                            TextSpan(
                              text: 'Privacy',
                              style: TextStyle(color: _C.muted),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Home indicator
            _buildHomeIndicator(),
          ],
        ),
      ),
    );
  }

  // ── Hero ─────────────────────────────────────────────────
  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(28.w, 28.h, 28.w, 32.h),
      decoration: const BoxDecoration(
        color: _C.blue,
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Animated grid
          Positioned.fill(child: _buildGrid()),

          // Orbs
          Positioned(
            top: -60.h,
            right: -40.w,
            child: _buildOrb(200.w, delay: 0),
          ),
          Positioned(
            top: -10.h,
            right: 55.w,
            child: _buildOrb(130.w, delay: 2500),
          ),
          Positioned(
            bottom: -15.h,
            left: 24.w,
            child: _buildOrb(80.w, delay: 1300),
          ),

          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroMark(),
                  SizedBox(height: 10.h),
                  Text(
                    'Parallax',
                    style: GoogleFonts.dmSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Heading
              Text.rich(
                TextSpan(
                  text: 'Welcome\n',
                  style: GoogleFonts.dmSans(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    letterSpacing: -0.65,
                    height: 1.2,
                  ),
                  children: [
                    TextSpan(
                      text: 'back.',
                      style: GoogleFonts.dmSans(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: -0.65,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return AnimatedBuilder(
      animation: _gridCtrl,
      builder: (_, __) {
        final offset = _gridCtrl.value * 32;
        return CustomPaint(
          painter: _GridPainter(offset: offset),
        );
      },
    );
  }

  Widget _buildOrb(double size, {required int delay}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 0.9),
      duration: const Duration(milliseconds: 5000),
      curve: Curves.easeInOut,
      builder: (_, v, __) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: v * 0.1),
              width: 1,
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroMark() {
    return SizedBox(
      height: 22.h,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
              width: 5.w,
              height: 22.h,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(1.5.r))),
          SizedBox(width: 4.w),
          Container(
              width: 5.w,
              height: 17.h,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(1.5.r))),
          SizedBox(width: 4.w),
          Container(
              width: 5.w,
              height: 12.h,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(1.5.r))),
        ],
      ),
    );
  }

  // ── Form Items ───────────────────────────────────────────
  Widget _buildFormItem(
      {required int index, required Widget child}) {
    return FadeTransition(
      opacity: _itemOpacity[index],
      child: SlideTransition(
        position: _itemSlide[index],
        child: child,
      ),
    );
  }

  Widget _buildFormIntro() {
    return Text(
      'Sign in',
      style: GoogleFonts.dmSans(
        fontSize: 20.sp,
        fontWeight: FontWeight.w500,
        color: _C.ink,
        letterSpacing: -0.4,
      ),
    );
  }

  Widget _buildUserIdField() {
    return _buildField(
      label: 'USER ID',
      child: _buildInput(
        controller: _userIdCtrl,
        hint: 'Enter your user ID',
        keyboardType: TextInputType.text,
      ),
    );
  }

  Widget _buildPasswordField() {
    return _buildField(
      label: 'PASSWORD',
      trailing: GestureDetector(
        onTap: () => Get.to(() => ForgotPasswordScreen()),
        child: Text(
          'Forgot?',
          style: GoogleFonts.dmSans(
            fontSize: 12.sp,
            color: _C.blue,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      child: _buildInput(
        controller: _passwordCtrl,
        hint: '••••••••',
        obscure: _obscurePassword,
        suffixIcon: GestureDetector(
          onTap: () =>
              setState(() => _obscurePassword = !_obscurePassword),
          child: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: _C.muted,
            size: 18.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required Widget child,
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: _C.ink,
                letterSpacing: 0.04 * 11,
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
        SizedBox(height: 5.h),
        child,
      ],
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Focus(
      child: Builder(builder: (ctx) {
        final focused = Focus.of(ctx).hasFocus;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 50.h,
          transform: focused
              ? (Matrix4.identity()..scale(1.015))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: _C.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: focused ? _C.blue : _C.border,
              width: 1.5,
            ),
            boxShadow: focused
                ? [
                    BoxShadow(
                      color: _C.blue.withValues(alpha: 0.09),
                      blurRadius: 0,
                      spreadRadius: 4,
                    )
                  ]
                : [],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            style: GoogleFonts.dmSans(
              fontSize: 15.sp,
              color: _C.ink,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.dmSans(
                fontSize: 15.sp,
                color: _C.placeholder,
              ),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w),
              suffixIcon: suffixIcon,
            ),
          ),
        );
      }),
    );
  }

  // ── Sign In Button with shimmer ──────────────────────────
  Widget _buildSignInButton() {
    return GestureDetector(
      onTap: () {
        Get.to(() => DashboardScreen());
      },
      child: AnimatedBuilder(
        animation: _shimmerAnim,
        builder: (_, __) {
          return Container(
            height: 54.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _C.blue,
              borderRadius: BorderRadius.circular(14.r),
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Top gloss
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Shimmer sweep
                Positioned.fill(
                  child: Transform.translate(
                    offset: Offset(
                        _shimmerAnim.value *
                            MediaQuery.of(context).size.width,
                        0),
                    child: FractionallySizedBox(
                      widthFactor: 0.4,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white
                                  .withValues(alpha: 0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Label
                Text(
                  'Sign in to Parallax',
                  style: GoogleFonts.dmSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooterLinks() {
    return Center(
      child: GestureDetector(
        onTap: () => Get.to(() => trouble()),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Trouble signing in?',
              style: GoogleFonts.dmSans(
                fontSize: 13.sp,
                color: _C.blue,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildHomeIndicator() {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Center(
        child: Container(
          width: 134.w,
          height: 5.h,
          decoration: BoxDecoration(
            color: _C.ink.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(3.r),
          ),
        ),
      ),
    );
  }
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

    // Vertical lines
    for (double x = -step + (offset % step); x < size.width + step; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    // Horizontal lines
    for (double y = -step + (offset % step); y < size.height + step; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.offset != offset;
}
