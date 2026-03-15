import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:signature/signature.dart';
import 'package:image_picker/image_picker.dart';
import 'CabinSecurityTrainingScreen.dart';

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────
class _C {
  static const Color primary = Color(0xFF3D5AFE);
  static const Color bg = Color(0xFFF5F6FA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color dark = Color(0xFF1A1A2E);
  static const Color grey = Color(0xFF8891A4);
  static const Color border = Color(0xFFE4E7EF);
  static const Color inputBg = Color(0xFFF9FAFB);
  static const Color seatColor = Color(0xFF6B7B99);
  static const Color green = Color(0xFF22C55E);
  static const Color red = Color(0xFFEF4444);
  static const Color planeGrey = Color(0xFFEDEFF4);
  static const Color infoBg = Color(0xFFEEF2FF);
  static const Color infoBorder = Color(0xFFB0BEF8);
  static const Color warnBg = Color(0xFFFFF8E1);
  static const Color warnBorder = Color(0xFFFFCC02);
}

// ─────────────────────────────────────────────
// PREDEFINED AREAS
// ─────────────────────────────────────────────
const List<String> kCabinAreas = [
  'Front Galley',
  'Rear Galley',
  'First Class',
  'Delta Comfort',
  'Main Cabin',
  'FWD LAV',
  'MID LAV L',
  'MID LAV R',
  'AFT LAV L',
  'AFT LAV R',
  'Overhead Bins',
  'Seat Pockets',
  'Crew Rest Area',
  'Emergency Equipment',
];

// Max image size: 100MB
const int kMaxImageBytes = 100 * 1024 * 1024;

// ─────────────────────────────────────────────
// AREA CARD MODEL
// ─────────────────────────────────────────────
class AreaCard {
  final String areaName;
  String status;
  List<File> images;

  AreaCard({required this.areaName}) : status = '', images = [];
}

// ─────────────────────────────────────────────
// SEAT MAP MODELS
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
class CabinQualityController extends GetxController {
  final selectedAircraft = 'Boeing 757-300 (75Y)'.obs;
  final selectedGate = 'Please Select One'.obs;
  final auditedSeats = <String, String>{}.obs;

  final shipNumber = ''.obs;
  final supervisorName = 'John Doe'.obs;
  final supervisorRole = 'Supervisor'.obs;

  final otherFindingsCtrl = TextEditingController();
  final additionalNotesCtrl = TextEditingController();

  final RxList<String> selectedAreas = <String>[].obs;
  final RxList<AreaCard> areaCards = <AreaCard>[].obs;
  final areaSearchCtrl = TextEditingController();
  final RxList<String> filteredAreas = <String>[].obs;
  final RxBool showAreaDropdown = false.obs;

  final RxSet<String> selectedSeatIds = <String>{}.obs;

  final sec1Expanded = true.obs;
  final sec2Expanded = true.obs;
  final sec3Expanded = true.obs;

  final List<String> aircraftOptions = [
    'Boeing 757-300 (75Y)',
    'Boeing 737-800',
    'Airbus A320',
  ];

  final List<String> gateOptions = [
    'Please Select One',
    'Gate - A',
    'Gate - B',
    'Gate - C',
    'Gate - D',
    'Gate A-01',
    'Gate A-02',
    'Gate A-03',
    'Gate A-12',
    'Gate B-01',
    'Gate B-02',
    'Gate B-04',
    'Gate C-07',
  ];

  final List<String> roleOptions = [
    'Vice President',
    'General Manager',
    'Duty Manager',
    'Supervisor',
    'All',
  ];

  late final Map<String, AircraftSeatMap> aircraftMaps;

  bool get isFormValid {
    if (selectedGate.value == 'Please Select One') return false;
    if (shipNumber.value.trim().isEmpty) return false;
    if (selectedAreas.isEmpty) return false;
    if (areaCards.any((c) => c.status.isEmpty)) return false;
    return true;
  }

  String get validationMessage {
    if (selectedGate.value == 'Please Select One')
      return 'Please select a Gate.';
    if (shipNumber.value.trim().isEmpty) return 'Please enter the Ship #.';
    if (selectedAreas.isEmpty)
      return 'Please select at least one area to inspect.';
    if (areaCards.any((c) => c.status.isEmpty))
      return 'Please mark Pass or Fail for all selected areas.';
    return '';
  }

  @override
  void onInit() {
    super.onInit();
    filteredAreas.assignAll(kCabinAreas);
    areaSearchCtrl.addListener(_onAreaSearch);
    _initAircraftMaps();
  }

  void _onAreaSearch() {
    final q = areaSearchCtrl.text.toLowerCase();
    filteredAreas.assignAll(
      q.isEmpty
          ? kCabinAreas
          : kCabinAreas.where((a) => a.toLowerCase().contains(q)),
    );
  }

  void addArea(String area) {
    if (!selectedAreas.contains(area)) {
      selectedAreas.add(area);
      areaCards.add(AreaCard(areaName: area));
    }
    areaSearchCtrl.clear();
    showAreaDropdown.value = false;
  }

  void removeArea(String area) {
    selectedAreas.remove(area);
    areaCards.removeWhere((c) => c.areaName == area);
    selectedSeatIds.removeWhere((id) => _seatAreaLabel(id) == area);
  }

