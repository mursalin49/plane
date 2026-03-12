import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:signature/signature.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import 'CabinSecurityTrainingScreen.dart';

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────
class _C {
  static const Color primary    = Color(0xFF3D5AFE);
  static const Color bg         = Color(0xFFF5F6FA);
  static const Color white      = Color(0xFFFFFFFF);
  static const Color dark       = Color(0xFF1A1A2E);
  static const Color grey       = Color(0xFF8891A4);
  static const Color border     = Color(0xFFE4E7EF);
  static const Color inputBg    = Color(0xFFF9FAFB);
  static const Color seatColor  = Color(0xFF6B7B99);
  static const Color green      = Color(0xFF22C55E);
  static const Color red        = Color(0xFFEF4444);
  static const Color planeGrey  = Color(0xFFEDEFF4);
}

// ─────────────────────────────────────────────
// CONTROLLER
// ─────────────────────────────────────────────
class CabinQualityController extends GetxController {
  final selectedAircraft   = 'Boeing 757-300 (75Y)'.obs;
  final selectedGate       = 'Gate - A'.obs;
  final selectedCleanType  = 'Clean 1'.obs;
  final supervisorName     = ''.obs;
  final auditedSeats       = <String, String>{}.obs; // seatId → 'pass'|'fail'

  final List<String> aircraftOptions  = ['Boeing 757-300 (75Y)', 'Boeing 737-800', 'Airbus A320'];
  final List<String> gateOptions      = ['Gate - A', 'Gate - B', 'Gate - C', 'Gate - D'];

  void markSeat(String id, String status) => auditedSeats[id] = status;
  void clearSeat(String id) => auditedSeats.remove(id);
}

// ─────────────────────────────────────────────
// SCREEN — Step 1 (Job Details)
// ─────────────────────────────────────────────
class CabinQualityAuditScreenN extends StatefulWidget {
  const CabinQualityAuditScreenN({super.key});
  @override State<CabinQualityAuditScreenN> createState() => _CabinQualityAuditScreenNState();
}

class _CabinQualityAuditScreenNState extends State<CabinQualityAuditScreenN> {
  final _ctrl = Get.put(CabinQualityController());
  final _supervisorCtrl = TextEditingController();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  int _step = 0; // 0 = job details, 1 = inspection, 2 = notes/submit

