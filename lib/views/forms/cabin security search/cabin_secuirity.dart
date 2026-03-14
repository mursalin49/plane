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
  static const Color infoBg    = Color(0xFFEEF2FF);
  static const Color infoBorder= Color(0xFFB0BEF8);
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

// ─────────────────────────────────────────────
// AREA CARD MODEL
// ─────────────────────────────────────────────
class AreaCard {
  final String areaName;
  String status; // '' | 'pass' | 'fail'
  List<File> images;

  AreaCard({required this.areaName})
      : status = '',
        images = [];
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
  final selectedAircraft  = 'Boeing 757-300 (75Y)'.obs;
  final selectedGate      = 'Gate - A'.obs;
  final auditedSeats      = <String, String>{}.obs;

  // Area search & dynamic cards
  final RxList<String>   selectedAreas   = <String>[].obs;
  final RxList<AreaCard> areaCards       = <AreaCard>[].obs;
  final areaSearchCtrl                   = TextEditingController();
  final RxList<String>   filteredAreas   = <String>[].obs;
  final RxBool           showAreaDropdown= false.obs;

  // Seat map — selected seat ids (tap to toggle area tag)
  final RxSet<String> selectedSeatIds = <String>{}.obs;

  // Section 2 expand state
  final sec2Expanded = true.obs;

  final List<String> aircraftOptions = [
    'Boeing 757-300 (75Y)',
    'Boeing 737-800',
    'Airbus A320',
  ];
  final List<String> gateOptions = [
    'Gate - A', 'Gate - B', 'Gate - C', 'Gate - D',
  ];

  late final Map<String, AircraftSeatMap> aircraftMaps;

  @override
  void onInit() {
    super.onInit();
    filteredAreas.assignAll(kCabinAreas);
    areaSearchCtrl.addListener(_onAreaSearch);
    _initAircraftMaps();
  }