  void toggleSeatArea(String seatId) {
    final label = _seatAreaLabel(seatId);
    if (selectedSeatIds.contains(seatId)) {
      selectedSeatIds.remove(seatId);
      final stillHas = selectedSeatIds.any((id) => _seatAreaLabel(id) == label);
      if (!stillHas) removeArea(label);
    } else {
      selectedSeatIds.add(seatId);
      addArea(label);
    }
  }

  String _seatAreaLabel(String seatId) {
    if (seatId.startsWith('LAV') || seatId == 'Closet') {
      if (seatId.contains('FWD')) return 'FWD LAV';
      if (seatId.contains('MID L')) return 'MID LAV L';
      if (seatId.contains('MID R')) return 'MID LAV R';
      if (seatId.contains('AFT L')) return 'AFT LAV L';
      if (seatId.contains('AFT R')) return 'AFT LAV R';
      return seatId;
    }
    if (seatId.startsWith('Galley')) {
      return seatId.contains('FWD') ? 'Front Galley' : 'Rear Galley';
    }
    final rowStr = seatId.replaceAll(RegExp(r'[A-Za-z]'), '');
    final rowNum = int.tryParse(rowStr) ?? 0;
    final map = currentAircraftMap;
    for (final section in map.sections) {
      if (rowNum >= section.startRow && rowNum <= section.endRow) {
        final n = section.name.toLowerCase();
        if (n.contains('first') || n.contains('business')) return 'First Class';
        if (n.contains('comfort')) return 'Delta Comfort';
        return 'Main Cabin';
      }
    }
    return 'Main Cabin';
  }

  void setAreaStatus(String area, String status) {
    final card = areaCards.firstWhereOrNull((c) => c.areaName == area);
    if (card != null) {
      card.status = status;
      areaCards.refresh();
    }
    for (final seatId in selectedSeatIds) {
      if (_seatAreaLabel(seatId) == area) {
        auditedSeats[seatId] = status;
      }
    }
  }

  void addAreaImage(String area, File file) {
    final card = areaCards.firstWhereOrNull((c) => c.areaName == area);
    if (card != null) {
      card.images.add(file);
      areaCards.refresh();
    }
  }

  void removeAreaImage(String area, int index) {
    final card = areaCards.firstWhereOrNull((c) => c.areaName == area);
    if (card != null) {
      card.images.removeAt(index);
      areaCards.refresh();
    }
  }

  void markSeat(String id, String status) => auditedSeats[id] = status;
  void clearSeat(String id) => auditedSeats.remove(id);

  AircraftSeatMap get currentAircraftMap =>
      aircraftMaps[selectedAircraft.value] ?? aircraftMaps.values.first;

  static String get currentDateTime {
    final n = DateTime.now();
    return '${n.month.toString().padLeft(2, '0')}/'
        '${n.day.toString().padLeft(2, '0')}/${n.year}  '
        '${n.hour.toString().padLeft(2, '0')}:'
        '${n.minute.toString().padLeft(2, '0')}';
  }

