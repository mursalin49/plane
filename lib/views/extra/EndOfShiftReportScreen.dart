import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// =====================
// COLORS
// =====================
class _Colors {
  static const Color primary = Color(0xFF3D5AFE);
  static const Color background = Color(0xFFF5F6FA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF9E9E9E);
  static const Color dotColor = Color(0xFF9E9E9E);
  static const Color namePrimary = Color(0xFF3D5AFE);
  static const Color divider = Color(0xFFEEEEEE);
  static const Color completed = Color(0xFF4CAF50);
  static const Color incomplete = Color(0xFFE53935);
  static const Color noColor = Color(0xFF4CAF50);
}

// =====================
// MODEL
// =====================
class ShiftReportItem {
  final String id;
  final String observerName;
  final String observerImage;
  final String date;
  final String time;
  final String locationImage;
  final String locationImage2;
  final bool qaCompleted;
  final bool lavObsCompleted;
  final bool hasDelays;

  ShiftReportItem({
    required this.id,
    required this.observerName,
    required this.observerImage,
    required this.date,
    required this.time,
    required this.locationImage,
    required this.locationImage2,
    required this.qaCompleted,
    required this.lavObsCompleted,
    required this.hasDelays,
  });
}

// =====================
// CONTROLLER
// =====================
class EndOfShiftController extends GetxController {
  final RxList<ShiftReportItem> reports = <ShiftReportItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    reports.assignAll([
      ShiftReportItem(
        id: '1',
        observerName: 'Jane Cooper',
        observerImage: 'assets/images/nirob.jpg',
        date: 'Dec 15, 2024',
        time: '2:30 PM',
        locationImage: 'assets/images/indor.png',
        locationImage2: 'assets/images/window.png',
        qaCompleted: true,
        lavObsCompleted: false,
        hasDelays: false,
      ),
      ShiftReportItem(
        id: '2',
        observerName: 'Jane Cooper',
        observerImage: 'assets/images/mursalin.jpg',
        date: 'Dec 15, 2024',
        time: '2:30 PM',
        locationImage: 'assets/images/indor.png',
        locationImage2: 'assets/images/window.png',
        qaCompleted: true,
        lavObsCompleted: false,
        hasDelays: false,
      ),
      ShiftReportItem(
        id: '3',
        observerName: 'Jane Cooper',
        observerImage: 'assets/images/nirob.jpg',
        date: 'Dec 15, 2024',
        time: '2:30 PM',
        locationImage: 'assets/images/indor.png',
        locationImage2: 'assets/images/window.png',
        qaCompleted: true,
        lavObsCompleted: false,
        hasDelays: false,
      ),
    ]);
  }
}

// =====================
// SCREEN
// =====================
class EndOfShiftReportScreen extends StatefulWidget {
  const EndOfShiftReportScreen({super.key});

  @override
  State<EndOfShiftReportScreen> createState() =>
      _EndOfShiftReportScreenState();
}

class _EndOfShiftReportScreenState extends State<EndOfShiftReportScreen> {
  late final EndOfShiftController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(EndOfShiftController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(),
                    SizedBox(height: 12.h),
                    _buildReportList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── App Bar ─────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child:
            Icon(Icons.arrow_back, color: _Colors.primary, size: 22.sp),
          ),
          Expanded(
            child: Text(
              'End of shift report',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: _Colors.primary,
              ),
            ),
          ),
          Icon(Icons.add_circle_outline,
              color: _Colors.primary, size: 24.sp),
        ],
      ),
    );
  }

  // ── Section Header ───────────────────────────────────────
  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 22.h,
          decoration: BoxDecoration(
            color: _Colors.primary,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          'Past Reports',
          style: GoogleFonts.poppins(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: _Colors.textDark,
          ),
        ),
      ],
    );
  }

  // ── Report List ──────────────────────────────────────────
  Widget _buildReportList() {
    return Obx(() {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.reports.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: _Colors.divider),
        itemBuilder: (context, index) {
          return _buildReportCard(controller.reports[index]);
        },
      );
    });
  }

  // ── Report Card ──────────────────────────────────────────
  Widget _buildReportCard(ShiftReportItem item) {
    return Container(
      color: _Colors.cardBg,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar with blue border + green dot
          Stack(
            children: [
              Container(
                padding: EdgeInsets.all(3.r),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _Colors.primary,
                    width: 2.5.w,
                  ),
                ),
                child: CircleAvatar(
                  radius: 26.r,
                  backgroundImage: AssetImage(item.observerImage),
                  backgroundColor: Colors.grey.shade200,
                  onBackgroundImageError: (_, __) {},
                ),
              ),
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  width: 13.w,
                  height: 13.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1DB954),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),

          // Middle content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5.h),

                // Name
                Text(
                  item.observerName,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: _Colors.namePrimary,
                  ),
                ),
                SizedBox(height: 6.h),

                // Date • Time
                Row(
                  children: [
                    Text(
                      item.date,
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: _Colors.textGrey,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Container(
                        width: 4.w,
                        height: 4.h,
                        decoration: const BoxDecoration(
                          color: _Colors.dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Text(
                      item.time,
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: _Colors.textGrey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                // QA status
                _buildStatusRow(
                  label: 'QA',
                  value: item.qaCompleted ? 'Completed' : 'Incomplete',
                  color: item.qaCompleted
                      ? _Colors.completed
                      : _Colors.incomplete,
                ),
                SizedBox(height: 5.h),

                // LAV OBS status
                _buildStatusRow(
                  label: 'LAV OBS',
                  value: item.lavObsCompleted ? 'Completed' : 'Incomplete',
                  color: item.lavObsCompleted
                      ? _Colors.completed
                      : _Colors.incomplete,
                ),
                SizedBox(height: 5.h),

                // Delays status
                _buildStatusRow(
                  label: 'Delays',
                  value: item.hasDelays ? 'YES' : 'NO',
                  color: item.hasDelays
                      ? _Colors.incomplete
                      : _Colors.noColor,
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),

          // Two stacked location images
          Column(
            children: [
              _buildLocationImage(item.locationImage),
              SizedBox(height: 6.h),
              _buildLocationImage(item.locationImage2),
            ],
          ),
        ],
      ),
    );
  }

  // ── Status Row ───────────────────────────────────────────
  Widget _buildStatusRow({
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Text(
          '$label : ',
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: _Colors.textDark,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  // ── Location Image ────────────────────────────────────────
  Widget _buildLocationImage(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Image.asset(
        imagePath,
        width: 64.w,
        height: 60.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 64.w,
          height: 60.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.image_outlined,
            color: Colors.grey.shade400,
            size: 24.sp,
          ),
        ),
      ),
    );
  }
}