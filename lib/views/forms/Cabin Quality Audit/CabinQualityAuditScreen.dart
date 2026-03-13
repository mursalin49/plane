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
  static const Color yes = Color(0xFF4CAF50);
  static const Color no = Color(0xFFE53935);
  static const Color divider = Color(0xFFEEEEEE);
  static const Color namePrimary = Color(0xFF1A1A2E);
}

// =====================
// MODEL
// =====================
class CabinAuditDetail {
  final String name;
  final String date;
  final String time;
  final String gate;
  final String type;
  final bool firstClass;
  final bool comfort;
  final bool mainCabin;
  final bool frontGallery;
  final bool backGallery;
  final List<String> pictures;

  CabinAuditDetail({
    required this.name,
    required this.date,
    required this.time,
    required this.gate,
    required this.type,
    required this.firstClass,
    required this.comfort,
    required this.mainCabin,
    required this.frontGallery,
    required this.backGallery,
    required this.pictures,
  });
}

// =====================
// CONTROLLER
// =====================
class CabinQualityAuditController extends GetxController {
  final Rx<CabinAuditDetail> detail = CabinAuditDetail(
    name: 'Sarah Johnson',
    date: 'Dec 15, 2024',
    time: '2:30 PM',
    gate: 'Gate A-12',
    type: 'Character',
    firstClass: true,
    comfort: true,
    mainCabin: false,
    frontGallery: false,
    backGallery: true,
    pictures: [
      'assets/images/indor.png',
      'assets/images/window.png',
      'assets/images/indor.png',
    ],
  ).obs;

  // Date navigation
  final RxString currentDate = 'Dec 15, 2024 • 2:30 PM'.obs;

  void previousDate() {
    // Handle previous date navigation
  }

  void nextDate() {
    // Handle next date navigation
  }
}

// =====================
// SCREEN
// =====================
class CabinQualityAuditScreen extends StatefulWidget {
  const CabinQualityAuditScreen({super.key});

  @override
  State<CabinQualityAuditScreen> createState() =>
      _CabinQualityAuditScreenState();
}

class _CabinQualityAuditScreenState
    extends State<CabinQualityAuditScreen> {
  late final CabinQualityAuditController controller;
  final PageController _pageController = PageController();
  final RxInt _currentPage = 0.obs;

  @override
  void initState() {
    super.initState();
    controller = Get.put(CabinQualityAuditController());
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
                child: Column(
                  children: [
                    _buildDateNavigation(),
                    _buildDetailCard(),
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
      padding:
      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Icon(Icons.arrow_back,
                color: _Colors.primary, size: 22.sp),
          ),
          Expanded(
            child: Text(
              'Cabin Quality Audit',
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

  // ── Date Navigation ──────────────────────────────────────
  Widget _buildDateNavigation() {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: controller.previousDate,
            child: Icon(Icons.chevron_left,
                color: _Colors.primary, size: 24.sp),
          ),
          Text(
            controller.currentDate.value,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: _Colors.primary,
            ),
          ),
          GestureDetector(
            onTap: controller.nextDate,
            child: Icon(Icons.chevron_right,
                color: _Colors.primary, size: 24.sp),
          ),
        ],
      )),
    );
  }

  // ── Detail Card ──────────────────────────────────────────
  Widget _buildDetailCard() {
    return Obx(() {
      final d = controller.detail.value;
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: _Colors.cardBg,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name with blue bar
            Row(
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
                  d.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: _Colors.namePrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // Date & Time
            _buildInfoRow('${d.date} • ${d.time}',
                isGrey: true),
            SizedBox(height: 8.h),

            // Gate
            _buildInfoRow(d.gate),
            SizedBox(height: 8.h),

            Divider(color: _Colors.divider, height: 1),
            SizedBox(height: 12.h),

            // Type
            _buildLabelValue('Type', d.type,
                valueColor: _Colors.textDark,
                isUnderline: true),
            SizedBox(height: 10.h),

            // First Class
            _buildLabelBool('First Class', d.firstClass),
            SizedBox(height: 10.h),

            // Comfort
            _buildLabelBool('Comfort', d.comfort),
            SizedBox(height: 10.h),

            // Main Cabin
            _buildLabelBool('Main Cabin', d.mainCabin),
            SizedBox(height: 10.h),

            // Front Gallery
            _buildLabelBool('Front Gallery', d.frontGallery),
            SizedBox(height: 10.h),

            // Back Gallery
            _buildLabelBool('Back Gallery', d.backGallery),
            SizedBox(height: 14.h),

            Divider(color: _Colors.divider, height: 1),
            SizedBox(height: 12.h),

            // Pictures label
            Text(
              'Pictures :',
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: _Colors.textDark,
              ),
            ),
            SizedBox(height: 10.h),

            // Image PageView
            _buildImageSlider(d.pictures),
          ],
        ),
      );
    });
  }

  // ── Info Row (plain text) ────────────────────────────────
  Widget _buildInfoRow(String text, {bool isGrey = false}) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 13.sp,
        color: isGrey ? _Colors.textGrey : _Colors.textDark,
      ),
    );
  }

  // ── Label : Value (with optional underline) ──────────────
  Widget _buildLabelValue(
      String label,
      String value, {
        required Color valueColor,
        bool isUnderline = false,
      }) {
    return Row(
      children: [
        Text(
          '$label : ',
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            color: _Colors.textDark,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            color: valueColor,
            decoration: isUnderline
                ? TextDecoration.underline
                : TextDecoration.none,
          ),
        ),
      ],
    );
  }

  // ── Label : YES / NO ─────────────────────────────────────
  Widget _buildLabelBool(String label, bool value) {
    return _buildLabelValue(
      label,
      value ? 'YES' : 'NO',
      valueColor: value ? _Colors.yes : _Colors.no,
    );
  }

  // ── Image Slider ─────────────────────────────────────────
  Widget _buildImageSlider(List<String> images) {
    return Column(
      children: [
        SizedBox(
          height: 180.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) => _currentPage.value = index,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.asset(
                  images[index],
                  width: double.infinity,
                  height: 180.h,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: double.infinity,
                    height: 180.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(Icons.image_outlined,
                        color: Colors.grey.shade400, size: 40.sp),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 10.h),

        // Dot indicators
        Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(images.length, (index) {
            final isActive = _currentPage.value == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              width: isActive ? 18.w : 6.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: isActive
                    ? _Colors.primary
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3.r),
              ),
            );
          }),
        )),
        SizedBox(height: 8.h),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}