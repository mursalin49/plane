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
  static const Color pass = Color(0xFF22C55E);
  static const Color fail = Color(0xFFEF4444);
  static const Color na = Color(0xFF9E9E9E);
  static const Color divider = Color(0xFFEEEEEE);
  static const Color namePrimary = Color(0xFF1A1A2E);
  static const Color highlightBg = Color(0xFFEEF2FF);
}

// =====================
// ENUMS & EXTENSIONS
// =====================
enum AuditStatus { pass, fail, na }

extension AuditStatusExt on AuditStatus {
  String get label {
    switch (this) {
      case AuditStatus.pass:
        return 'Pass';
      case AuditStatus.fail:
        return 'Fail';
      case AuditStatus.na:
        return 'N/A';
    }
  }

  Color get color {
    switch (this) {
      case AuditStatus.pass:
        return _Colors.pass;
      case AuditStatus.fail:
        return _Colors.fail;
      case AuditStatus.na:
        return _Colors.na;
    }
  }

  IconData get icon {
    switch (this) {
      case AuditStatus.pass:
        return Icons.check_circle_rounded;
      case AuditStatus.fail:
        return Icons.cancel_rounded;
      case AuditStatus.na:
        return Icons.remove_circle_outline_rounded;
    }
  }
}

// =====================
// MODELS
// =====================
class CheckItemResult {
  final String itemName;
  final AuditStatus status;

  CheckItemResult({required this.itemName, required this.status});
}

class AuditedAreaResult {
  final String areaId;
  final String sectionLabel;
  final List<CheckItemResult> checkItems;

  AuditedAreaResult({
    required this.areaId,
    required this.sectionLabel,
    required this.checkItems,
  });

  AuditStatus get overallStatus {
    if (checkItems.any((c) => c.status == AuditStatus.fail)) {
      return AuditStatus.fail;
    }
    if (checkItems.any((c) => c.status == AuditStatus.pass)) {
      return AuditStatus.pass;
    }
    return AuditStatus.na;
  }

  int get passCount =>
      checkItems.where((c) => c.status == AuditStatus.pass).length;
  int get failCount =>
      checkItems.where((c) => c.status == AuditStatus.fail).length;
  int get naCount => checkItems.where((c) => c.status == AuditStatus.na).length;
}

class CabinAuditDetailModel {
  final String auditorName;
  final String date;
  final String time;
  final String gate;
  final String type;
  final String tailNumber;
  final List<AuditedAreaResult> auditedAreas;
  final List<String> pictures;
  final String? notes;

  CabinAuditDetailModel({
    required this.auditorName,
    required this.date,
    required this.time,
    required this.gate,
    required this.type,
    required this.tailNumber,
    required this.auditedAreas,
    required this.pictures,
    this.notes,
  });

  double get scorePercent {
    int total = 0;
    int passed = 0;
    for (final area in auditedAreas) {
      for (final item in area.checkItems) {
        if (item.status != AuditStatus.na) {
          total++;
          if (item.status == AuditStatus.pass) passed++;
        }
      }
    }
    if (total == 0) return 0;
    return (passed / total) * 100;
  }
}

