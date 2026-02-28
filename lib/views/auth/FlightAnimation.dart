import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../CabinAudit.dart';

class FlightAnimation extends StatefulWidget {
  @override
  _FlightAnimationState createState() => _FlightAnimationState();
}

class _FlightAnimationState extends State<FlightAnimation> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _planeFloatController;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15), // মেঘের গতি
    )..repeat();

    _planeFloatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    // Navigate to CabinAuditScreen after 3 seconds
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted) {
        Get.off(() => CabinAuditScreen());
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _planeFloatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _mainController,
        builder: (context, child) {
          return Stack(
            children: [
              // ১. এই মেঘটি বাম থেকে ডানে যাবে (Left to Right)
              _buildCloud(
                image: 'assets/images/small_cloud.png',
                width: 180,
                speed: 0.5,
                fromLeft: true, // ডিরেকশন কন্ট্রোল
                top: 150,
              ),

              // ২. প্লেন (আপনার ডিজাইন অনুযায়ী ডান থেকে বাম-উপরে যাচ্ছে)
              _buildMovingPlane(),

              // ৩. এই মেঘটি ডান থেকে বামে যাবে (Right to Left)
              _buildCloud(
                image: 'assets/images/big_cloud.png',
                width: 350,
                speed: 1.2,
                fromLeft: true,
                bottom: 100,
              ),

              // ৪. আরেকটি ছোট মেঘ বাম থেকে ডানে (নিচের দিকে)
              _buildCloud(
                image: 'assets/images/small_cloud.png',
                width: 120,
                speed: 0.7,
                fromLeft: true,
                top: 500,
              ),
            ],
          );
        },
      ),
    );
  }

  // ডিরেকশন ভিত্তিক মেঘ তৈরির মেথড
  Widget _buildCloud({
    required String image,
    required double width,
    required double speed,
    required bool fromLeft,
    double? top,
    double? bottom,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    double progress = (_mainController.value * speed) % 1.0;

    double xPos;
    if (fromLeft) {
      // বাম থেকে ডানে যাওয়ার লজিক
      xPos = (progress * (screenWidth + width)) - width;
    } else {
      // ডান থেকে বামে যাওয়ার লজিক
      xPos = screenWidth - (progress * (screenWidth + width));
    }

    return Positioned(
      left: xPos,
      top: top,
      bottom: bottom,
      child: Image.asset(image, width: width, opacity: const AlwaysStoppedAnimation(0.7)),
    );
  }

  Widget _buildMovingPlane() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double progress = _mainController.value;

    // প্লেন ডান থেকে বাম-উপরে যাবে
    double xPos = screenWidth - (progress * (screenWidth + 300));
    double yPos = (screenHeight * 0.6) - (progress * (screenHeight * 0.4));

    return Positioned(
      left: xPos,
      top: yPos,
      child: AnimatedBuilder(
        animation: _planeFloatController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _planeFloatController.value * 15),
            child: Image.asset('assets/images/plane.png', width: 220),
          );
        },
      ),
    );
  }
}