import 'dart:io';
import 'package:avislap/views/forms/Cabin%20Quality%20Audit/CabinQualityAuditList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';


// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────
class _C {
  static const Color primary   = Color(0xFF3D5AFE);
  static const Color bg        = Color(0xFFF5F6FA);
  static const Color white     = Color(0xFFFFFFFF);
  static const Color dark      = Color(0xFF1A1A2E);
  static const Color grey      = Color(0xFF8891A4);
  static const Color border    = Color(0xFFE4E7EF);
  static const Color inputBg   = Color(0xFFF9FAFB);
  static const Color seatColor = Color(0xFF6B7B99);
  static const Color green     = Color(0xFF22C55E);
  static const Color red       = Color(0xFFEF4444);
  static const Color planeGrey = Color(0xFFEDEFF4);
}

// ─────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────
class AircraftSeatMap {
  final String name;
  final List<SeatSection> sections;
  final bool hasFirstClassArc;
  AircraftSeatMap({
    required this.name,
    required this.sections,
    this.hasFirstClassArc = false,
  });
}

class SeatSection {
  final String name;
  final int startRow;
  final int endRow;
  final List<String> leftCols;
  final List<String> rightCols;
  final bool hasExitBefore;
  final bool hasExitAfter;
  final List<AmenityRow>? amenitiesBefore;
  final List<AmenityRow>? amenitiesAfter;
  final List<int>? skipRows;
  SeatSection({
    required this.name,
    required this.startRow,
    required this.endRow,
    required this.leftCols,
    required this.rightCols,
    this.hasExitBefore = false,
    this.hasExitAfter = false,
    this.amenitiesBefore,
    this.amenitiesAfter,
    this.skipRows,
  });
}

class AmenityRow {
  final String? leftSvg;
  final String? leftId;
  final String? rightSvg;
  final String? rightId;
  final bool centerOnly;
  final String? customLabel;
  AmenityRow({
    this.leftSvg,
    this.leftId,
    this.rightSvg,
    this.rightId,
    this.centerOnly = false,
    this.customLabel,
  });
}

// ─────────────────────────────────────────────
// CONTROLLER
// ─────────────────────────────────────────────
class CabinAudit extends GetxController {
  final selectedAircraft  = 'Boeing 757-300 (75Y)'.obs;
  final selectedGate      = 'Gate - A'.obs;
  final selectedCleanType = 'Clean 1'.obs;
  final supervisorName    = ''.obs;
  final auditedSeats      = <String, String>{}.obs;

  final List<String> aircraftOptions = [
    'Boeing 757-300 (75Y)',
    'Boeing 737-800',
    'Airbus A320',
  ];
  final List<String> gateOptions = [
    'Gate - A', 'Gate - B', 'Gate - C', 'Gate - D',
  ];
  final List<String> cleanTypeOptions = ['Clean 1', 'Clean 2', 'Deep Clean'];

  late final Map<String, AircraftSeatMap> aircraftMaps;

  @override
  void onInit() {
    super.onInit();
    _initAircraftMaps();
  }