// =====================
// CONTROLLER
// =====================
class CabinQualityAuditController extends GetxController {
  final Rx<CabinAuditDetailModel> detail = CabinAuditDetailModel(
    auditorName: 'Sarah Johnson',
    date: 'Dec 15, 2024',
    time: '2:30 PM',
    gate: 'Gate A-12',
    type: 'Charter',
    tailNumber: 'N123DL',
    notes:
        'Overall cabin was in acceptable condition. '
        'Row 22C tray table latch was broken.',
    pictures: [
      'assets/images/indor.png',
      'assets/images/window.png',
      'assets/images/indor.png',
    ],
    auditedAreas: [
      AuditedAreaResult(
        areaId: '1A',
        sectionLabel: 'First Class',
        checkItems: [
          CheckItemResult(itemName: 'Seatbelt', status: AuditStatus.pass),
          CheckItemResult(itemName: 'Tray Table', status: AuditStatus.pass),
          CheckItemResult(itemName: 'IFE Screen', status: AuditStatus.pass),
          CheckItemResult(
            itemName: 'Seat Back Trash',
            status: AuditStatus.pass,
          ),
          CheckItemResult(itemName: 'Overhead Bin', status: AuditStatus.pass),
          CheckItemResult(itemName: 'Carpet', status: AuditStatus.pass),
          CheckItemResult(itemName: 'Window', status: AuditStatus.na),
        ],
      ),
      AuditedAreaResult(
        areaId: '15B',
        sectionLabel: 'Comfort+',
        checkItems: [
          CheckItemResult(itemName: 'Seatbelt', status: AuditStatus.pass),
          CheckItemResult(itemName: 'Tray Table', status: AuditStatus.fail),
          CheckItemResult(itemName: 'IFE Screen', status: AuditStatus.pass),
          CheckItemResult(
            itemName: 'Seat Back Trash',
            status: AuditStatus.pass,
          ),
          CheckItemResult(itemName: 'Overhead Bin', status: AuditStatus.pass),
          CheckItemResult(itemName: 'Carpet', status: AuditStatus.pass),
          CheckItemResult(itemName: 'Window', status: AuditStatus.pass),
        ],
      ),
      AuditedAreaResult(
        areaId: '22C',
        sectionLabel: 'Main Cabin',
        checkItems: [
          CheckItemResult(itemName: 'Seatbelt', status: AuditStatus.pass),
          CheckItemResult(itemName: 'Tray Table', status: AuditStatus.fail),
          CheckItemResult(itemName: 'IFE Screen', status: AuditStatus.pass),
          CheckItemResult(
            itemName: 'Seat Back Trash',
            status: AuditStatus.fail,
          ),
          CheckItemResult(itemName: 'Overhead Bin', status: AuditStatus.pass),
          CheckItemResult(itemName: 'Carpet', status: AuditStatus.pass),
          CheckItemResult(itemName: 'Window', status: AuditStatus.pass),
        ],
      ),
      AuditedAreaResult(
        areaId: 'LAV FWD',
        sectionLabel: 'Lav',
        checkItems: [
          CheckItemResult(itemName: 'Cleanliness', status: AuditStatus.pass),
          CheckItemResult(itemName: 'Toilet / Seat', status: AuditStatus.pass),
          CheckItemResult(itemName: 'Sink & Faucet', status: AuditStatus.pass),
          CheckItemResult(itemName: 'Mirror', status: AuditStatus.pass),
          CheckItemResult(
            itemName: 'Trash Receptacle',
            status: AuditStatus.pass,
          ),
          CheckItemResult(
            itemName: 'Soap / Supplies Stocked',
            status: AuditStatus.fail,
          ),
          CheckItemResult(itemName: 'No Odor', status: AuditStatus.pass),
        ],
      ),
      AuditedAreaResult(
        areaId: 'Galley FWD',
        sectionLabel: 'Galley',
        checkItems: [
          CheckItemResult(
            itemName: 'Counter Cleanliness',
            status: AuditStatus.pass,
          ),
          CheckItemResult(
            itemName: 'Trash Receptacle',
            status: AuditStatus.pass,
          ),
          CheckItemResult(
            itemName: 'Compartment / Drawers',
            status: AuditStatus.pass,
          ),
          CheckItemResult(
            itemName: 'Equipment Condition',
            status: AuditStatus.pass,
          ),
          CheckItemResult(itemName: 'No Odor', status: AuditStatus.pass),
          CheckItemResult(itemName: 'Floor', status: AuditStatus.pass),
        ],
      ),
    ],
  ).obs;

  final RxString currentDate = 'Dec 15, 2024 • 2:30 PM'.obs;
  final RxInt expandedAreaIndex = RxInt(-1);

  void previousDate() {}
  void nextDate() {}