  void _initAircraftMaps() {
    aircraftMaps = {
      'Boeing 757-300 (75Y)': AircraftSeatMap(
        name: 'Boeing 757-300 (75Y)',
        hasFirstClassArc: true,
        sections: [
          SeatSection(
            name: 'First Class',
            startRow: 1,
            endRow: 6,
            leftCols: ['A', 'B'],
            rightCols: ['C', 'D'],
            amenitiesBefore: [
              AmenityRow(
                leftSvg: 'assets/icons/toilet.svg',
                leftId: 'LAV FWD',
                rightSvg: 'assets/icons/chiken.svg',
                rightId: 'Galley FWD',
              ),
            ],
            hasExitBefore: true,
            amenitiesAfter: [
              AmenityRow(customLabel: 'Closet'),
              AmenityRow(
                leftSvg: 'assets/icons/toilet.svg',
                leftId: 'LAV MID L',
                rightSvg: 'assets/icons/toilet.svg',
                rightId: 'LAV MID R',
              ),
            ],
          ),
          SeatSection(
            name: 'Delta Comfort',
            startRow: 14,
            endRow: 21,
            leftCols: ['A', 'B', 'C'],
            rightCols: ['D', 'E', 'F'],
            hasExitBefore: true,
            skipRows: [14],
          ),
          SeatSection(
            name: 'Delta Main',
            startRow: 22,
            endRow: 40,
            leftCols: ['A', 'B', 'C'],
            rightCols: ['D', 'E', 'F'],
            amenitiesAfter: [
              AmenityRow(
                leftSvg: 'assets/icons/toilet.svg',
                leftId: 'LAV AFT L',
                rightSvg: 'assets/icons/toilet.svg',
                rightId: 'LAV AFT R',
              ),
            ],
            hasExitAfter: true,
          ),
          SeatSection(
            name: '',
            startRow: 41,
            endRow: 49,
            leftCols: ['A', 'B', 'C'],
            rightCols: ['D', 'E', 'F'],
            amenitiesAfter: [
              AmenityRow(
                rightSvg: 'assets/icons/chiken.svg',
                rightId: 'Galley AFT',
                centerOnly: true,
              ),
            ],
            hasExitAfter: true,
          ),
        ],
      ),
      'Boeing 737-800': AircraftSeatMap(
        name: 'Boeing 737-800',
        sections: [
          SeatSection(
            name: 'First Class',
            startRow: 1,
            endRow: 4,
            leftCols: ['A', 'B'],
            rightCols: ['C', 'D'],
            amenitiesBefore: [
              AmenityRow(
                leftSvg: 'assets/icons/toilet.svg',
                leftId: 'LAV FWD',
                rightSvg: 'assets/icons/chiken.svg',
                rightId: 'Galley FWD',
              ),
            ],
            hasExitBefore: true,
          ),
          SeatSection(
            name: 'Main Cabin',
            startRow: 7,
            endRow: 20,
            leftCols: ['A', 'B', 'C'],
            rightCols: ['D', 'E', 'F'],
            hasExitBefore: true,
          ),
          SeatSection(
            name: '',
            startRow: 21,
            endRow: 33,
            leftCols: ['A', 'B', 'C'],
            rightCols: ['D', 'E', 'F'],
            hasExitAfter: true,
            amenitiesAfter: [
              AmenityRow(
                leftSvg: 'assets/icons/toilet.svg',
                leftId: 'LAV AFT L',
                rightSvg: 'assets/icons/toilet.svg',
                rightId: 'LAV AFT R',
              ),
              AmenityRow(
                rightSvg: 'assets/icons/chiken.svg',
                rightId: 'Galley AFT',
                centerOnly: true,
              ),
            ],
          ),
        ],
      ),
      'Airbus A320': AircraftSeatMap(
        name: 'Airbus A320',
        sections: [
          SeatSection(
            name: 'Business Class',
            startRow: 1,
            endRow: 3,
            leftCols: ['A', 'B'],
            rightCols: ['C', 'D'],
            amenitiesBefore: [
              AmenityRow(
                rightSvg: 'assets/icons/chiken.svg',
                rightId: 'Galley FWD',
                centerOnly: true,
              ),
            ],
          ),
          SeatSection(
            name: 'Economy',
            startRow: 8,
            endRow: 18,
            leftCols: ['A', 'B', 'C'],
            rightCols: ['D', 'E', 'F'],
            hasExitBefore: true,
          ),
          SeatSection(
            name: '',
            startRow: 19,
            endRow: 30,
            leftCols: ['A', 'B', 'C'],
            rightCols: ['D', 'E', 'F'],
            hasExitAfter: true,
            amenitiesAfter: [
              AmenityRow(
                leftSvg: 'assets/icons/toilet.svg',
                leftId: 'LAV L',
                rightSvg: 'assets/icons/toilet.svg',
                rightId: 'LAV R',
              ),
            ],
          ),
        ],
      ),
    };
  }

  @override
  void onClose() {
    areaSearchCtrl.dispose();
    otherFindingsCtrl.dispose();
    additionalNotesCtrl.dispose();
    super.onClose();
  }
}

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────
class CabinQualityAuditScreenN extends StatefulWidget {
  const CabinQualityAuditScreenN({super.key});

  @override
  State<CabinQualityAuditScreenN> createState() =>
      _CabinQualityAuditScreenNState();
}

class _CabinQualityAuditScreenNState extends State<CabinQualityAuditScreenN> {
  final _ctrl = Get.put(CabinQualityController());
  final _shipCtrl = TextEditingController();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  // Steps: 0 = Instruction + Section 1
  //        1 = Section 2 (Checklist + Seat Map)
  //        2 = Section 3 (Finalize)
  int _step = 0;

  final RxList<File> _generalImages = <File>[].obs;
  final ImagePicker _picker = ImagePicker();