  void _initAircraftMaps() {
    aircraftMaps = {
      'Boeing 757-300 (75Y)': AircraftSeatMap(
        name: 'Boeing 757-300 (75Y)',
        hasFirstClassArc: true,
        sections: [
          SeatSection(
            name: 'First Class',
            startRow: 1, endRow: 6,
            leftCols: ['A', 'B'], rightCols: ['C', 'D'],
            amenitiesBefore: [
              AmenityRow(
                leftSvg: 'assets/icons/toilet.svg', leftId: 'LAV FWD',
                rightSvg: 'assets/icons/chiken.svg', rightId: 'Galley FWD',
              ),
            ],
            hasExitBefore: true,
            amenitiesAfter: [
              AmenityRow(customLabel: 'Closet'),
              AmenityRow(
                leftSvg: 'assets/icons/toilet.svg', leftId: 'LAV MID L',
                rightSvg: 'assets/icons/toilet.svg', rightId: 'LAV MID R',
              ),
            ],
          ),
          SeatSection(
            name: 'Delta Comfort',
            startRow: 14, endRow: 21,
            leftCols: ['A', 'B', 'C'], rightCols: ['D', 'E', 'F'],
            hasExitBefore: true,
            skipRows: [14],
          ),
          SeatSection(
            name: 'Delta Main',
            startRow: 22, endRow: 40,
            leftCols: ['A', 'B', 'C'], rightCols: ['D', 'E', 'F'],
            amenitiesAfter: [
              AmenityRow(
                leftSvg: 'assets/icons/toilet.svg', leftId: 'LAV AFT L',
                rightSvg: 'assets/icons/toilet.svg', rightId: 'LAV AFT R',
              ),
            ],
            hasExitAfter: true,
          ),
          SeatSection(
            name: '',
            startRow: 41, endRow: 49,
            leftCols: ['A', 'B', 'C'], rightCols: ['D', 'E', 'F'],
            amenitiesAfter: [
              AmenityRow(
                rightSvg: 'assets/icons/chiken.svg', rightId: 'Galley AFT',
                centerOnly: true,
              ),
            ],
            hasExitAfter: true,
          ),
        ],
      ),
      'Boeing 737-800': AircraftSeatMap(
        name: 'Boeing 737-800',
        hasFirstClassArc: false,
        sections: [
          SeatSection(
            name: 'First Class',
            startRow: 1, endRow: 4,
            leftCols: ['A', 'B'], rightCols: ['C', 'D'],
            amenitiesBefore: [
              AmenityRow(
                leftSvg: 'assets/icons/toilet.svg', leftId: 'LAV FWD',
                rightSvg: 'assets/icons/chiken.svg', rightId: 'Galley FWD',
              ),
            ],
            hasExitBefore: true,
          ),
          SeatSection(
            name: 'Main Cabin',
            startRow: 7, endRow: 20,
            leftCols: ['A', 'B', 'C'], rightCols: ['D', 'E', 'F'],
            hasExitBefore: true,
          ),
          SeatSection(
            name: '',
            startRow: 21, endRow: 33,
            leftCols: ['A', 'B', 'C'], rightCols: ['D', 'E', 'F'],
            hasExitAfter: true,
            amenitiesAfter: [
              AmenityRow(
                leftSvg: 'assets/icons/toilet.svg', leftId: 'LAV AFT L',
                rightSvg: 'assets/icons/toilet.svg', rightId: 'LAV AFT R',
              ),
              AmenityRow(
                rightSvg: 'assets/icons/chiken.svg', rightId: 'Galley AFT',
                centerOnly: true,
              ),
            ],
          ),
        ],
      ),
      'Airbus A320': AircraftSeatMap(
        name: 'Airbus A320',
        hasFirstClassArc: false,
        sections: [
          SeatSection(
            name: 'Business Class',
            startRow: 1, endRow: 3,
            leftCols: ['A', 'B'], rightCols: ['C', 'D'],
            amenitiesBefore: [
              AmenityRow(
                rightSvg: 'assets/icons/chiken.svg', rightId: 'Galley FWD',
                centerOnly: true,
              ),
            ],
          ),
          SeatSection(
            name: 'Economy',
            startRow: 8, endRow: 18,
            leftCols: ['A', 'B', 'C'], rightCols: ['D', 'E', 'F'],
            hasExitBefore: true,
          ),
          SeatSection(
            name: '',
            startRow: 19, endRow: 30,
            leftCols: ['A', 'B', 'C'], rightCols: ['D', 'E', 'F'],
            hasExitAfter: true,
            amenitiesAfter: [
              AmenityRow(
                leftSvg: 'assets/icons/toilet.svg', leftId: 'LAV L',
                rightSvg: 'assets/icons/toilet.svg', rightId: 'LAV R',
              ),
            ],
          ),
        ],
      ),
    };
  }

  AircraftSeatMap get currentAircraftMap =>
      aircraftMaps[selectedAircraft.value] ?? aircraftMaps.values.first;

  void markSeat(String id, String status) => auditedSeats[id] = status;
  void clearSeat(String id) => auditedSeats.remove(id);
}

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────
class CabinAuditScreen extends StatefulWidget {
  const CabinAuditScreen({super.key});
  @override
  State<CabinAuditScreen> createState() => _CabinAuditScreenState();
}