  void toggleArea(int index) {
    expandedAreaIndex.value = expandedAreaIndex.value == index ? -1 : index;
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

class _CabinQualityAuditScreenState extends State<CabinQualityAuditScreen> {
  late final CabinQualityAuditController controller;
  final PageController _pageController = PageController();
  final RxInt _currentPage = 0.obs;

  @override
  void initState() {
    super.initState();
    controller = Get.put(CabinQualityAuditController());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
                    _buildScoreCard(),
                    _buildInfoCard(),
                    _buildAuditedAreasList(),
                    _buildPicturesCard(),
                    _buildNotesCard(),
                    SizedBox(height: 24.h),
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
            child: Icon(Icons.arrow_back, color: _Colors.primary, size: 22.sp),
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
          Icon(Icons.add_circle_outline, color: _Colors.primary, size: 24.sp),
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
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: controller.previousDate,
              child: Icon(
                Icons.chevron_left,
                color: _Colors.primary,
                size: 24.sp,
              ),
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
              child: Icon(
                Icons.chevron_right,
                color: _Colors.primary,
                size: 24.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Score Card ───────────────────────────────────────────
  Widget _buildScoreCard() {
    return Obx(() {
      final d = controller.detail.value;
      final score = d.scorePercent;
      final isGood = score >= 80;
      final scoreColor = isGood ? _Colors.pass : _Colors.fail;

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: scoreColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 64.w,
              height: 64.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scoreColor,
              ),
              child: Center(
                child: Text(
                  '${score.toStringAsFixed(0)}%',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isGood ? 'Audit Passed' : 'Audit Failed',
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: scoreColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${d.auditedAreas.length} areas audited  •  '
                    '${d.auditedAreas.where((a) => a.overallStatus == AuditStatus.fail).length} failed',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: _Colors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── Info Card ────────────────────────────────────────────
  Widget _buildInfoCard() {
    return Obx(() {
      final d = controller.detail.value;
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
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
                  d.auditorName,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: _Colors.namePrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            _infoRow('${d.date}  •  ${d.time}', isGrey: true),
            SizedBox(height: 8.h),
            _infoRow(d.gate),
            SizedBox(height: 10.h),
            Divider(color: _Colors.divider, height: 1),
            SizedBox(height: 12.h),
            _labelValue('Type', d.type),
            SizedBox(height: 8.h),
            _labelValue('Tail Number', d.tailNumber),
          ],
        ),
      );
    });
  }

  // ── Audited Areas List ───────────────────────────────────
  Widget _buildAuditedAreasList() {
    return Obx(() {
      final d = controller.detail.value;
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: _Colors.cardBg,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  Container(
                    width: 4.w,
                    height: 20.h,
                    decoration: BoxDecoration(
                      color: _Colors.primary,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Audited Areas',
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: _Colors.namePrimary,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: _Colors.divider),
            ...List.generate(d.auditedAreas.length, (index) {
              final area = d.auditedAreas[index];
              final isExpanded = controller.expandedAreaIndex.value == index;
              return _buildAreaTile(area, index, isExpanded);
            }),
            SizedBox(height: 4.h),
          ],
        ),
      );
    });
  }

  Widget _buildAreaTile(AuditedAreaResult area, int index, bool isExpanded) {
    final overall = area.overallStatus;
    return Column(
      children: [
        InkWell(
          onTap: () => controller.toggleArea(index),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Container(
                  width: 38.w,
                  height: 38.h,
                  decoration: BoxDecoration(
                    color: _Colors.highlightBg,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    _sectionIcon(area.sectionLabel),
                    color: _Colors.primary,
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        area.sectionLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: _Colors.namePrimary,
                        ),
                      ),
                      Text(
                        'Area: ${area.areaId}  •  '
                        '${area.passCount}P  ${area.failCount}F  ${area.naCount}N/A',
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: _Colors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                _statusBadge(overall),
                SizedBox(width: 8.w),
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: _Colors.textGrey,
                    size: 20.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) _buildExpandedItems(area),
        Divider(height: 1, color: _Colors.divider),
      ],
    );
  }

  Widget _buildExpandedItems(AuditedAreaResult area) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: _Colors.background,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: area.checkItems.map((item) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 5.h),
            child: Row(
              children: [
                Icon(item.status.icon, color: item.status.color, size: 16.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    item.itemName,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: _Colors.namePrimary,
                    ),
                  ),
                ),
                _statusChip(item.status),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Pictures Card ────────────────────────────────────────
  Widget _buildPicturesCard() {
    return Obx(() {
      final d = controller.detail.value;
      if (d.pictures.isEmpty) return const SizedBox.shrink();
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: _Colors.cardBg,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Pictures'),
            SizedBox(height: 12.h),
            _buildImageSlider(d.pictures),
          ],
        ),
      );
    });
  }

  // ── Notes Card ───────────────────────────────────────────
  Widget _buildNotesCard() {
    return Obx(() {
      final d = controller.detail.value;
      if (d.notes == null || d.notes!.isEmpty) {
        return const SizedBox.shrink();
      }
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: _Colors.cardBg,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Notes & Findings'),
            SizedBox(height: 10.h),
            Text(
              d.notes!,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: _Colors.textGrey,
                height: 1.6,
              ),
            ),
          ],
        ),
      );
    });
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
            onPageChanged: (i) => _currentPage.value = i,
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
                    child: Icon(
                      Icons.image_outlined,
                      color: Colors.grey.shade400,
                      size: 40.sp,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 10.h),
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
              final isActive = _currentPage.value == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                width: isActive ? 18.w : 6.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: isActive ? _Colors.primary : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              );
            }),
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  // ── Shared Helper Widgets ────────────────────────────────
  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: _Colors.primary,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: _Colors.namePrimary,
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String text, {bool isGrey = false}) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 13.sp,
        color: isGrey ? _Colors.textGrey : _Colors.namePrimary,
      ),
    );
  }

  Widget _labelValue(String label, String value) {
    return Row(
      children: [
        Text(
          '$label : ',
          style: GoogleFonts.poppins(fontSize: 13.sp, color: _Colors.textGrey),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: _Colors.namePrimary,
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(AuditStatus status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: status.color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        status.label,
        style: GoogleFonts.poppins(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: status.color,
        ),
      ),
    );
  }

  Widget _statusChip(AuditStatus status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        status.label,
        style: GoogleFonts.poppins(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: status.color,
        ),
      ),
    );
  }

  IconData _sectionIcon(String label) {
    switch (label.toLowerCase()) {
      case 'first class':
      case 'business class':
        return Icons.airline_seat_recline_extra_rounded;
      case 'comfort+':
        return Icons.airline_seat_recline_normal_rounded;
      case 'main cabin':
      case 'economy':
        return Icons.weekend_rounded;
      case 'lav':
        return Icons.wc_rounded;
      case 'galley':
        return Icons.restaurant_rounded;
      default:
        return Icons.event_seat_rounded;
    }
  }
}