  // ── 100MB image validation ────────────────────────────
  Future<List<File>> _pickValidatedImages() async {
    final picked = await _picker.pickMultiImage();
    final List<File> valid = [];
    final List<String> oversized = [];

    for (final x in picked) {
      final file = File(x.path);
      final size = await file.length();
      if (size > kMaxImageBytes) {
        oversized.add(x.name);
      } else {
        valid.add(file);
      }
    }

    if (oversized.isNotEmpty) {
      Get.snackbar(
        'Image Too Large',
        '${oversized.join(', ')} exceeds the 100MB limit and was not added.',
        backgroundColor: _C.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    }
    return valid;
  }

  @override
  void dispose() {
    _shipCtrl.dispose();
    _signatureController.dispose();
    super.dispose();
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

  // ── App Bar ───────────────────────────────────────────
  AppBar _buildAppBar() => AppBar(
    backgroundColor: _C.white,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    leading: IconButton(
      icon: Icon(Icons.arrow_back_rounded, color: _C.primary, size: 22.sp),
      onPressed: () => _step > 0 ? setState(() => _step--) : Get.back(),
    ),
    title: Text(
      'Cabin Security Search',
      style: GoogleFonts.dmSans(
        fontSize: 17.sp,
        fontWeight: FontWeight.w600,
        color: _C.primary,
      ),
    ),
    centerTitle: true,
    actions: [
      IconButton(
        icon: Icon(Icons.info_outline_rounded, color: _C.primary, size: 22.sp),
        onPressed: _showInstructions,
      ),
    ],
  );

  // ─────────────────────────────────────────────
  // STEP 0
  // ─────────────────────────────────────────────
  Widget _buildStep0() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInstructionBanner(),
                SizedBox(height: 16.h),
                _buildReferenceImage(),
                SizedBox(height: 16.h),
                _buildSection1(),
              ],
            ),
          ),
        ),
        _nextButton(() {
          if (_ctrl.selectedGate.value == 'Please Select One') {
            Get.snackbar(
              'Incomplete',
              'Please select a Gate before continuing.',
              backgroundColor: _C.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
              duration: const Duration(seconds: 3),
            );
            return;
          }
          if (_ctrl.shipNumber.value.trim().isEmpty) {
            Get.snackbar(
              'Incomplete',
              'Please enter the Ship # before continuing.',
              backgroundColor: _C.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
              duration: const Duration(seconds: 3),
            );
            return;
          }
          setState(() => _step = 1);
        }),
      ],
    );
  }

  Widget _buildReferenceImage() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _C.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: Image.asset(
          'assets/images/indor.png',
          height: 180.h,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 180.h,
            decoration: BoxDecoration(
              color: _C.infoBg,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flight_rounded, color: _C.primary, size: 40.sp),
                SizedBox(height: 8.h),
                Text(
                  'Cabin Interior Reference',
                  style: GoogleFonts.dmSans(
                    fontSize: 13.sp,
                    color: _C.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Section 1 ────────────────────────────────────────
  Widget _buildSection1() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _ctrl.sec1Expanded.value = !_ctrl.sec1Expanded.value,
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: _C.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: _C.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4.w,
                    height: 18.h,
                    decoration: BoxDecoration(
                      color: _C.primary,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'Section 1: Training Info',
                      style: GoogleFonts.dmSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: _C.dark,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _ctrl.sec1Expanded.value ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _C.grey,
                      size: 22.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_ctrl.sec1Expanded.value) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: _C.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: _C.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Date and Time'),
                  _readOnlyField(
                    CabinQualityController.currentDateTime,
                    icon: Icons.calendar_month_outlined,
                  ),
                  SizedBox(height: 14.h),
                  _label('Supervisor / Lead'),
                  _readOnlyField(
                    _ctrl.supervisorName.value,
                    icon: Icons.person_outline_rounded,
                  ),

                  SizedBox(height: 14.h),
                  _label('Gate *'),
                  Obx(
                    () => _pillDropdown(
                      value: _ctrl.selectedGate.value,
                      items: _ctrl.gateOptions,
                      onChanged: (v) => _ctrl.selectedGate.value = v!,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  _label('Ship # *'),
                  _pillTextField(
                    controller: _shipCtrl,
                    hint: 'Enter ship number',
                    onChanged: (v) => _ctrl.shipNumber.value = v,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // STEP 1
  // ─────────────────────────────────────────────
  Widget _buildStep1() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                _buildSection2(),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
        _nextButton(() {
          if (_ctrl.selectedAreas.isEmpty) {
            Get.snackbar(
              'Incomplete',
              'Please select at least one area to inspect.',
              backgroundColor: _C.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
              duration: const Duration(seconds: 3),
            );
            return;
          }
          if (_ctrl.areaCards.any((c) => c.status.isEmpty)) {
            Get.snackbar(
              'Incomplete',
              'Please mark Pass or Fail for all selected areas.',
              backgroundColor: _C.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
              duration: const Duration(seconds: 3),
            );
            return;
          }
          setState(() => _step = 2);
        }),
      ],
    );
  }

  // ── Section 2 (reordered: area search first, aircraft below) ──
  Widget _buildSection2() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          InkWell(
            onTap: () => _ctrl.sec2Expanded.value = !_ctrl.sec2Expanded.value,
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: _C.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: _C.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4.w,
                    height: 18.h,
                    decoration: BoxDecoration(
                      color: _C.primary,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'Section 2: Inspection Checklist',
                      style: GoogleFonts.dmSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: _C.dark,
                      ),
                    ),
                  ),
                  Obx(() {
                    final count = _ctrl.selectedAreas.length;
                    if (count == 0) return const SizedBox.shrink();
                    return Container(
                      margin: EdgeInsets.only(right: 8.w),
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: _C.primary,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        '$count',
                        style: GoogleFonts.dmSans(
                          fontSize: 11.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }),
                  AnimatedRotation(
                    turns: _ctrl.sec2Expanded.value ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _C.grey,
                      size: 22.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_ctrl.sec2Expanded.value) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: _C.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: _C.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 1. Search & Select Area (TOP) ─────────────
                  _label('Search & Select Area *'),
                  SizedBox(height: 8.h),
                  _buildAreaSearchField(),
                  SizedBox(height: 6.h),

                  // Dropdown suggestions
                  Obx(() {
                    if (!_ctrl.showAreaDropdown.value)
                      return const SizedBox.shrink();
                    return Container(
                      constraints: BoxConstraints(maxHeight: 180.h),
                      decoration: BoxDecoration(
                        color: _C.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: _C.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        children: _ctrl.filteredAreas.map((area) {
                          final already = _ctrl.selectedAreas.contains(area);
                          return ListTile(
                            dense: true,
                            title: Text(
                              area,
                              style: GoogleFonts.dmSans(
                                fontSize: 13.sp,
                                color: already ? _C.grey : _C.dark,
                              ),
                            ),
                            trailing: already
                                ? Icon(
                                    Icons.check_rounded,
                                    color: _C.primary,
                                    size: 16.sp,
                                  )
                                : null,
                            onTap: already ? null : () => _ctrl.addArea(area),
                          );
                        }).toList(),
                      ),
                    );
                  }),
                  SizedBox(height: 12.h),

                  // Area tag chips
                  Obx(() {
                    if (_ctrl.selectedAreas.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Text(
                          'Tap seats on the map or search to add areas.',
                          style: GoogleFonts.dmSans(
                            fontSize: 12.sp,
                            color: _C.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    }
                    return Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: _ctrl.selectedAreas.map((area) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: _C.primary,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                area,
                                style: GoogleFonts.dmSans(
                                  fontSize: 12.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              GestureDetector(
                                onTap: () => _ctrl.removeArea(area),
                                child: Icon(
                                  Icons.close,
                                  size: 14.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  }),
                  SizedBox(height: 16.h),

                  // Dynamic area cards
                  Obx(() {
                    if (_ctrl.areaCards.isEmpty) return const SizedBox.shrink();
                    return Column(
                      children: _ctrl.areaCards
                          .map((card) => _buildAreaCard(card))
                          .toList(),
                    );
                  }),

                  // ── Divider ───────────────────────────────────
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(child: Divider(color: _C.border)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Text(
                          'select area on the seat map',
                          style: GoogleFonts.dmSans(
                            fontSize: 11.sp,
                            color: _C.grey,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: _C.border)),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // ── 2. Type of Aircraft (BELOW area search) ───
                  _label('Type of Aircraft *'),
                  Obx(
                    () => _pillDropdown(
                      value: _ctrl.selectedAircraft.value,
                      items: _ctrl.aircraftOptions,
                      onChanged: (v) => _ctrl.selectedAircraft.value = v!,
                      suffixIcon: Icons.search_rounded,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Legend
                  _buildLegend(),
                  SizedBox(height: 12.h),

                  // Seat Map
                  _buildSeatMap(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // STEP 2
  // ─────────────────────────────────────────────
  Widget _buildStep2() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                _buildSection3(),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
        _buildSubmitButton(),
      ],
    );
  }

  // ── Section 3 ────────────────────────────────────────
  Widget _buildSection3() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _ctrl.sec3Expanded.value = !_ctrl.sec3Expanded.value,
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: _C.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: _C.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4.w,
                    height: 18.h,
                    decoration: BoxDecoration(
                      color: _C.primary,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'Section 3: Finalize',
                      style: GoogleFonts.dmSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: _C.dark,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _ctrl.sec3Expanded.value ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _C.grey,
                      size: 22.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_ctrl.sec3Expanded.value) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: _C.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: _C.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Other Findings'),
                  _multilineField(
                    'Enter any additional findings...',
                    controller: _ctrl.otherFindingsCtrl,
                  ),
                  SizedBox(height: 14.h),
                  _label('Additional Notes'),
                  _multilineField(
                    'Enter additional notes...',
                    controller: _ctrl.additionalNotesCtrl,
                  ),
                  SizedBox(height: 14.h),
                  _label('Pictures'),
                  _uploadBox(),
                  SizedBox(height: 10.h),
                  Obx(
                    () => _generalImages.isEmpty
                        ? const SizedBox.shrink()
                        : Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: _generalImages.asMap().entries.map((e) {
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: Image.file(
                                      e.value,
                                      width: 80.w,
                                      height: 80.w,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () =>
                                          _generalImages.removeAt(e.key),
                                      child: Container(
                                        padding: EdgeInsets.all(2.r),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 13.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                  ),
                  SizedBox(height: 14.h),
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
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SUBMIT BUTTON — success popup then navigate
  // ─────────────────────────────────────────────
  Widget _buildSubmitButton() {
    return Obx(() {
      final valid = _ctrl.isFormValid;
      return Container(
        color: _C.white,
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
        child: GestureDetector(
          onTap: () {
            if (!valid) {
              Get.snackbar(
                'Incomplete Form',
                _ctrl.validationMessage,
                backgroundColor: _C.red,
                colorText: Colors.white,
                snackPosition: SnackPosition.TOP,
                duration: const Duration(seconds: 3),
              );
              return;
            }
            _handleSubmit();
          },
          child: Container(
            height: 52.h,
            decoration: BoxDecoration(
              color: valid ? _C.primary : _C.border,
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send_rounded, color: Colors.white, size: 18.sp),
                SizedBox(width: 10.w),
                Text(
                  'SEND AUDIT REPORT',
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ─────────────────────────────────────────────
  // HANDLE SUBMIT — show success dialog then go
  // ─────────────────────────────────────────────
  void _handleSubmit() {
    final now = DateTime.now();
    final dateStr = '${_monthName(now.month)} ${now.day}, ${now.year}';
    final timeStr =
        '${_padTwo(now.hour)}:${_padTwo(now.minute)} ${now.hour < 12 ? 'AM' : 'PM'}';

    final newItem = TrainingItem(
      id: now.millisecondsSinceEpoch.toString(),
      observerName: _ctrl.supervisorName.value,
      observerImage: 'assets/images/nirob.jpg',
      date: dateStr,
      time: timeStr,
      dateTime: now,
      gate: _ctrl.selectedGate.value,
      shipNumber: _ctrl.shipNumber.value.trim(),
      role: _ctrl.supervisorRole.value,
      locationImage: _generalImages.isNotEmpty
          ? _generalImages.first.path
          : 'assets/images/indor.png',
      locationImage2: _generalImages.length > 1
          ? _generalImages[1].path
          : 'assets/images/window.png',
      isPassed: _ctrl.areaCards.every((c) => c.status == 'pass'),
      areaResults: _ctrl.areaCards
          .map((c) => {'area': c.areaName, 'status': c.status})
          .toList(),
      otherFindings: _ctrl.otherFindingsCtrl.text.trim(),
      additionalNotes: _ctrl.additionalNotesCtrl.text.trim(),
    );

    // Show success popup
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          decoration: BoxDecoration(
            color: _C.white,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated success icon container
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: _C.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: _C.green,
                  size: 48.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Report Submitted!',
                style: GoogleFonts.dmSans(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: _C.dark,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Your cabin security audit report has been submitted successfully.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 13.sp,
                  color: _C.grey,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 8.h),
              // Summary row
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: _C.bg,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    _summaryRow(
                      Icons.local_airport_rounded,
                      'Gate',
                      _ctrl.selectedGate.value,
                    ),
                    SizedBox(height: 6.h),
                    _summaryRow(
                      Icons.tag_rounded,
                      'Ship #',
                      _ctrl.shipNumber.value.trim(),
                    ),
                    SizedBox(height: 6.h),
                    _summaryRow(
                      Icons.location_on_rounded,
                      'Areas',
                      '${_ctrl.areaCards.length} inspected',
                    ),
                    SizedBox(height: 6.h),
                    _summaryRow(
                      Icons.bar_chart_rounded,
                      'Result',
                      newItem.isPassed ? 'All Passed ✓' : 'Some Failed ✗',
                      valueColor: newItem.isPassed ? _C.green : _C.red,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              // Done button
              GestureDetector(
                onTap: () {
                  // Close dialog first
                  Navigator.of(context).pop();
                  // Navigate back to CabinSecurityTrainingScreen with result
                  Get.back(result: newItem);
                },
                child: Container(
                  width: double.infinity,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: _C.primary,
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Done',
                    style: GoogleFonts.dmSans(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: _C.primary),
        SizedBox(width: 6.w),
        Text(
          '$label: ',
          style: GoogleFonts.dmSans(
            fontSize: 12.sp,
            color: _C.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 12.sp,
              color: valueColor ?? _C.dark,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // INSTRUCTION BANNER
  // ─────────────────────────────────────────────
  Widget _buildInstructionBanner() {
    const instructions = [
      'Hide Test objects and take pictures of where you hide them and then have the team search. Go back and mark the one they did not find.',
      'The goal is to find common areas of failure so we can focus on those areas for a TSA Audit.',
      'Do not tell agents how many objects were hidden.',
      'Only tell them where the objects are after the team says they have completed the search fully.',
      'Conduct Audits Proactive and Submit them as you do them; Do not wait until the End of the Shift to complete them.',
    ];
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _C.infoBg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _C.infoBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_rounded, color: _C.primary, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Instructions',
                style: GoogleFonts.dmSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: _C.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ...instructions.asMap().entries.map(
            (e) => Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${e.key + 1}. ',
                    style: GoogleFonts.dmSans(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: _C.primary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      e.value,
                      style: GoogleFonts.dmSans(
                        fontSize: 12.sp,
                        color: _C.dark,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // LEGEND
  // ─────────────────────────────────────────────
  Widget _buildLegend() {
    return Wrap(
      spacing: 14.w,
      runSpacing: 6.h,
      children: [_legendDot(_C.green, 'Pass'), _legendDot(_C.red, 'Fail')],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.w,
          height: 10.h,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: GoogleFonts.dmSans(fontSize: 10.sp, color: _C.grey),
        ),
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
                  ...aircraftMap.sections.map((s) => _buildSection(s)),
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
          ...section.amenitiesBefore!.map((a) {
            if (a.customLabel != null) return _buildClosetRow();
            return _buildAmenityRow(
              leftSvg: a.leftSvg,
              leftId: a.leftId,
              rightSvg: a.rightSvg,
              rightId: a.rightId,
              centerOnly: a.centerOnly,
            );
          }),
        if (section.hasExitBefore) _buildExitRow(),
        SizedBox(height: 4.h),
        if (section.name.isNotEmpty) _buildSectionLabel(section.name),
        SizedBox(height: 4.h),
        _buildColHeaders([...section.leftCols, '', ...section.rightCols]),
        SizedBox(height: 4.h),
        ...List.generate(section.endRow - section.startRow + 1, (i) {
          final rowNum = section.startRow + i;
          if (section.skipRows != null && section.skipRows!.contains(rowNum)) {
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
          ...section.amenitiesAfter!.map(
            (a) => _buildAmenityRow(
              leftSvg: a.leftSvg,
              leftId: a.leftId,
              rightSvg: a.rightSvg,
              rightId: a.rightId,
              centerOnly: a.centerOnly,
            ),
          ),
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
          const radius = 72.0;
          final x = -radius * (1 - 2 * i / 8);
          final y = -radius * 0.6 * (0.5 - (i / 8 - 0.5).abs());
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
            .map(
              (c) => c.isEmpty
                  ? SizedBox(width: 28.w)
                  : SizedBox(
                      width: 34.w,
                      child: Center(
                        child: Text(
                          c,
                          style: GoogleFonts.dmSans(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: _C.grey,
                          ),
                        ),
                      ),
                    ),
            )
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
          ...leftCols.map(
            (col) => col.isEmpty ? SizedBox(width: 34.w) : _seat('$rowNum$col'),
          ),
          SizedBox(
            width: 28.w,
            child: Center(
              child: Text(
                '$rowNum',
                style: GoogleFonts.dmSans(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: _C.grey,
                ),
              ),
            ),
          ),
          ...rightCols.map(
            (col) => col.isEmpty ? SizedBox(width: 34.w) : _seat('$rowNum$col'),
          ),
        ],
      ),
    );
  }

  Widget _seat(String id) {
    return Obx(() {
      final status = _ctrl.auditedSeats[id];
      final isSelected = _ctrl.selectedSeatIds.contains(id);
      final color = status == 'pass'
          ? _C.green
          : status == 'fail'
          ? _C.red
          : isSelected
          ? _C.primary
          : _C.seatColor;
      return GestureDetector(
        onTap: () => _ctrl.toggleSeatArea(id),
        child: Container(
          width: 30.w,
          height: 32.h,
          margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
          child: CustomPaint(painter: _SeatPainter(color: color)),
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
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 40.w),
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
      final isSelected = _ctrl.selectedSeatIds.contains(id);
      final color = status == 'pass'
          ? _C.green
          : status == 'fail'
          ? _C.red
          : isSelected
          ? _C.primary
          : _C.seatColor;
      return GestureDetector(
        onTap: () => _ctrl.toggleSeatArea(id),
        child: Container(
          width: 44.w,
          height: 44.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10.r),
            border: isSelected
                ? Border.all(color: Colors.white, width: 2)
                : null,
          ),
          child: Center(
            child: SvgPicture.asset(
              svgPath,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
              width: 22.sp,
              height: 22.sp,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildExitRow() => Padding(
    padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 20.w),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '◁ Exit',
          style: GoogleFonts.dmSans(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: _C.grey,
          ),
        ),
        Text(
          'Exit ▷',
          style: GoogleFonts.dmSans(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: _C.grey,
          ),
        ),
      ],
    ),
  );

  Widget _buildClosetRow() => Padding(
    padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 40.w),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Closet',
          style: GoogleFonts.dmSans(
            fontSize: 12.sp,
            color: _C.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        _amenityBox('assets/icons/toilet.svg', 'Closet'),
      ],
    ),
  );

  Widget _buildSectionLabel(String t) => Padding(
    padding: EdgeInsets.symmetric(vertical: 10.h),
    child: Center(
      child: Text(
        t,
        style: GoogleFonts.dmSans(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: _C.dark,
        ),
      ),
    ),
  );

  // ─────────────────────────────────────────────
  // AREA SEARCH FIELD
  // ─────────────────────────────────────────────
  Widget _buildAreaSearchField() {
    return TextField(
      controller: _ctrl.areaSearchCtrl,
      style: GoogleFonts.dmSans(fontSize: 14.sp, color: _C.dark),
      onTap: () => _ctrl.showAreaDropdown.value = true,
      decoration: InputDecoration(
        hintText: 'Search area (e.g. Front Galley, MID LAV...)',
        hintStyle: GoogleFonts.dmSans(fontSize: 13.sp, color: _C.grey),
        prefixIcon: Icon(Icons.search_rounded, size: 18.sp, color: _C.grey),
        filled: true,
        fillColor: _C.inputBg,
        contentPadding: EdgeInsets.symmetric(vertical: 13.h, horizontal: 16.w),
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
  }

  // ─────────────────────────────────────────────
  // DYNAMIC AREA CARD
  // ─────────────────────────────────────────────
  Widget _buildAreaCard(AreaCard card) {
    return Obx(() {
      _ctrl.areaCards.length;
      final status = card.status;
      return Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: _C.bg,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: status == 'pass'
                ? _C.green.withValues(alpha: 0.4)
                : status == 'fail'
                ? _C.red.withValues(alpha: 0.4)
                : _C.border,
            width: status.isNotEmpty ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_searching_rounded,
                  color: _C.primary,
                  size: 16.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  '${card.areaName} *',
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: _C.dark,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _buildStatusButton(
                    label: 'Pass',
                    icon: Icons.check,
                    isSelected: status == 'pass',
                    color: _C.green,
                    onTap: () => _ctrl.setAreaStatus(card.areaName, 'pass'),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _buildStatusButton(
                    label: 'Fail',
                    icon: Icons.close,
                    isSelected: status == 'fail',
                    color: _C.red,
                    onTap: () => _ctrl.setAreaStatus(card.areaName, 'fail'),
                  ),
                ),
              ],
            ),
            if (status == 'fail') ...[
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _C.red.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: _C.red,
                      size: 14.sp,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        'Team failed to find the hidden object in this area.',
                        style: GoogleFonts.dmSans(
                          fontSize: 11.sp,
                          color: _C.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (status.isNotEmpty) ...[
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () async {
                  final files = await _pickValidatedImages();
                  for (final f in files) {
                    _ctrl.addAreaImage(card.areaName, f);
                  }
                },
                child: Container(
                  height: 46.h,
                  decoration: BoxDecoration(
                    color: _C.white,
                    borderRadius: BorderRadius.circular(25.r),
                    border: Border.all(color: _C.border, width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 18.sp,
                        color: _C.grey,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Upload an Image',
                        style: GoogleFonts.dmSans(
                          fontSize: 13.sp,
                          color: _C.grey,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '(max 100MB)',
                        style: GoogleFonts.dmSans(
                          fontSize: 10.sp,
                          color: _C.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (card.images.isNotEmpty) ...[
                SizedBox(height: 10.h),
                SizedBox(
                  height: 72.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: card.images.length,
                    itemBuilder: (_, i) => Stack(
                      children: [
                        Container(
                          width: 64.w,
                          height: 64.h,
                          margin: EdgeInsets.only(right: 8.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: _C.border, width: 1),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.file(
                              card.images[i],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 10,
                          child: GestureDetector(
                            onTap: () =>
                                _ctrl.removeAreaImage(card.areaName, i),
                            child: Container(
                              padding: EdgeInsets.all(2.r),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 12.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      );
    });
  }

  // ─────────────────────────────────────────────
  // SHARED HELPERS
  // ─────────────────────────────────────────────
  String _monthName(int m) => const [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][m];

  String _padTwo(int v) => v.toString().padLeft(2, '0');

  Widget _buildStatusButton({
    required String label,
    required IconData? icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 44.h,
      decoration: BoxDecoration(
        color: isSelected ? color : _C.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: isSelected ? color : _C.border, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18.sp, color: isSelected ? Colors.white : _C.grey),
            SizedBox(width: 5.w),
          ],
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : _C.grey,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _label(String t) => Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: Text(
      t,
      style: GoogleFonts.dmSans(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: _C.primary,
      ),
    ),
  );

  TextStyle _fieldStyle() =>
      GoogleFonts.dmSans(fontSize: 15.sp, color: _C.dark);

  Widget _readOnlyField(String value, {IconData? icon}) => Container(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    decoration: BoxDecoration(
      color: _C.inputBg,
      borderRadius: BorderRadius.circular(30.r),
      border: Border.all(color: _C.border),
    ),
    child: Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18.sp, color: _C.grey),
          SizedBox(width: 10.w),
        ],
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.dmSans(fontSize: 14.sp, color: _C.grey),
          ),
        ),
        Icon(Icons.lock_outline_rounded, size: 14.sp, color: _C.border),
      ],
    ),
  );

  Widget _pillTextField({
    required TextEditingController controller,
    required String hint,
    void Function(String)? onChanged,
  }) => TextField(
    controller: controller,
    onChanged: onChanged,
    style: _fieldStyle(),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.dmSans(fontSize: 14.sp, color: _C.grey),
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
        icon: Icon(
          suffixIcon ?? Icons.keyboard_arrow_down_rounded,
          color: _C.grey,
          size: 20.sp,
        ),
        style: _fieldStyle(),
        items: items
            .map((i) => DropdownMenuItem(value: i, child: Text(i)))
            .toList(),
        onChanged: onChanged,
      ),
    ),
  );

  Widget _multilineField(String hint, {TextEditingController? controller}) =>
      TextField(
        controller: controller,
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
    onTap: () async {
      final files = await _pickValidatedImages();
      _generalImages.addAll(files);
    },
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
          Text(
            'Upload Images',
            style: GoogleFonts.dmSans(fontSize: 14.sp, color: _C.grey),
          ),
          SizedBox(width: 6.w),
          Text(
            '(max 100MB each)',
            style: GoogleFonts.dmSans(fontSize: 10.sp, color: _C.grey),
          ),
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
        child: Text(
          'NEXT',
          style: GoogleFonts.dmSans(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
    ),
  );

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: _C.primary, size: 24.sp),
            SizedBox(width: 8.w),
            Text(
              'How to use',
              style: GoogleFonts.dmSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          '1. Read the instructions and reference image carefully.\n'
          '2. Fill in Gate and Ship # in Section 1.\n'
          '3. Search or tap seats on the map to select areas.\n'
          '4. Select aircraft type and review the seat map.\n'
          '5. Mark each area as Pass or Fail, upload a photo.\n'
          '6. Add findings, notes, and sign in Section 3 before submitting.',
          style: GoogleFonts.dmSans(
            fontSize: 13.sp,
            color: _C.grey,
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Got it',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                color: _C.primary,
              ),
            ),
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
        const Radius.circular(5),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-1, h * 0.55, w + 2, h * 0.38),
        const Radius.circular(4),
      ),
      paint,
    );
    final armPaint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-3, h * 0.25, 4, h * 0.45),
        const Radius.circular(2),
      ),
      armPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w - 1, h * 0.25, 4, h * 0.45),
        const Radius.circular(2),
      ),
      armPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SeatPainter old) => old.color != color;
}

class _PlaneSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {}
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