  final RxList<File> _selectedImages = <File>[].obs;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      _selectedImages.addAll(images.map((img) => File(img.path)));
    }
  }

  static String _todayDate() {
    final n = DateTime.now();
    return '${n.month.toString().padLeft(2,'0')}/${n.day.toString().padLeft(2,'0')}/${n.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _buildAppBar(),
      body: _step == 0 ? _buildStep0() :
      _step == 1 ? _buildStep1() :
      _buildStep2(),
    );
  }

  AppBar _buildAppBar() => AppBar(
    backgroundColor: _C.white,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    leading: IconButton(
      icon: Icon(Icons.arrow_back_rounded, color: _C.primary, size: 22.sp),
      onPressed: () => _step > 0 ? setState(() => _step--) : Get.back(),
    ),
    title: Text('Cabin Security Search Training',
        style: GoogleFonts.dmSans(fontSize: 17.sp, fontWeight: FontWeight.w600, color: _C.primary)),
    centerTitle: true,
    actions: [
      IconButton(
        icon: Icon(Icons.info_outline_rounded, color: _C.primary, size: 22.sp),
        onPressed: _showInstructions,
      ),
    ],
  );

  // ── STEP 0: Job Details ───────────────────────────────────
  Widget _buildStep0() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Date and Time *'),
                _pillField(
                  child: Row(children: [
                    Expanded(child: Text(_todayDate(), style: _fieldStyle())),
                    Icon(Icons.calendar_month_outlined, size: 20.sp, color: _C.grey),
                  ]),
                ),
                SizedBox(height: 16.h),
                _label('Supervisor/Lead *'),
                _pillTextField(controller: _supervisorCtrl, hint: 'John Doe'),
                SizedBox(height: 16.h),
                _label('Gate *'),
                Obx(() => _pillDropdown(
                  value: _ctrl.selectedGate.value,
                  items: _ctrl.gateOptions,
                  onChanged: (v) => _ctrl.selectedGate.value = v!,
                )),
                SizedBox(height: 16.h),

              ],
            ),
          ),
        ),
        _nextButton(() => setState(() => _step = 1)),
      ],
    );
  }

  // ── STEP 1: Inspection Checklist + Seat Map ───────────────
  Widget _buildStep1() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24.h),
                Text('Inspection Checklist',
                    style: GoogleFonts.dmSans(fontSize: 20.sp, fontWeight: FontWeight.w700, color: _C.primary)),
                SizedBox(height: 20.h),
                _label('Type of Aircraft *'),
                Obx(() => _pillDropdown(
                  value: _ctrl.selectedAircraft.value,
                  items: _ctrl.aircraftOptions,
                  onChanged: (v) => _ctrl.selectedAircraft.value = v!,
                  suffixIcon: Icons.search_rounded,
                )),
                SizedBox(height: 24.h),
                // Seat map
                _buildSeatMap(),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
        _nextButton(() => setState(() => _step = 2)),
      ],
    );
  }

  // ── STEP 2: Notes + Submit ────────────────────────────────
  Widget _buildStep2() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Other Findings'),
                _multilineField('Enter any additional findings or notes...'),
                SizedBox(height: 16.h),
                _label('Additional Notes'),
                _multilineField('Enter any additional findings or notes...'),
                SizedBox(height: 16.h),
                _label('Pictures'),
                _uploadBox(),
                SizedBox(height: 12.h),
                Obx(() => _selectedImages.isEmpty 
                  ? const SizedBox.shrink() 
                  : Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: _selectedImages.map((file) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Image.file(
                                file,
                                width: 80.w,
                                height: 80.w,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _selectedImages.remove(file),
                                child: Container(
                                  padding: EdgeInsets.all(2.r),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.close, color: Colors.white, size: 14.sp),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                  )
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _label('Signature *'),
                    GestureDetector(
                      onTap: () => _signatureController.clear(),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Text(
                          'Clear',
                          style: GoogleFonts.dmSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: _C.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: _C.border),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Signature(
                      controller: _signatureController,
                      height: 120.h,
                      backgroundColor: _C.inputBg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _submitButton(),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────
  // SEAT MAP
  // ──────────────────────────────────────────────────────────
  Widget _buildSeatMap() {
    return Container(
      decoration: BoxDecoration(
        color: _C.planeGrey,
        borderRadius: BorderRadius.circular(32.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32.r),
        child: CustomPaint(
          painter: _PlaneSilhouettePainter(),
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 40.h),
            child: Column(
              children: [
                // ── NOSE area ──
                SizedBox(height: 60.h),

                // ── First class arc (decorative) ──
                _buildFirstClassArc(),
                SizedBox(height: 12.h),

                // ── Galley + exit row 1 ──
                _buildAmenityRow(
                  leftSvg: 'assets/icons/toilet.svg', leftId: 'LAV FWD',
                  rightSvg: 'assets/icons/chiken.svg', rightId: 'Galley FWD'
                ),
                _buildExitRow(),
                SizedBox(height: 4.h),

                // ── Column headers ABCD ──
                _buildColHeaders(['A', 'B', '', 'C', 'D']),
                SizedBox(height: 4.h),

                // ── Rows 1–6: 2-2 (First/Business) ──
                ...List.generate(6, (i) => _buildSeatRow(
                  rowNum: i + 1,
                  leftCols: ['A', 'B'],
                  rightCols: ['C', 'D'],
                  config: _SeatConfig.normal,
                )),

                SizedBox(height: 16.h),

                // ── Closet row ──
                _buildClosetRow(),

                // ── Galley + lavs ──
                _buildAmenityRow(
                  leftSvg: 'assets/icons/toilet.svg', leftId: 'LAV MID L',
                  rightSvg: 'assets/icons/toilet.svg', rightId: 'LAV MID R'
                ),

                // ── Delta Comfort label ──
                _buildSectionLabel('Delta Comfort'),
                _buildExitRow(),
                SizedBox(height: 4.h),

                // ── Row 14 (2-2, partial) ──
                _buildSeatRow(rowNum: 14, leftCols: ['', ''], rightCols: ['C', 'D'], config: _SeatConfig.normal),

                // ── Rows 15–20: 3-3 ──
                _buildColHeaders(['A', 'B', 'C', '', 'D', 'E', 'F']),
                SizedBox(height: 4.h),
                ...List.generate(7, (i) => _buildSeatRow(
                  rowNum: 15 + i,
                  leftCols: ['A', 'B', 'C'],
                  rightCols: ['D', 'E', 'F'],
                  config: _SeatConfig.normal,
                )),

                SizedBox(height: 16.h),

                // ── Delta Main label ──
                _buildSectionLabel('Delta Main'),

                // ── Rows 21–29: 3-3 ──
                ...List.generate(9, (i) => _buildSeatRow(
                  rowNum: 21 + i,
                  leftCols: ['A', 'B', 'C'],
                  rightCols: ['D', 'E', 'F'],
                  config: _SeatConfig.normal,
                )),

                SizedBox(height: 16.h),

                // ── Exit + rows 40 ──
                _buildSeatRow(rowNum: 40, leftCols: ['A','B','C'], rightCols: ['D','E','F'], config: _SeatConfig.normal),
                _buildAmenityRow(
                  leftSvg: 'assets/icons/toilet.svg', leftId: 'LAV AFT L',
                  rightSvg: 'assets/icons/toilet.svg', rightId: 'LAV AFT R'
                ),
                _buildExitRow(),
                SizedBox(height: 4.h),

                // ── ABC DEF headers ──
                _buildColHeaders(['A', 'B', 'C', '', 'D', 'E', 'F']),
                SizedBox(height: 4.h),

                // ── Rows 41–49 ──
                ...List.generate(9, (i) => _buildSeatRow(
                  rowNum: 41 + i,
                  leftCols: ['A', 'B', 'C'],
                  rightCols: ['D', 'E', 'F'],
                  config: _SeatConfig.normal,
                )),

                SizedBox(height: 16.h),

                // ── Last row + aft galley ──
                _buildExitRow(),
                _buildAmenityRow(
                  rightSvg: 'assets/icons/chiken.svg', rightId: 'Galley AFT', centerOnly: true
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── First class arc (decorative blocks) ──────────────────
  Widget _buildFirstClassArc() {
    return SizedBox(
      height: 120.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Arc of 9 blocks arranged in a semicircle
          ...List.generate(9, (i) {
            final angle = (i / 8) * 3.14159;
            final radius = 72.0;
            final x = -radius * (1 - 2 * i / 8);
            final y = -radius * 0.6 * (0.5 - (i / 8 - 0.5).abs());
            final tilt = (i / 8 - 0.5) * 60;
            return Transform.translate(
              offset: Offset(x * 0.9, y + 30),
              child: Transform.rotate(
                angle: tilt * 3.14159 / 180,
                child: _arcBlock(i),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _arcBlock(int idx) {
    // middle block is taller (trapezoid look)
    final isMid = idx == 4;
    return Container(
      width: isMid ? 28.w : 22.w,
      height: isMid ? 44.h : 36.h,
      decoration: BoxDecoration(
        color: _C.seatColor,
        borderRadius: BorderRadius.circular(6.r),
      ),
    );
  }

  // ── Column headers ────────────────────────────────────────
  Widget _buildColHeaders(List<String> cols) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: cols.map((c) => c.isEmpty
            ? SizedBox(width: 28.w)
            : SizedBox(
          width: 34.w,
          child: Center(
            child: Text(c,
                style: GoogleFonts.dmSans(fontSize: 11.sp, fontWeight: FontWeight.w600, color: _C.grey)),
          ),
        )
        ).toList(),
      ),
    );
  }

  // ── Single seat row ───────────────────────────────────────
  Widget _buildSeatRow({
    required int rowNum,
    required List<String> leftCols,
    required List<String> rightCols,
    required _SeatConfig config,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Left seats
          ...leftCols.map((col) => col.isEmpty
              ? SizedBox(width: 34.w)
              : _seat('$rowNum$col')),
          // Row number
          SizedBox(
            width: 28.w,
            child: Center(
              child: Text('$rowNum',
                  style: GoogleFonts.dmSans(fontSize: 10.sp, fontWeight: FontWeight.w600, color: _C.grey)),
            ),
          ),
          // Right seats
          ...rightCols.map((col) => col.isEmpty
              ? SizedBox(width: 34.w)
              : _seat('$rowNum$col')),
        ],
      ),
    );
  }

  Widget _seat(String id) {
    return Obx(() {
      final status = _ctrl.auditedSeats[id];
      final color = status == 'pass' ? _C.green
          : status == 'fail' ? _C.red
          : _C.seatColor;
      return GestureDetector(
        onTap: () => _showSeatSheet(id),
        child: Container(
          width: 30.w,
          height: 32.h,
          margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
          child: CustomPaint(painter: _SeatPainter(color: color)),
        ),
      );
    });
  }

  // ── Amenity row (lavatory/galley icons) ───────────────────
  Widget _buildAmenityRow({
    String? leftSvg, String? leftId,
    String? rightSvg, String? rightId,
    bool centerOnly = false
  }) {
    if (centerOnly) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: _amenityBox(rightSvg!, rightId!),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 40.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (leftSvg != null && leftId != null) _amenityBox(leftSvg, leftId) else SizedBox(width: 44.w),
          if (rightSvg != null && rightId != null) _amenityBox(rightSvg, rightId) else SizedBox(width: 44.w),
        ],
      ),
    );
  }

  Widget _amenityBox(String svgPath, String id) {
    return Obx(() {
      final status = _ctrl.auditedSeats[id];
      final color = status == 'pass' ? _C.green
          : status == 'fail' ? _C.red
          : _C.seatColor;

      return GestureDetector(
        onTap: () => _showSeatSheet(id),
        child: Container(
          width: 44.w,
          height: 44.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Center(
            child: SvgPicture.asset(
              svgPath,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              width: 22.sp,
              height: 22.sp,
            ),
          ),
        ),
      );
    });
  }

  // ── Exit row ─────────────────────────────────────────────
  Widget _buildExitRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _exitLabel('◁ Exit'),
          _exitLabel('Exit ▷'),
        ],
      ),
    );
  }

  Widget _exitLabel(String t) => Text(t,
      style: GoogleFonts.dmSans(fontSize: 11.sp, fontWeight: FontWeight.w500, color: _C.grey));

  // ── Closet row ────────────────────────────────────────────
  Widget _buildClosetRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 40.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Closet',
              style: GoogleFonts.dmSans(fontSize: 12.sp, color: _C.grey, fontWeight: FontWeight.w500)),
          _amenityBox('assets/icons/toilet.svg', 'Closet'),
        ],
      ),
    );
  }

  // ── Section label ─────────────────────────────────────────
  Widget _buildSectionLabel(String t) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Center(
        child: Text(t,
            style: GoogleFonts.dmSans(fontSize: 14.sp, fontWeight: FontWeight.w600, color: _C.dark)),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // SEAT SHEET
  // ──────────────────────────────────────────────────────────
  void _showSeatSheet(String id) {
    String status = _ctrl.auditedSeats[id] ?? 'pass';

    Get.bottomSheet(
      StatefulBuilder(
        builder: (_, ss) => Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: _C.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w, height: 4.h,
                    decoration: BoxDecoration(
                        color: _C.border, borderRadius: BorderRadius.circular(2.r)),
                  ),
                ),
                SizedBox(height: 14.h),
                Text('Seat $id',
                    style: GoogleFonts.dmSans(fontSize: 18.sp, fontWeight: FontWeight.w700, color: _C.dark)),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(child: _statusChip('pass', status == 'pass', () => ss(() => status = 'pass'))),
                    SizedBox(width: 12.w),
                    Expanded(child: _statusChip('fail', status == 'fail', () => ss(() => status = 'fail'))),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () { _ctrl.clearSeat(id); Get.back(); },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _C.grey,
                          side: BorderSide(color: _C.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                        child: Text('Clear', style: GoogleFonts.dmSans(fontSize: 14.sp)),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () { _ctrl.markSeat(id, status); Get.back(); },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _C.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          elevation: 0,
                        ),
                        child: Text('Save', style: GoogleFonts.dmSans(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _statusChip(String label, bool selected, VoidCallback onTap) {
    final isPass = label == 'pass';
    final color = isPass ? _C.green : _C.red;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : _C.inputBg,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? color : _C.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isPass ? Icons.check_circle_outline : Icons.cancel_outlined,
                size: 20.sp, color: selected ? color : _C.grey),
            SizedBox(width: 8.w),
            Text(isPass ? 'Pass' : 'Fail',
                style: GoogleFonts.dmSans(
                  fontSize: 14.sp,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? color : _C.grey,
                )),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // SHARED WIDGETS
  // ──────────────────────────────────────────────────────────
  Widget _label(String t) => Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: Text(t,
        style: GoogleFonts.dmSans(fontSize: 12.sp, fontWeight: FontWeight.w600, color: _C.primary)),
  );

  TextStyle _fieldStyle() => GoogleFonts.dmSans(fontSize: 15.sp, color: _C.dark);

  Widget _pillField({required Widget child}) => Container(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    decoration: BoxDecoration(
      color: _C.white,
      borderRadius: BorderRadius.circular(30.r),
      border: Border.all(color: _C.border),
    ),
    child: child,
  );

  Widget _pillTextField({required TextEditingController controller, required String hint}) => TextField(
    controller: controller,
    style: _fieldStyle(),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.dmSans(fontSize: 15.sp, color: _C.grey),
      filled: true,
      fillColor: _C.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.r),
        borderSide: BorderSide(color: _C.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.r),
        borderSide: BorderSide(color: _C.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.r),
        borderSide: BorderSide(color: _C.primary, width: 1.5),
      ),
    ),
  );

  Widget _pillDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    IconData? suffixIcon,
  }) => Container(
    padding: EdgeInsets.symmetric(horizontal: 16.w),
    decoration: BoxDecoration(
      color: _C.white,
      borderRadius: BorderRadius.circular(30.r),
      border: Border.all(color: _C.border),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        icon: Icon(suffixIcon ?? Icons.keyboard_arrow_down_rounded, color: _C.grey, size: 20.sp),
        style: _fieldStyle(),
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
        onChanged: onChanged,
      ),
    ),
  );

  Widget _multilineField(String hint) => TextField(
    maxLines: 4,
    style: _fieldStyle(),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.dmSans(fontSize: 14.sp, color: _C.grey),
      filled: true,
      fillColor: _C.white,
      contentPadding: EdgeInsets.all(16.w),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: _C.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: _C.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: _C.primary, width: 1.5),
      ),
    ),
  );

  Widget _uploadBox() => GestureDetector(
    onTap: _pickImages,
    child: Container(
      height: 52.h,
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: _C.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_upload_outlined, size: 20.sp, color: _C.grey),
          SizedBox(width: 8.w),
          Text('Upload images', style: GoogleFonts.dmSans(fontSize: 14.sp, color: _C.grey)),
        ],
      ),
    ),
  );

  Widget _nextButton(VoidCallback onTap) => Container(
    color: _C.white,
    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          color: _C.primary,
          borderRadius: BorderRadius.circular(30.r),
        ),
        alignment: Alignment.center,
        child: Text('NEXT',
            style: GoogleFonts.dmSans(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.2)),
      ),
    ),
  );

  Widget _submitButton() => Container(
    color: _C.white,
    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
    child: GestureDetector(
      onTap: () {
        if (_signatureController.isEmpty) {
          // Get.snackbar(
          //   'Signature Required',
          //   'Please provide a signature before submitting.',
          //   backgroundColor: _C.red,
          //   colorText: Colors.white,
          //   snackPosition: SnackPosition.TOP,
          // );
          context;
        }

        Get.snackbar(
          'Success',
          'Audit report submitted!',
          backgroundColor: _C.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        Get.offAll(() => const CabinSecurityScreen());
      },
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          color: _C.primary,
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_rounded, color: Colors.white, size: 18.sp),
            SizedBox(width: 10.w),
            Text('SEND AUDIT REPORT',
                style: GoogleFonts.dmSans(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.1)),
          ],
        ),
      ),
    ),
  );

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(children: [
          Icon(Icons.info_outline_rounded, color: _C.primary, size: 24.sp),
          SizedBox(width: 8.w),
          Text('Instructions', style: GoogleFonts.dmSans(fontSize: 16.sp, fontWeight: FontWeight.w600)),
        ]),
        content: Text(
            'Complete all sections of the cabin quality audit. Mark each seat as Pass or Fail. Fill in findings and notes before submitting.',
            style: GoogleFonts.dmSans(fontSize: 13.sp, color: _C.grey, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Got it', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, color: _C.primary)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SEAT CONFIG
// ─────────────────────────────────────────────
enum _SeatConfig { normal, wide }

// ─────────────────────────────────────────────
// CUSTOM PAINTER — Airplane seat shape
// ─────────────────────────────────────────────
class _SeatPainter extends CustomPainter {
  final Color color;
  const _SeatPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;

    // Seat back (top 55%)
    final backRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h * 0.58),
      const Radius.circular(5),
    );
    canvas.drawRRect(backRect, paint);

    // Seat cushion (bottom area, slightly wider)
    final cushionRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(-1, h * 0.55, w + 2, h * 0.38),
      const Radius.circular(4),
    );
    canvas.drawRRect(cushionRect, paint);

    // Armrests
    final armPaint = Paint()..color = color.withValues(alpha: 0.85)..style = PaintingStyle.fill;
    // left armrest
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(-3, h * 0.25, 4, h * 0.45), const Radius.circular(2)),
      armPaint,
    );
    // right armrest
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w - 1, h * 0.25, 4, h * 0.45), const Radius.circular(2)),
      armPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SeatPainter old) => old.color != color;
}

// ─────────────────────────────────────────────
// CUSTOM PAINTER — Plane silhouette background
// ─────────────────────────────────────────────
class _PlaneSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // The plane shape is handled by ClipRRect + the outer container
    // This painter just makes sure the background is correct
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}