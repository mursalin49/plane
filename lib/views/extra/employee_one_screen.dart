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
  static const Color employeeNameColor = Color(0xFF4CAF50);
  static const Color divider = Color(0xFFEEEEEE);
}

// =====================
// MODEL
// =====================
class EmployeeOneOnOneItem {
  final String id;
  final String reporterName;
  final String date;
  final String time;
  final String employeeName;
  final String signatureImage;
  final String? avatarImage;

  EmployeeOneOnOneItem({
    required this.id,
    required this.reporterName,
    required this.date,
    required this.time,
    required this.employeeName,
    required this.signatureImage,
    this.avatarImage,
  });
}

// =====================
// CONTROLLER
// =====================
class EmployeeOneOnOneController extends GetxController {
  final RxList<EmployeeOneOnOneItem> items =
      <EmployeeOneOnOneItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    items.assignAll([
      EmployeeOneOnOneItem(
        id: '1',
        reporterName: 'Jane Cooper',
        date: 'Dec 15, 2024',
        time: '2:30 PM',
        employeeName: 'Adam West',
        signatureImage: 'assets/images/signature.png',
        avatarImage: 'assets/images/nirob.jpg',
      ),
      EmployeeOneOnOneItem(
        id: '2',
        reporterName: 'Jane Cooper',
        date: 'Dec 15, 2024',
        time: '2:30 PM',
        employeeName: 'Adam West',
        signatureImage: 'assets/images/signature.png',
      ),
      EmployeeOneOnOneItem(
        id: '3',
        reporterName: 'Jane Cooper',
        date: 'Dec 15, 2024',
        time: '2:30 PM',
        employeeName: 'Adam West',
        signatureImage: 'assets/images/signature.png',
      ),
      EmployeeOneOnOneItem(
        id: '4',
        reporterName: 'Jane Cooper',
        date: 'Dec 15, 2024',
        time: '2:30 PM',
        employeeName: 'Adam West',
        signatureImage: 'assets/images/signature.png',
      ),
    ]);
  }
}

// =====================
// SCREEN
// =====================
class EmployeeOneOnOneScreen extends StatefulWidget {
  const EmployeeOneOnOneScreen({super.key});

  @override
  State<EmployeeOneOnOneScreen> createState() =>
      _EmployeeOneOnOneScreenState();
}

class _EmployeeOneOnOneScreenState
    extends State<EmployeeOneOnOneScreen> {
  late final EmployeeOneOnOneController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(EmployeeOneOnOneController());
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
                padding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(),
                    SizedBox(height: 16.h),
                    _buildItemList(),
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
              'Employee 1:1',
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
          'Past 1:1',
          style: GoogleFonts.poppins(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: _Colors.textDark,
          ),
        ),
      ],
    );
  }

  // ── Item List ────────────────────────────────────────────
  Widget _buildItemList() {
    return Obx(() => ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.items.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, color: _Colors.divider),
      itemBuilder: (context, index) {
        return _buildCard(controller.items[index]);
      },
    ));
  }

  // ── Card ─────────────────────────────────────────────────
  Widget _buildCard(EmployeeOneOnOneItem item) {
    return Container(
      color: _Colors.cardBg,
      padding:
      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reporter name
                Text(
                  item.reporterName,
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
                      padding:
                      EdgeInsets.symmetric(horizontal: 5.w),
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

                // Empl's Name
                Row(
                  children: [
                    Text(
                      "Empl's Name : ",
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: _Colors.textDark,
                      ),
                    ),
                    Text(
                      item.employeeName,
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: _Colors.employeeNameColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),

          // Right: signature + optional avatar
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Signature image
              Image.asset(
                item.signatureImage,
                width: 90.w,
                height: 36.h,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: 90.w,
                  height: 36.h,
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Signature',
                    style: GoogleFonts.dancingScript != null
                        ? GoogleFonts.getFont(
                      'Dancing Script',
                      fontSize: 18.sp,
                      color: _Colors.textDark,
                    )
                        : TextStyle(
                      fontSize: 18.sp,
                      fontStyle: FontStyle.italic,
                      color: _Colors.textDark,
                    ),
                  ),
                ),
              ),

              // Avatar (only first item has it per UI)
              if (item.avatarImage != null) ...[
                SizedBox(height: 4.h),
                CircleAvatar(
                  radius: 16.r,
                  backgroundImage: AssetImage(item.avatarImage!),
                  backgroundColor: Colors.grey.shade200,
                  onBackgroundImageError: (_, __) {},
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}