  void _onAreaSearch() {
    final q = areaSearchCtrl.text.toLowerCase();
    filteredAreas.assignAll(q.isEmpty
        ? kCabinAreas
        : kCabinAreas.where((a) => a.toLowerCase().contains(q)));
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

  /// Called when a seat/amenity is tapped on the map
  void toggleSeatArea(String seatId) {
    final label = _seatAreaLabel(seatId);
    if (selectedSeatIds.contains(seatId)) {
      // Deselect
      selectedSeatIds.remove(seatId);
      // Only remove area tag if no other seat from same area is selected
      final stillHas = selectedSeatIds.any((id) => _seatAreaLabel(id) == label);
      if (!stillHas) removeArea(label);
    } else {
      // Select
      selectedSeatIds.add(seatId);
      addArea(label);
    }
  }

  /// Map seatId → readable area label
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
    // Parse row number
    final rowStr = seatId.replaceAll(RegExp(r'[A-Za-z]'), '');
    final rowNum = int.tryParse(rowStr) ?? 0;
    final map = currentAircraftMap;
    for (final section in map.sections) {
      if (rowNum >= section.startRow && rowNum <= section.endRow) {
        final n = section.name.toLowerCase();
        if (n.contains('first') || n.contains('business')) return 'First Class';
        if (n.contains('comfort')) return 'Delta Comfort';
        if (n.contains('main') || n.contains('economy')) return 'Main Cabin';
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
    // Update seat colors on the map for seats in this area
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
              AmenityRow(leftSvg: 'assets/icons/toilet.svg', leftId: 'LAV FWD',
                  rightSvg: 'assets/icons/chiken.svg', rightId: 'Galley FWD'),
            ],
            hasExitBefore: true,
            amenitiesAfter: [
              AmenityRow(customLabel: 'Closet'),
              AmenityRow(leftSvg: 'assets/icons/toilet.svg', leftId: 'LAV MID L',
                  rightSvg: 'assets/icons/toilet.svg', rightId: 'LAV MID R'),
            ],
          ),
          SeatSection(
            name: 'Delta Comfort',
            startRow: 14, endRow: 21,
            leftCols: ['A', 'B', 'C'], rightCols: ['D', 'E', 'F'],
            hasExitBefore: true, skipRows: [14],
          ),
          SeatSection(
            name: 'Delta Main',
            startRow: 22, endRow: 40,
            leftCols: ['A', 'B', 'C'], rightCols: ['D', 'E', 'F'],
            amenitiesAfter: [
              AmenityRow(leftSvg: 'assets/icons/toilet.svg', leftId: 'LAV AFT L',
                  rightSvg: 'assets/icons/toilet.svg', rightId: 'LAV AFT R'),
            ],
            hasExitAfter: true,
          ),
          SeatSection(
            name: '',
            startRow: 41, endRow: 49,
            leftCols: ['A', 'B', 'C'], rightCols: ['D', 'E', 'F'],
            amenitiesAfter: [
              AmenityRow(rightSvg: 'assets/icons/chiken.svg', rightId: 'Galley AFT', centerOnly: true),
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
            startRow: 1, endRow: 4,
            leftCols: ['A', 'B'], rightCols: ['C', 'D'],
            amenitiesBefore: [
              AmenityRow(leftSvg: 'assets/icons/toilet.svg', leftId: 'LAV FWD',
                  rightSvg: 'assets/icons/chiken.svg', rightId: 'Galley FWD'),
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
              AmenityRow(leftSvg: 'assets/icons/toilet.svg', leftId: 'LAV AFT L',
                  rightSvg: 'assets/icons/toilet.svg', rightId: 'LAV AFT R'),
              AmenityRow(rightSvg: 'assets/icons/chiken.svg', rightId: 'Galley AFT', centerOnly: true),
            ],
          ),
        ],
      ),
      'Airbus A320': AircraftSeatMap(
        name: 'Airbus A320',
        sections: [
          SeatSection(
            name: 'Business Class',
            startRow: 1, endRow: 3,
            leftCols: ['A', 'B'], rightCols: ['C', 'D'],
            amenitiesBefore: [
              AmenityRow(rightSvg: 'assets/icons/chiken.svg', rightId: 'Galley FWD', centerOnly: true),
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
              AmenityRow(leftSvg: 'assets/icons/toilet.svg', leftId: 'LAV L',
                  rightSvg: 'assets/icons/toilet.svg', rightId: 'LAV R'),
            ],
          ),
        ],
      ),
    };
  }

  @override
  void onClose() {
    areaSearchCtrl.dispose();
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

class _CabinQualityAuditScreenNState
    extends State<CabinQualityAuditScreenN> {
  final _ctrl = Get.put(CabinQualityController());
  final _supervisorCtrl = TextEditingController();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  // Steps: 0 = Training Info, 1 = Seat Map + Area Checklist, 2 = Finalize
  int _step = 0;

  final RxList<File> _selectedImages = <File>[].obs;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      _selectedImages.addAll(images.map((img) => File(img.path)));
    }
  }

  Future<List<File>> _pickMulti() async {
    final picked = await _picker.pickMultiImage();
    return picked.map((x) => File(x.path)).toList();
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
        icon: Icon(Icons.info_outline_rounded,
            color: _C.primary, size: 22.sp),
        onPressed: _showInstructions,
      ),
    ],
  );

  // ─────────────────────────────────────────────
  // STEP 0 — Instruction Banner + Training Info
  // ─────────────────────────────────────────────
  Widget _buildStep0() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Instruction Banner
                // _buildInstructionBanner(),
                SizedBox(height: 20.h),

                _label('Date and Time *'),
                _pillField(
                  child: Row(children: [
                    Expanded(
                        child: Text(_todayDate(), style: _fieldStyle())),
                    Icon(Icons.calendar_month_outlined,
                        size: 20.sp, color: _C.grey),
                  ]),
                ),
                SizedBox(height: 16.h),

                _label('Supervisor / Lead *'),
                _pillTextField(
                    controller: _supervisorCtrl, hint: 'John Doe'),
                SizedBox(height: 16.h),

                _label('Gate *'),
                Obx(() => _pillDropdown(
                  value: _ctrl.selectedGate.value,
                  items: _ctrl.gateOptions,
                  onChanged: (v) =>
                  _ctrl.selectedGate.value = v!,
                )),
              ],
            ),
          ),
        ),
        _nextButton(() => setState(() => _step = 1)),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // STEP 1 — Section 2: Inspection Checklist (Expandable)
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
                _buildSection2Header(),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
        _nextButton(() => setState(() => _step = 2)),
      ],
    );
  }

  // ── Section 2 Expandable Header ─────────────────────────
  Widget _buildSection2Header() {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header (tap to expand/collapse) ──
        InkWell(
          onTap: () => _ctrl.sec2Expanded.value =
          !_ctrl.sec2Expanded.value,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: 16.w, vertical: 14.h),
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
                // Selected areas count badge
                Obx(() {
                  final count = _ctrl.selectedAreas.length;
                  if (count == 0) return const SizedBox.shrink();
                  return Container(
                    margin: EdgeInsets.only(right: 8.w),
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: _C.primary,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      '$count',
                      style: GoogleFonts.dmSans(
                          fontSize: 11.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w700),
                    ),
                  );
                }),
                AnimatedRotation(
                  turns: _ctrl.sec2Expanded.value ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _C.grey,
                      size: 22.sp),
                ),
              ],
            ),
          ),
        ),

        // ── Section 2 body ─────────────────────────────
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
                // Aircraft type
                _label('Type of Aircraft *'),
                Obx(() => _pillDropdown(
                  value: _ctrl.selectedAircraft.value,
                  items: _ctrl.aircraftOptions,
                  onChanged: (v) =>
                  _ctrl.selectedAircraft.value = v!,
                  suffixIcon: Icons.search_rounded,
                )),
                SizedBox(height: 16.h),

                // Legend
                _buildLegend(),
                SizedBox(height: 12.h),

                // Seat Map
                _buildSeatMap(),
                SizedBox(height: 20.h),

                // Divider between map and search
                Row(children: [
                  Expanded(child: Divider(color: _C.border)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Text('or search area below',
                        style: GoogleFonts.dmSans(
                            fontSize: 11.sp, color: _C.grey)),
                  ),
                  Expanded(child: Divider(color: _C.border)),
                ]),
                SizedBox(height: 16.h),

                // Area search
                _label('Search & Select Area *'),
                SizedBox(height: 8.h),
                _buildAreaSearchField(),
                SizedBox(height: 6.h),

                // Search dropdown
                Obx(() {
                  if (!_ctrl.showAreaDropdown.value) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    constraints: BoxConstraints(maxHeight: 180.h),
                    decoration: BoxDecoration(
                      color: _C.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: _C.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      children: _ctrl.filteredAreas.map((area) {
                        final already =
                        _ctrl.selectedAreas.contains(area);
                        return ListTile(
                          dense: true,
                          title: Text(area,
                              style: GoogleFonts.dmSans(
                                  fontSize: 13.sp,
                                  color: already
                                      ? _C.grey
                                      : _C.dark)),
                          trailing: already
                              ? Icon(Icons.check_rounded,
                              color: _C.primary,
                              size: 16.sp)
                              : null,
                          onTap: already
                              ? null
                              : () => _ctrl.addArea(area),
                        );
                      }).toList(),
                    ),
                  );
                }),
                SizedBox(height: 12.h),

                // Selected area tags
                Obx(() {
                  if (_ctrl.selectedAreas.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: Text(
                        'Tap seats on the map or search to add areas.',
                        style: GoogleFonts.dmSans(
                            fontSize: 12.sp,
                            color: _C.grey,
                            fontStyle: FontStyle.italic),
                      ),
                    );
                  }
                  return Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children:
                    _ctrl.selectedAreas.map((area) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: _C.primary,
                          borderRadius:
                          BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(area,
                                style: GoogleFonts.dmSans(
                                    fontSize: 12.sp,
                                    color: Colors.white,
                                    fontWeight:
                                    FontWeight.w600)),
                            SizedBox(width: 6.w),
                            GestureDetector(
                              onTap: () =>
                                  _ctrl.removeArea(area),
                              child: Icon(Icons.close,
                                  size: 14.sp,
                                  color: Colors.white),
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
                  if (_ctrl.areaCards.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: _ctrl.areaCards
                        .map((card) => _buildAreaCard(card))
                        .toList(),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    ));
  }

  // ─────────────────────────────────────────────
  // STEP 2 — Findings / Notes / Pictures / Signature
  // ─────────────────────────────────────────────
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
                          top: 4,
                          right: 4,
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
                SizedBox(height: 16.h),

                // Signature
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _label('Signature *'),
                    GestureDetector(
                      onTap: () => _signatureController.clear(),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Text('Clear',
                            style: GoogleFonts.dmSans(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: _C.red)),
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

  // ─────────────────────────────────────────────
  // INSTRUCTION BANNER
  // ─────────────────────────────────────────────
  Widget _buildInstructionBanner() {
    const instructions = [
      // 'Hide test objects and take pictures of where you hide them, then have the team search.',
      // 'The goal is to find common areas of failure so we can focus on those areas for a TSA Audit.',
      // 'Do NOT tell agents how many objects were hidden.',
      // 'Only tell them where the objects are AFTER the team says they have completed the search fully.',
      // 'Conduct Audits Proactively and Submit them as you do them. Do NOT wait until the End of Shift.',
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
          Row(children: [
            Icon(Icons.info_rounded, color: _C.primary, size: 20.sp),
            SizedBox(width: 8.w),
            Text('Instructions',
                style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: _C.primary)),
          ]),
          SizedBox(height: 10.h),
          ...instructions.asMap().entries.map((e) => Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${e.key + 1}. ',
                    style: GoogleFonts.dmSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: _C.primary)),
                Expanded(
                  child: Text(e.value,
                      style: GoogleFonts.dmSans(
                          fontSize: 12.sp,
                          color: _C.dark,
                          height: 1.5)),
                ),
              ],
            ),
          )),
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
      children: [
        _legendDot(_C.primary, '🔵 Tap to select'),
        _legendDot(_C.green, 'Pass'),
        _legendDot(_C.red, 'Fail'),
        _legendDot(_C.seatColor, 'Not selected'),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10.w,
          height: 10.h,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4.w),
        Text(label,
            style: GoogleFonts.dmSans(fontSize: 10.sp, color: _C.grey)),
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
                      .map((s) => _buildSection(s)),
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
              leftSvg: a.leftSvg, leftId: a.leftId,
              rightSvg: a.rightSvg, rightId: a.rightId,
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
          if (section.skipRows != null &&
              section.skipRows!.contains(rowNum)) {
            return _buildSeatRow(
                rowNum: rowNum,
                leftCols: ['', ''],
                rightCols: section.rightCols);
          }
          return _buildSeatRow(
              rowNum: rowNum,
              leftCols: section.leftCols,
              rightCols: section.rightCols);
        }),
        SizedBox(height: 16.h),
        if (section.amenitiesAfter != null)
          ...section.amenitiesAfter!.map((a) => _buildAmenityRow(
            leftSvg: a.leftSvg, leftId: a.leftId,
            rightSvg: a.rightSvg, rightId: a.rightId,
            centerOnly: a.centerOnly,
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
    String? leftSvg, String? leftId,
    String? rightSvg, String? rightId,
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
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
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
                child: SvgPicture.asset(svgPath,
                    colorFilter: const ColorFilter.mode(
                        Colors.white, BlendMode.srcIn),
                    width: 22.sp,
                    height: 22.sp),
              ),
            ),
            if (isSelected)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 14.w,
                  height: 14.h,
                  decoration: const BoxDecoration(
                    color: _C.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: Colors.white, size: 9.sp),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildExitRow() => Padding(
    padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 20.w),
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

  Widget _buildClosetRow() => Padding(
    padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 40.w),
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

  Widget _buildSectionLabel(String t) => Padding(
    padding: EdgeInsets.symmetric(vertical: 10.h),
    child: Center(
      child: Text(t,
          style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: _C.dark)),
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
        prefixIcon:
        Icon(Icons.search_rounded, size: 18.sp, color: _C.grey),
        filled: true,
        fillColor: _C.inputBg,
        contentPadding:
        EdgeInsets.symmetric(vertical: 13.h, horizontal: 16.w),
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
            Row(children: [
              Icon(Icons.location_searching_rounded,
                  color: _C.primary, size: 16.sp),
              SizedBox(width: 8.w),
              Text('${card.areaName} *',
                  style: GoogleFonts.dmSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: _C.dark)),
            ]),
            SizedBox(height: 12.h),

            // Pass / Fail
            Row(children: [
              Expanded(
                child: _buildStatusButton(
                  label: 'Pass',
                  icon: Icons.check,
                  isSelected: status == 'pass',
                  color: _C.green,
                  onTap: () =>
                      _ctrl.setAreaStatus(card.areaName, 'pass'),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildStatusButton(
                  label: 'Fail',
                  icon: Icons.close,
                  isSelected: status == 'fail',
                  color: _C.red,
                  onTap: () =>
                      _ctrl.setAreaStatus(card.areaName, 'fail'),
                ),
              ),
            ]),

            // Upload — shown after Pass/Fail selected
            if (status.isNotEmpty) ...[
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () async {
                  final files = await _pickMulti();
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
                      Icon(Icons.cloud_upload_outlined,
                          size: 18.sp, color: _C.grey),
                      SizedBox(width: 8.w),
                      Text('Upload an Image',
                          style: GoogleFonts.dmSans(
                              fontSize: 13.sp, color: _C.grey)),
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
                            border: Border.all(
                                color: _C.border, width: 1),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.file(card.images[i],
                                fit: BoxFit.cover),
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 10,
                          child: GestureDetector(
                            onTap: () => _ctrl.removeAreaImage(
                                card.areaName, i),
                            child: Container(
                              padding: EdgeInsets.all(2.r),
                              decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle),
                              child: Icon(Icons.close,
                                  color: Colors.white,
                                  size: 12.sp),
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
  // SEAT SHEET
  // ─────────────────────────────────────────────
  void _showSeatSheet(String id) {
    String status = _ctrl.auditedSeats[id] ?? '';
    final RxList<File> imgs = <File>[].obs;
    final picker = ImagePicker();

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, ss) => Material(
          color: Colors.transparent,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.55,
            decoration: BoxDecoration(
              color: _C.white,
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: _C.border,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                    EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Seat: $id',
                            style: GoogleFonts.dmSans(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                                color: _C.primary)),
                        SizedBox(height: 20.h),
                        _buildSheetLabel('Status', required: true),
                        Row(children: [
                          Expanded(
                            child: _buildStatusButton(
                              label: 'Pass',
                              icon: Icons.check,
                              isSelected: status == 'pass',
                              color: _C.green,
                              onTap: () =>
                                  ss(() => status = 'pass'),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: _buildStatusButton(
                              label: 'Fail',
                              icon: Icons.close,
                              isSelected: status == 'fail',
                              color: _C.red,
                              onTap: () =>
                                  ss(() => status = 'fail'),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: _buildStatusButton(
                              label: 'N/A',
                              icon: null,
                              isSelected: status == 'na',
                              color: _C.primary,
                              onTap: () => ss(() => status = 'na'),
                            ),
                          ),
                        ]),
                        SizedBox(height: 16.h),
                        _buildSheetLabel(
                            'Upload image (max 100MB)'),
                        GestureDetector(
                          onTap: () async {
                            final picked =
                            await picker.pickMultiImage();
                            if (picked.isNotEmpty) {
                              imgs.addAll(picked
                                  .map((x) => File(x.path)));
                            }
                          },
                          child: Container(
                            height: 50.h,
                            decoration: BoxDecoration(
                              color: _C.white,
                              borderRadius:
                              BorderRadius.circular(25.r),
                              border: Border.all(
                                  color: _C.border, width: 1.5),
                            ),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cloud_upload_outlined,
                                    size: 20.sp, color: _C.grey),
                                SizedBox(width: 8.w),
                                Text('Upload an image',
                                    style: GoogleFonts.dmSans(
                                        fontSize: 14.sp,
                                        color: _C.grey)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Obx(() => imgs.isEmpty
                            ? const SizedBox.shrink()
                            : SizedBox(
                          height: 76.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: imgs.length,
                            itemBuilder: (_, i) => Stack(
                              children: [
                                Container(
                                  width: 68.w,
                                  height: 68.h,
                                  margin: EdgeInsets.only(
                                      right: 8.w),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(
                                        8.r),
                                    border: Border.all(
                                        color: _C.border),
                                  ),
                                  child: ClipRRect(
                                    borderRadius:
                                    BorderRadius.circular(
                                        8.r),
                                    child: Image.file(imgs[i],
                                        fit: BoxFit.cover),
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 10,
                                  child: GestureDetector(
                                    onTap: () =>
                                        imgs.removeAt(i),
                                    child: Container(
                                      padding:
                                      EdgeInsets.all(2.r),
                                      decoration:
                                      const BoxDecoration(
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
                        )),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(
                      20.w, 12.h, 20.w, 24.h),
                  decoration: BoxDecoration(
                    color: _C.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _C.primary,
                          side: BorderSide(
                              color: _C.primary, width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(25.r)),
                          padding: EdgeInsets.symmetric(
                              vertical: 14.h),
                        ),
                        child: Text('Cancel',
                            style: GoogleFonts.dmSans(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (status.isNotEmpty) {
                            _ctrl.markSeat(id, status);
                          }
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _C.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(25.r)),
                          padding: EdgeInsets.symmetric(
                              vertical: 14.h),
                          elevation: 0,
                        ),
                        child: Text('Apply',
                            style: GoogleFonts.dmSans(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ]),
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

  // ─────────────────────────────────────────────
  // SHARED HELPERS
  // ─────────────────────────────────────────────
  Widget _buildSheetLabel(String text, {bool required = false}) =>
      Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: RichText(
          text: TextSpan(
            text: text,
            style: GoogleFonts.dmSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: _C.primary),
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

  Widget _buildStatusButton({
    required String label,
    required IconData? icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 44.h,
          decoration: BoxDecoration(
            color: isSelected ? color : _C.white,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(
                color: isSelected ? color : _C.border, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    size: 18.sp,
                    color: isSelected ? Colors.white : _C.grey),
                SizedBox(width: 5.w),
              ],
              Text(label,
                  style: GoogleFonts.dmSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : _C.grey)),
            ],
          ),
        ),
      );

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
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
          hintStyle:
          GoogleFonts.dmSans(fontSize: 15.sp, color: _C.grey),
          filled: true,
          fillColor: _C.white,
          contentPadding:
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
              suffixIcon ?? Icons.keyboard_arrow_down_rounded,
              color: _C.grey,
              size: 20.sp,
            ),
            style: _fieldStyle(),
            items: items
                .map((i) =>
                DropdownMenuItem(value: i, child: Text(i)))
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
      hintStyle:
      GoogleFonts.dmSans(fontSize: 14.sp, color: _C.grey),
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
    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
    child: GestureDetector(
      onTap: () {
        Get.snackbar(
          'Success',
          'Security search report submitted!',
          backgroundColor: _C.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        Get.off(() => const CabinSecurityScreen());
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
          Text('How to use',
              style: GoogleFonts.dmSans(
                  fontSize: 16.sp, fontWeight: FontWeight.w600)),
        ]),
        content: Text(
          '1. Fill in date, supervisor, and gate.\n'
              '2. Select the aircraft and tap seats to mark Pass/Fail.\n'
              '3. Search and add areas from the checklist below the map.\n'
              '4. Mark each area Pass or Fail and upload a photo.\n'
              '5. Add notes and sign in the final step.',
          style: GoogleFonts.dmSans(
              fontSize: 13.sp, color: _C.grey, height: 1.6),
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
          Rect.fromLTWH(0, 0, w, h * 0.58), const Radius.circular(5)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(-1, h * 0.55, w + 2, h * 0.38),
          const Radius.circular(4)),
      paint,
    );
    final armPaint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(-3, h * 0.25, 4, h * 0.45),
          const Radius.circular(2)),
      armPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(w - 1, h * 0.25, 4, h * 0.45),
          const Radius.circular(2)),
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