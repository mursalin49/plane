import 'package:avislap/controllers/login_controller.dart';
import 'package:avislap/services/api_client.dart';
import 'package:avislap/views/auth/trouble_screen.dart';
import 'package:avislap/views/select_station/select_station.dart';
import 'package:avislap/widgets/parallax_hero_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class _C {
  static const Color blue = Color(0xFF3D5AFE);
  static const Color ink = Color(0xFF0E0E10);
  static const Color muted = Color(0xFF8891A4);
  static const Color border = Color(0xFFEAECF2);
  static const Color placeholder = Color(0xFFC8CDD9);
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final AuthController _authController = AuthController.ensureRegistered();
  final _userIdCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isSubmitting = false;

  late AnimationController _heroCtrl;
  late Animation<double> _heroOpacity;
  late Animation<Offset> _heroSlide;

  late AnimationController _formCtrl;
  late List<Animation<double>> _itemOpacity;
  late List<Animation<Offset>> _itemSlide;

  late AnimationController _shimmerCtrl;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();

    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _heroOpacity = Tween<double>(begin: 0, end: 1).animate(_heroCtrl);
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutExpo));

    _formCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _itemOpacity = List.generate(
      5,
      (index) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _formCtrl,
          curve: Interval(
            index * 0.1,
            index * 0.1 + 0.55,
            curve: Curves.easeOutExpo,
          ),
        ),
      ),
    );
    _itemSlide = List.generate(
      5,
      (index) =>
          Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
            CurvedAnimation(
              parent: _formCtrl,
              curve: Interval(
                index * 0.1,
                index * 0.1 + 0.55,
                curve: Curves.easeOutExpo,
              ),
            ),
          ),
    );

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -1.5, end: 2.5).animate(_shimmerCtrl);

    Future.delayed(const Duration(milliseconds: 80), () {
      if (!mounted) {
        return;
      }
      _heroCtrl.forward();
      _formCtrl.forward();
    });
  }

  @override
  void dispose() {
    _userIdCtrl.dispose();
    _passwordCtrl.dispose();
    _heroCtrl.dispose();
    _formCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final userId = _userIdCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (userId.isEmpty || password.isEmpty) {
      _showError('Enter both User ID and password.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      final target = await _authController.login(
        userId: userId,
        password: password,
        rememberUser: _rememberMe,
      );

      if (!mounted) {
        return;
      }

      switch (target) {
        case AuthLaunchTarget.dashboard:
          Get.offAllNamed('/dashboard');
          break;
        case AuthLaunchTarget.stationSelection:
          Get.offAll(() => const StationSelectionScreen());
          break;
        case AuthLaunchTarget.login:
          _showError('Unable to continue with this account.');
          break;
      }
    } on ApiException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Sign In Failed',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFD92D20),
      colorText: Colors.white,
      margin: EdgeInsets.all(16.w),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          FadeTransition(
            opacity: _heroOpacity,
            child: SlideTransition(
              position: _heroSlide,
              child: ParallaxHeroWidget(
                bottomPadding: 220,
                child: Text(
                  'Sign in to\nyour Account',
                  style: GoogleFonts.dmSans(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.8,
                    height: 1.15,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: 180.h,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, keyboardInset + 24.h),
              child: Container(
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
                    SizedBox(height: 18.h),
                    _buildHomeIndicator(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormItem({required int index, required Widget child}) {
    return FadeTransition(
      opacity: _itemOpacity[index],
      child: SlideTransition(position: _itemSlide[index], child: child),
    );
  }

  Widget _buildUserIdField() => _buildField(
    label: 'User ID',
    child: _buildInput(controller: _userIdCtrl, hint: 'Enter your User ID'),
  );

  Widget _buildPasswordField() => _buildField(
    label: 'Password',
    child: _buildInput(
      controller: _passwordCtrl,
      hint: 'Enter your password',
      obscure: _obscurePassword,
      suffixIcon: GestureDetector(
        onTap: () {
          setState(() => _obscurePassword = !_obscurePassword);
        },
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
                onChanged: (value) {
                  setState(() => _rememberMe = value ?? false);
                },
                activeColor: _C.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
                side: BorderSide(color: _C.blue.withValues(alpha: 0.5)),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'Remember me',
              style: GoogleFonts.dmSans(
                fontSize: 13.sp,
                color: _C.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => Get.to(() => const TroubleScreen()),
          child: Text(
            'Trouble Signing in?',
            style: GoogleFonts.dmSans(
              fontSize: 13.sp,
              color: _C.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: _C.blue,
          ),
        ),
        SizedBox(height: 6.h),
        child,
      ],
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: _C.border, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        textInputAction: obscure ? TextInputAction.done : TextInputAction.next,
        style: GoogleFonts.dmSans(fontSize: 15.sp, color: _C.ink),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.dmSans(fontSize: 15.sp, color: _C.placeholder),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
          suffixIcon: suffixIcon == null
              ? null
              : Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: suffixIcon,
                ),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return GestureDetector(
      onTap: _isSubmitting ? null : _handleSignIn,
      child: AnimatedBuilder(
        animation: _shimmerAnim,
        builder: (context, child) => Container(
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
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              if (!_isSubmitting)
                Positioned.fill(
                  child: Transform.translate(
                    offset: Offset(
                      _shimmerAnim.value * MediaQuery.of(context).size.width,
                      0,
                    ),
                    child: FractionallySizedBox(
                      widthFactor: 0.4,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              _isSubmitting
                  ? SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'SIGN IN',
                      style: GoogleFonts.dmSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
            ],
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