class _CabinAuditScreenState extends State<CabinAuditScreen> {
  final _ctrl           = Get.put(CabinAudit());
  final _supervisorCtrl = TextEditingController();
  int _step = 0;

  final RxList<File> _selectedImages = <File>[].obs;
  final ImagePicker  _picker         = ImagePicker();

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      _selectedImages.addAll(images.map((img) => File(img.path)));
    }
  }

  static String _todayDate() {
    final n = DateTime.now();
    return '${n.month.toString().padLeft(2, '0')}/'
        '${n.day.toString().padLeft(2, '0')}/${n.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _buildAppBar(),
      body: _step == 0
          ? _buildStep0()
          : _step == 1
          ? _buildStep1()
          : _buildStep2(),
    );
  }

  // ── App Bar ──────────────────────────────────────────────
  AppBar _buildAppBar() => AppBar(
    backgroundColor: _C.white,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    leading: IconButton(
      icon: Icon(Icons.arrow_back_rounded,
          color: _C.primary, size: 22.sp),
      onPressed: () =>
      _step > 0 ? setState(() => _step--) : Get.back(),
    ),
    title: Text(
      'Cabin Quality Audit',
      style: GoogleFonts.dmSans(
        fontSize: 17.sp,
        fontWeight: FontWeight.w600,
        color: _C.primary,
      ),
    ),
    centerTitle: true,
    actions: [
      IconButton(
        icon: Icon(Icons.info_outline_rounded,
            color: _C.primary, size: 22.sp),
        onPressed: _showInstructions,
      ),
    ],
  );

  // ── STEP 0: Job Details ──────────────────────────────────
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
                    Expanded(
                        child: Text(_todayDate(),
                            style: _fieldStyle())),
                    Icon(Icons.calendar_month_outlined,
                        size: 20.sp, color: _C.grey),
                  ]),
                ),
                SizedBox(height: 16.h),
                _label('Supervisor/Lead *'),
                _pillTextField(
                    controller: _supervisorCtrl,
                    hint: 'John Doe'),
                SizedBox(height: 16.h),
                _label('Gate *'),
                Obx(() => _pillDropdown(
                  value: _ctrl.selectedGate.value,
                  items: _ctrl.gateOptions,
                  onChanged: (v) =>
                  _ctrl.selectedGate.value = v!,
                )),
                SizedBox(height: 16.h),
                _label('Type of Clean *'),
                Obx(() => _pillDropdown(
                  value: _ctrl.selectedCleanType.value,
                  items: _ctrl.cleanTypeOptions,
                  onChanged: (v) =>
                  _ctrl.selectedCleanType.value = v!,
                )),
              ],
            ),
          ),
        ),
        _nextButton(() => setState(() => _step = 1)),
      ],
    );
  }

  // ── STEP 1: Inspection Checklist + Seat Map ──────────────
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
                Text(
                  'Inspection Checklist',
                  style: GoogleFonts.dmSans(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: _C.primary,
                  ),
                ),
                SizedBox(height: 20.h),
                _label('Type of Aircraft *'),
                Obx(() => _pillDropdown(
                  value: _ctrl.selectedAircraft.value,
                  items: _ctrl.aircraftOptions,
                  onChanged: (v) =>
                  _ctrl.selectedAircraft.value = v!,
                  suffixIcon: Icons.search_rounded,
                )),
                SizedBox(height: 24.h),
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

  // ── STEP 2: Notes + Submit ───────────────────────────────
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
                _multilineField(
                    'Enter any additional findings or notes...'),
                SizedBox(height: 16.h),
                _label('Additional Notes'),
                _multilineField(
                    'Enter any additional findings or notes...'),
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
                          borderRadius:
                          BorderRadius.circular(8.r),
                          child: Image.file(file,
                              width: 80.w,
                              height: 80.w,
                              fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 4, right: 4,
                          child: GestureDetector(
                            onTap: () =>
                                _selectedImages.remove(file),
                            child: Container(
                              padding: EdgeInsets.all(2.r),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.close,
                                  color: Colors.white,
                                  size: 14.sp),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                )),
              ],
            ),
          ),
        ),
        _submitButton(),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // SEAT MAP
  // ─────────────────────────────────────────────
  Widget _buildSeatMap() {
    return Obx(() {
      final aircraftMap = _ctrl.currentAircraftMap;
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
                  SizedBox(height: 60.h),
                  if (aircraftMap.hasFirstClassArc) ...[
                    _buildFirstClassArc(),
                    SizedBox(height: 12.h),
                  ],
                  ...aircraftMap.sections
                      .map((section) => _buildSection(section)),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSection(SeatSection section) {
    return Column(
      children: [
        if (section.amenitiesBefore != null)
          ...section.amenitiesBefore!.map((amenity) {
            if (amenity.customLabel != null)
              return _buildClosetRow();
            return _buildAmenityRow(
              leftSvg: amenity.leftSvg,
              leftId: amenity.leftId,
              rightSvg: amenity.rightSvg,
              rightId: amenity.rightId,
              centerOnly: amenity.centerOnly,
            );
          }),
        if (section.hasExitBefore) _buildExitRow(),
        SizedBox(height: 4.h),
        if (section.name.isNotEmpty)
          _buildSectionLabel(section.name),
        SizedBox(height: 4.h),
        _buildColHeaders(
            [...section.leftCols, '', ...section.rightCols]),
        SizedBox(height: 4.h),
        ...List.generate(
            section.endRow - section.startRow + 1, (i) {
          final rowNum = section.startRow + i;
          if (section.skipRows != null &&
              section.skipRows!.contains(rowNum)) {
            return _buildSeatRow(
              rowNum: rowNum,
              leftCols: ['', ''],
              rightCols: section.rightCols,
            );
          }
          return _buildSeatRow(
            rowNum: rowNum,
            leftCols: section.leftCols,
            rightCols: section.rightCols,
          );
        }),
        SizedBox(height: 16.h),
        if (section.amenitiesAfter != null)
          ...section.amenitiesAfter!.map((amenity) =>
              _buildAmenityRow(
                leftSvg: amenity.leftSvg,
                leftId: amenity.leftId,
                rightSvg: amenity.rightSvg,
                rightId: amenity.rightId,
                centerOnly: amenity.centerOnly,
              )),
        if (section.hasExitAfter) _buildExitRow(),
      ],
    );
  }

  Widget _buildFirstClassArc() {
    return SizedBox(
      height: 120.h,
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(9, (i) {
          final radius = 72.0;
          final x = -radius * (1 - 2 * i / 8);
          final y =
              -radius * 0.6 * (0.5 - (i / 8 - 0.5).abs());
          final tilt = (i / 8 - 0.5) * 60;
          return Transform.translate(
            offset: Offset(x * 0.9, y + 30),
            child: Transform.rotate(
              angle: tilt * 3.14159 / 180,
              child: Container(
                width: i == 4 ? 28.w : 22.w,
                height: i == 4 ? 44.h : 36.h,
                decoration: BoxDecoration(
                  color: _C.seatColor,
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildColHeaders(List<String> cols) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: cols
            .map((c) => c.isEmpty
            ? SizedBox(width: 28.w)
            : SizedBox(
          width: 34.w,
          child: Center(
            child: Text(c,
                style: GoogleFonts.dmSans(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: _C.grey)),
          ),
        ))
            .toList(),
      ),
    );
  }

  Widget _buildSeatRow({
    required int rowNum,
    required List<String> leftCols,
    required List<String> rightCols,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...leftCols.map((col) => col.isEmpty
              ? SizedBox(width: 34.w)
              : _seat('$rowNum$col')),
          SizedBox(
            width: 28.w,
            child: Center(
              child: Text('$rowNum',
                  style: GoogleFonts.dmSans(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: _C.grey)),
            ),
          ),
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
      final color = status == 'pass'
          ? _C.green
          : status == 'fail'
          ? _C.red
          : _C.seatColor;
      return GestureDetector(
        onTap: () => _showSeatSheet(id),
        child: Container(
          width: 30.w,
          height: 32.h,
          margin: EdgeInsets.symmetric(
              horizontal: 2.w, vertical: 1.h),
          child: CustomPaint(
              painter: _SeatPainter(color: color)),
        ),
      );
    });
  }

  Widget _buildAmenityRow({
    String? leftSvg,
    String? leftId,
    String? rightSvg,
    String? rightId,
    bool centerOnly = false,
  }) {
    if (centerOnly) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: _amenityBox(rightSvg!, rightId!),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: 6.h, horizontal: 40.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (leftSvg != null && leftId != null)
            _amenityBox(leftSvg, leftId)
          else
            SizedBox(width: 44.w),
          if (rightSvg != null && rightId != null)
            _amenityBox(rightSvg, rightId)
          else
            SizedBox(width: 44.w),
        ],
      ),
    );
  }

  Widget _amenityBox(String svgPath, String id) {
    return Obx(() {
      final status = _ctrl.auditedSeats[id];
      final color = status == 'pass'
          ? _C.green
          : status == 'fail'
          ? _C.red
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
              colorFilter: const ColorFilter.mode(
                  Colors.white, BlendMode.srcIn),
              width: 22.sp,
              height: 22.sp,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildExitRow() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: 4.h, horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('◁ Exit',
              style: GoogleFonts.dmSans(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: _C.grey)),
          Text('Exit ▷',
              style: GoogleFonts.dmSans(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: _C.grey)),
        ],
      ),
    );
  }

  Widget _buildClosetRow() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: 6.h, horizontal: 40.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Closet',
              style: GoogleFonts.dmSans(
                  fontSize: 12.sp,
                  color: _C.grey,
                  fontWeight: FontWeight.w500)),
          _amenityBox('assets/icons/toilet.svg', 'Closet'),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String t) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Center(
        child: Text(t,
            style: GoogleFonts.dmSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: _C.dark)),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SEAT SHEET  ✅ FULLY UPDATED
  // — Object1 arrow click → inline expand:
  //     Status (Pass/Fail/N/A) + Upload images + Uncleaned part
  // — Object2 arrow click → same inline expand independently
  // — No separate screen, everything in the sheet
  // ─────────────────────────────────────────────
  void _showSeatSheet(String id) {
    // ── sheet-local state ──────────────────────
    String status        = _ctrl.auditedSeats[id] ?? 'pass';
    bool   obj1Expanded  = false;
    bool   obj2Expanded  = false;

    final RxList<File>   imgs1     = <File>[].obs;
    final RxList<File>   imgs2     = <File>[].obs;
    final RxList<String> tags1     = <String>[].obs;
    final RxList<String> tags2     = <String>[].obs;
    final notes1Ctrl = TextEditingController();
    final notes2Ctrl = TextEditingController();
    final picker     = ImagePicker();

    Future<void> pickFor(RxList<File> target) async {
      final picked = await picker.pickMultiImage();
      if (picked.isNotEmpty) {
        target.addAll(picked.map((x) => File(x.path)));
      }
    }

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, ss) => Material(
          color: Colors.transparent,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.90,
            decoration: BoxDecoration(
              color: _C.white,
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20.r)),
            ),
            child: Column(
              children: [
                // ── drag handle ──────────────────────
                Padding(
                  padding:
                  EdgeInsets.symmetric(vertical: 12.h),
                  child: Center(
                    child: Container(
                      width: 40.w, height: 4.h,
                      decoration: BoxDecoration(
                        color: _C.border,
                        borderRadius:
                        BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                ),

                // ── scrollable content ───────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                        20.w, 0, 20.w, 20.h),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        // title
                        Text(
                          'First Class',
                          style: GoogleFonts.dmSans(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: _C.primary,
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // ══════════════════════════
                        // OBJECT 1
                        // ══════════════════════════
                        _sheetLabel('Object1',
                            required: true),
                        _objectRow(
                          expanded: obj1Expanded,
                          onTap: () => ss(() =>
                          obj1Expanded = !obj1Expanded),
                        ),

                        // Object1 expanded panel
                        if (obj1Expanded) ...[
                          SizedBox(height: 16.h),
                          _sheetLabel('Status',
                              required: true),
                          _statusRow(
                            status: status,
                            onPass: () =>
                                ss(() => status = 'pass'),
                            onFail: () =>
                                ss(() => status = 'fail'),
                            onNA: () =>
                                ss(() => status = 'na'),
                          ),
                          SizedBox(height: 16.h),
                          _sheetLabel(
                            'Upload the images (max 100MB)',
                            required: true,
                          ),
                          _uploadRow(
                              onTap: () => pickFor(imgs1)),
                          SizedBox(height: 10.h),
                          _thumbsRow(imgs1),
                          SizedBox(height: 16.h),
                          _sheetLabel('Uncleaned part'),
                          _uncleanedField(
                            ctrl: notes1Ctrl,
                            tags: tags1,
                          ),
                          SizedBox(height: 20.h),
                        ],

                        SizedBox(height: 12.h),

                        // ══════════════════════════
                        // OBJECT 2
                        // ══════════════════════════
                        _sheetLabel('Object2',
                            required: true),
                        _objectRow(
                          expanded: obj2Expanded,
                          onTap: () => ss(() =>
                          obj2Expanded = !obj2Expanded),
                        ),

                        // Object2 expanded panel
                        if (obj2Expanded) ...[
                          SizedBox(height: 16.h),
                          _sheetLabel('Status',
                              required: true),
                          _statusRow(
                            status: status,
                            onPass: () =>
                                ss(() => status = 'pass'),
                            onFail: () =>
                                ss(() => status = 'fail'),
                            onNA: () =>
                                ss(() => status = 'na'),
                          ),
                          SizedBox(height: 16.h),
                          _sheetLabel(
                            'Upload the images (max 100MB)',
                            required: true,
                          ),
                          _uploadRow(
                              onTap: () => pickFor(imgs2)),
                          SizedBox(height: 10.h),
                          _thumbsRow(imgs2),
                          SizedBox(height: 16.h),
                          _sheetLabel('Uncleaned part'),
                          _uncleanedField(
                            ctrl: notes2Ctrl,
                            tags: tags2,
                          ),
                          SizedBox(height: 20.h),
                        ],

                        SizedBox(height: 8.h),
                      ],
                    ),
                  ),
                ),

                // ── Cancel / Apply ───────────────────
                Container(
                  padding: EdgeInsets.fromLTRB(
                      20.w, 12.h, 20.w, 24.h),
                  decoration: BoxDecoration(
                    color: _C.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _C.primary,
                            side: BorderSide(
                                color: _C.primary,
                                width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                  25.r),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 14.h),
                          ),
                          child: Text('Cancel',
                              style: GoogleFonts.dmSans(
                                  fontSize: 15.sp,
                                  fontWeight:
                                  FontWeight.w600)),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _ctrl.markSeat(id, status);
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _C.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                  25.r),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 14.h),
                            elevation: 0,
                          ),
                          child: Text('Apply',
                              style: GoogleFonts.dmSans(
                                  fontSize: 15.sp,
                                  fontWeight:
                                  FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
    );
  }

  // ── Object row (pill with animated arrow) ────
  Widget _objectRow({
    required bool expanded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 50.h,
        decoration: BoxDecoration(
          color: _C.white,
          borderRadius: BorderRadius.circular(25.r),
          border: Border.all(
            color: expanded ? _C.primary : _C.border,
            width: expanded ? 1.5 : 1.0,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Please Select the object',
              style: GoogleFonts.dmSans(
                  fontSize: 14.sp, color: _C.grey),
            ),
            AnimatedRotation(
              turns: expanded ? 0.25 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_right_rounded,
                color: expanded ? _C.primary : _C.grey,
                size: 20.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Status row (Pass / Fail / N/A) ───────────
  Widget _statusRow({
    required String status,
    required VoidCallback onPass,
    required VoidCallback onFail,
    required VoidCallback onNA,
  }) {
    return Row(
      children: [
        Expanded(
          child: _statusBtn(
            label: 'Pass',
            icon: Icons.check,
            selected: status == 'pass',
            activeColor: _C.green,
            onTap: onPass,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _statusBtn(
            label: 'Fail',
            icon: Icons.close,
            selected: status == 'fail',
            activeColor: _C.red,
            onTap: onFail,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _statusBtn(
            label: 'N/A',
            icon: null,
            selected: status == 'na',
            activeColor: _C.primary,
            onTap: onNA,
          ),
        ),
      ],
    );
  }

  Widget _statusBtn({
    required String label,
    required IconData? icon,
    required bool selected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 44.h,
        decoration: BoxDecoration(
          color: selected ? activeColor : _C.white,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: selected ? activeColor : _C.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 18.sp,
                  color: selected ? Colors.white : _C.grey),
              SizedBox(width: 5.w),
            ],
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : _C.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Upload button ────────────────────────────
  Widget _uploadRow({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: _C.white,
          borderRadius: BorderRadius.circular(25.r),
          border: Border.all(color: _C.border, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload_outlined,
                size: 20.sp, color: _C.grey),
            SizedBox(width: 8.w),
            Text('Upload an image',
                style: GoogleFonts.dmSans(
                    fontSize: 14.sp, color: _C.grey)),
          ],
        ),
      ),
    );
  }

  // ── Thumbnails horizontal row ────────────────
  Widget _thumbsRow(RxList<File> imgs) {
    return Obx(() => imgs.isEmpty
        ? const SizedBox.shrink()
        : SizedBox(
      height: 76.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imgs.length,
        itemBuilder: (_, i) => Stack(
          children: [
            Container(
              width: 68.w, height: 68.h,
              margin: EdgeInsets.only(right: 8.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border:
                Border.all(color: _C.border, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.file(imgs[i],
                    fit: BoxFit.cover),
              ),
            ),
            Positioned(
              top: 2, right: 10,
              child: GestureDetector(
                onTap: () => imgs.removeAt(i),
                child: Container(
                  padding: EdgeInsets.all(2.r),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close,
                      color: Colors.white,
                      size: 13.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  // ── Uncleaned part (hashtag chips + notes) ───
  Widget _uncleanedField({
    required TextEditingController ctrl,
    required RxList<String> tags,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _C.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // chips
          Obx(() => tags.isEmpty
              ? const SizedBox.shrink()
              : Container(
            padding: EdgeInsets.fromLTRB(
                14.w, 12.h, 14.w, 4.h),
            child: Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: tags.map((tag) {
                return Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: _C.primary,
                    borderRadius:
                    BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(tag,
                          style: GoogleFonts.dmSans(
                              fontSize: 12.sp,
                              color: Colors.white,
                              fontWeight:
                              FontWeight.w500)),
                      SizedBox(width: 6.w),
                      GestureDetector(
                        onTap: () => tags.remove(tag),
                        child: Icon(Icons.close,
                            size: 13.sp,
                            color: Colors.white),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          )),

          // text input
          TextField(
            controller: ctrl,
            maxLines: 4,
            style: GoogleFonts.dmSans(
                fontSize: 14.sp, color: _C.dark),
            decoration: InputDecoration(
              hintText:
              'Enter any additional findings or notes...',
              hintStyle: GoogleFonts.dmSans(
                  fontSize: 14.sp, color: _C.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(14.w),
            ),
            onChanged: (text) {
              // type #word then Space → auto chip
              if (text.endsWith(' ') &&
                  text.trim().startsWith('#')) {
                final words = text.trim().split(' ');
                final last = words.last;
                if (last.startsWith('#') && last.length > 1) {
                  tags.add(last);
                  ctrl.text =
                      text.replaceAll(last, '').trim();
                  ctrl.selection = TextSelection.fromPosition(
                      TextPosition(offset: ctrl.text.length));
                }
              }
            },
          ),
        ],
      ),
    );
  }

  // ── Sheet label ──────────────────────────────
  Widget _sheetLabel(String text, {bool required = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: RichText(
        text: TextSpan(
          text: text,
          style: GoogleFonts.dmSans(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: _C.primary,
          ),
          children: required
              ? [
            TextSpan(
                text: ' *',
                style: TextStyle(color: _C.red))
          ]
              : [],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SHARED HELPERS
  // ─────────────────────────────────────────────
  Widget _label(String t) => Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: Text(t,
        style: GoogleFonts.dmSans(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: _C.primary)),
  );

  TextStyle _fieldStyle() =>
      GoogleFonts.dmSans(fontSize: 15.sp, color: _C.dark);

  Widget _pillField({required Widget child}) => Container(
    padding: EdgeInsets.symmetric(
        horizontal: 16.w, vertical: 14.h),
    decoration: BoxDecoration(
      color: _C.white,
      borderRadius: BorderRadius.circular(30.r),
      border: Border.all(color: _C.border),
    ),
    child: child,
  );

  Widget _pillTextField({
    required TextEditingController controller,
    required String hint,
  }) =>
      TextField(
        controller: controller,
        style: _fieldStyle(),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.dmSans(
              fontSize: 15.sp, color: _C.grey),
          filled: true,
          fillColor: _C.white,
          contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w, vertical: 14.h),
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
            borderSide:
            BorderSide(color: _C.primary, width: 1.5),
          ),
        ),
      );

  Widget _pillDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    IconData? suffixIcon,
  }) =>
      Container(
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
            icon: Icon(
                suffixIcon ??
                    Icons.keyboard_arrow_down_rounded,
                color: _C.grey,
                size: 20.sp),
            style: _fieldStyle(),
            items: items
                .map((i) => DropdownMenuItem(
                value: i, child: Text(i)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      );

  Widget _multilineField(String hint) => TextField(
    maxLines: 4,
    style: _fieldStyle(),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.dmSans(
          fontSize: 14.sp, color: _C.grey),
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
        borderSide:
        BorderSide(color: _C.primary, width: 1.5),
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
          Icon(Icons.cloud_upload_outlined,
              size: 20.sp, color: _C.grey),
          SizedBox(width: 8.w),
          Text('Upload images',
              style: GoogleFonts.dmSans(
                  fontSize: 14.sp, color: _C.grey)),
        ],
      ),
    ),
  );

  Widget _nextButton(VoidCallback onTap) => Container(
    color: _C.white,
    padding: EdgeInsets.fromLTRB(
        20.w, 12.h, 20.w, 24.h),
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
            style: GoogleFonts.dmSans(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.2)),
      ),
    ),
  );

  Widget _submitButton() => Container(
    color: _C.white,
    padding: EdgeInsets.fromLTRB(
        20.w, 12.h, 20.w, 24.h),
    child: GestureDetector(
      onTap: () {
        Get.snackbar(
          'Success',
          'Audit report submitted!',
          backgroundColor: _C.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        Get.offAll(
                () => const CabinQualityAuditListScreen());
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
            Icon(Icons.send_rounded,
                color: Colors.white, size: 18.sp),
            SizedBox(width: 10.w),
            Text('SEND AUDIT REPORT',
                style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.1)),
          ],
        ),
      ),
    ),
  );

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        title: Row(children: [
          Icon(Icons.info_outline_rounded,
              color: _C.primary, size: 24.sp),
          SizedBox(width: 8.w),
          Text('Instructions',
              style: GoogleFonts.dmSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600)),
        ]),
        content: Text(
          'Complete all sections of the cabin quality audit. '
              'Mark each seat as Pass or Fail. '
              'Fill in findings and notes before submitting.',
          style: GoogleFonts.dmSans(
              fontSize: 13.sp,
              color: _C.grey,
              height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Got it',
                style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600,
                    color: _C.primary)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PAINTERS
// ─────────────────────────────────────────────
class _SeatPainter extends CustomPainter {
  final Color color;
  const _SeatPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;

    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, w, h * 0.58),
            const Radius.circular(5)),
        paint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(-1, h * 0.55, w + 2, h * 0.38),
            const Radius.circular(4)),
        paint);

    final armPaint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(-3, h * 0.25, 4, h * 0.45),
            const Radius.circular(2)),
        armPaint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w - 1, h * 0.25, 4, h * 0.45),
            const Radius.circular(2)),
        armPaint);
  }

  @override
  bool shouldRepaint(covariant _SeatPainter old) =>
      old.color != color;
}

class _PlaneSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {}
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}