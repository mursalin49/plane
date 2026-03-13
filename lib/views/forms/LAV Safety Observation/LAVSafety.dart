import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────
class _C {
  static const Color primary = Color(0xFF3D5AFE);
  static const Color bg      = Color(0xFFFFFFFF);
  static const Color dark    = Color(0xFF1A1A2E);
  static const Color grey    = Color(0xFF8891A4);
  static const Color border  = Color(0xFFE4E7EF);
  static const Color inputBg = Color(0xFFF9FAFB);
  static const Color green   = Color(0xFF22C55E);
  static const Color red     = Color(0xFFEF4444);
}

// ─────────────────────────────────────────────
// MODEL — checklist item
// ─────────────────────────────────────────────
class ChecklistItem {
  final String title;
  final String? subtitle;
  ChecklistItem({required this.title, this.subtitle});
}

// ─────────────────────────────────────────────
// CONTROLLER
// ─────────────────────────────────────────────
class LavSafetyController extends GetxController {
  final selectedShip = 'Boeing 757-300 (75Y)'.obs;
  final selectedGate = 'Gate a-2'.obs;

  final List<String> shipOptions = [
    'Boeing 757-300 (75Y)',
    'Boeing 737-800',
    'Airbus A320',
  ];
  final List<String> gateOptions = [
    'Gate a-2',
    'Gate a-3',
    'Gate b-1',
    'Gate b-2',
  ];

  // checklist items
  final List<ChecklistItem> checklistItems = [
    ChecklistItem(title: 'Used Chocks'),
    ChecklistItem(
      title: 'Safety Stop',
      subtitle:
      'Checking if breaks are functional before approaching to aircraft',
    ),
    ChecklistItem(
      title: 'Used Guide Cone',
      subtitle:
      'Placing guide code near panel before reversing LAV truck near aircraft',
    ),
    ChecklistItem(title: 'Proper PPE'),
    ChecklistItem(title: 'Vehicle Inspection'),
    ChecklistItem(title: 'Spill Prevention'),
  ];

  // status per item index: 'pass' | 'fail' | 'na' | ''
  late final List<RxString> statuses;
  // images per item
  late final List<RxList<File>> images;

  @override
  void onInit() {
    super.onInit();
    statuses =
        List.generate(checklistItems.length, (_) => ''.obs);
    images = List.generate(
        checklistItems.length, (_) => <File>[].obs);
  }
}

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────
class LavSafetyObservation extends StatefulWidget {
  const LavSafetyObservation({super.key});
  @override
  State<LavSafetyObservation> createState() =>
      _LavSafetyObservationScreenState();
}

class _LavSafetyObservationScreenState
    extends State<LavSafetyObservation> {
  final _ctrl             = Get.put(LavSafetyController());
  final _supervisorCtrl   = TextEditingController();
  final _driverCtrl       = TextEditingController();
  final _otherFindingsCtrl= TextEditingController();
  final _additionalCtrl   = TextEditingController();
  final _picker           = ImagePicker();

  int _step = 0;

  final RxList<File> _step2Images = <File>[].obs;

  static String _todayDate() {
    final n = DateTime.now();
    return '${n.month.toString().padLeft(2, '0')}/'
        '${n.day.toString().padLeft(2, '0')}/${n.year}';
  }

  Future<void> _pickImagesFor(int idx) async {
    final picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) {
      _ctrl.images[idx]
          .addAll(picked.map((x) => File(x.path)));
    }
  }

  Future<void> _pickStep2Images() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) {
      _step2Images.addAll(picked.map((x) => File(x.path)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _appBar(),
      body: _step == 0
          ? _buildStep0()
          : _step == 1
          ? _buildStep1()
          : _buildStep2(),
    );
  }

  // ── App Bar ──────────────────────────────────────────────
  AppBar _appBar() => AppBar(
    backgroundColor: _C.bg,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    leading: IconButton(
      icon: Icon(Icons.arrow_back_rounded,
          color: _C.primary, size: 22.sp),
      onPressed: () =>
      _step > 0 ? setState(() => _step--) : Get.back(),
    ),
    title: Text(
      'LAV Safety Observation',
      style: GoogleFonts.dmSans(
        fontSize: 17.sp,
        fontWeight: FontWeight.w600,
        color: _C.dark,
      ),
    ),
    centerTitle: true,
    actions: [
      IconButton(
        icon: Icon(Icons.info_outline_rounded,
            color: _C.dark, size: 22.sp),
        onPressed: _showInstructions,
      ),
    ],
  );

  // ─────────────────────────────────────────────
  // STEP 0 — Job Details
  // ─────────────────────────────────────────────
  Widget _buildStep0() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                20.w, 24.h, 20.w, 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and Time
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
                SizedBox(height: 20.h),

                // Supervisor/Lead
                _label('Supervisor/Lead *'),
                _pillTextField(
                  controller: _supervisorCtrl,
                  hint: 'John Doe',
                ),
                SizedBox(height: 20.h),

                // Driver
                _label('Driver *'),
                _pillTextField(
                  controller: _driverCtrl,
                  hint: 'Stony Korella',
                ),
                SizedBox(height: 20.h),

                // Ship
                _label('Ship *'),
                Obx(() => _pillDropdown(
                  value: _ctrl.selectedShip.value,
                  items: _ctrl.shipOptions,
                  onChanged: (v) =>
                  _ctrl.selectedShip.value = v!,
                )),
                SizedBox(height: 20.h),

                // Gate
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
  // STEP 1 — Inspection Checklist
  // ─────────────────────────────────────────────
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                20.w, 24.h, 20.w, 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inspection Checklist',
                  style: GoogleFonts.dmSans(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: _C.primary,
                  ),
                ),
                SizedBox(height: 24.h),
                ...List.generate(
                  _ctrl.checklistItems.length,
                      (i) => _checklistCard(i),
                ),
              ],
            ),
          ),
        ),
        _nextButton(() => setState(() => _step = 2)),
      ],
    );
  }

  Widget _checklistCard(int idx) {
    final item = _ctrl.checklistItems[idx];
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title (primary color + asterisk)
          RichText(
            text: TextSpan(
              text: item.title,
              style: GoogleFonts.dmSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: _C.primary,
              ),
              children: [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: _C.red),
                ),
              ],
            ),
          ),

          // Subtitle if present
          if (item.subtitle != null) ...[
            SizedBox(height: 4.h),
            Text(
              item.subtitle!,
              style: GoogleFonts.dmSans(
                fontSize: 12.sp,
                color: _C.grey,
                height: 1.4,
              ),
            ),
          ],
          SizedBox(height: 10.h),

          // Pass / Fail / N/A
          Obx(() {
            final status = _ctrl.statuses[idx].value;
            return Row(
              children: [
                Expanded(
                  child: _statusBtn(
                    label: 'Pass',
                    icon: Icons.check,
                    selected: status == 'pass',
                    activeColor: _C.green,
                    onTap: () =>
                    _ctrl.statuses[idx].value = 'pass',
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _statusBtn(
                    label: 'Fail',
                    icon: Icons.close,
                    selected: status == 'fail',
                    activeColor: _C.red,
                    onTap: () =>
                    _ctrl.statuses[idx].value = 'fail',
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _statusBtn(
                    label: 'N/A',
                    icon: null,
                    selected: status == 'na',
                    activeColor: _C.primary,
                    onTap: () =>
                    _ctrl.statuses[idx].value = 'na',
                  ),
                ),
              ],
            );
          }),
          SizedBox(height: 10.h),

          // Upload an image
          GestureDetector(
            onTap: () => _pickImagesFor(idx),
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: _C.bg,
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(color: _C.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined,
                      size: 18.sp, color: _C.grey),
                  SizedBox(width: 8.w),
                  Text('Upload an image',
                      style: GoogleFonts.dmSans(
                          fontSize: 14.sp,
                          color: _C.grey)),
                ],
              ),
            ),
          ),

          // Thumbnails
          Obx(() => _ctrl.images[idx].isEmpty
              ? const SizedBox.shrink()
              : Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: SizedBox(
              height: 72.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _ctrl.images[idx].length,
                itemBuilder: (_, j) => Stack(
                  children: [
                    Container(
                      width: 64.w,
                      height: 64.h,
                      margin: EdgeInsets.only(right: 8.w),
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(8.r),
                        border: Border.all(
                            color: _C.border),
                      ),
                      child: ClipRRect(
                        borderRadius:
                        BorderRadius.circular(8.r),
                        child: Image.file(
                            _ctrl.images[idx][j],
                            fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: 2, right: 10,
                      child: GestureDetector(
                        onTap: () => _ctrl.images[idx]
                            .removeAt(j),
                        child: Container(
                          padding: EdgeInsets.all(2.r),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
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
          )),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // STEP 2 — Other Findings + Notes + Pictures
  // ─────────────────────────────────────────────
  Widget _buildStep2() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                20.w, 24.h, 20.w, 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Other Findings
                _label('Other Findings'),
                _multilineField(
                  controller: _otherFindingsCtrl,
                  hint:
                  'Enter any additional findings or notes...',
                ),
                SizedBox(height: 20.h),

                // Additional Notes
                _label('Additional Notes'),
                _multilineField(
                  controller: _additionalCtrl,
                  hint:
                  'Enter any additional findings or notes...',
                ),
                SizedBox(height: 20.h),

                // Pictures
                _label('Pictures'),
                GestureDetector(
                  onTap: _pickStep2Images,
                  child: Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: _C.bg,
                      borderRadius:
                      BorderRadius.circular(30.r),
                      border: Border.all(color: _C.border),
                    ),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_outlined,
                            size: 18.sp, color: _C.grey),
                        SizedBox(width: 8.w),
                        Text('Upload an image',
                            style: GoogleFonts.dmSans(
                                fontSize: 14.sp,
                                color: _C.grey)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12.h),

                // Step2 thumbnails
                Obx(() => _step2Images.isEmpty
                    ? const SizedBox.shrink()
                    : Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: List.generate(
                    _step2Images.length,
                        (i) => Stack(
                      children: [
                        ClipRRect(
                          borderRadius:
                          BorderRadius.circular(8.r),
                          child: Image.file(
                            _step2Images[i],
                            width: 80.w,
                            height: 80.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4, right: 4,
                          child: GestureDetector(
                            onTap: () => _step2Images
                                .removeAt(i),
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
                                  size: 14.sp),
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
        _submitButton(),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // SHARED WIDGETS
  // ─────────────────────────────────────────────

  // Status button (Pass / Fail / N/A)
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
          color: selected ? activeColor : _C.bg,
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
                  size: 16.sp,
                  color: selected ? Colors.white : _C.grey),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : _C.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: Text(t,
        style: GoogleFonts.dmSans(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: _C.primary)),
  );

  TextStyle _fieldStyle() =>
      GoogleFonts.dmSans(fontSize: 15.sp, color: _C.dark);

  Widget _pillField({required Widget child}) => Container(
    padding: EdgeInsets.symmetric(
        horizontal: 16.w, vertical: 14.h),
    decoration: BoxDecoration(
      color: _C.bg,
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
          fillColor: _C.bg,
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
  }) =>
      Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: _C.bg,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(color: _C.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down_rounded,
                color: _C.grey, size: 20.sp),
            style: _fieldStyle(),
            items: items
                .map((i) => DropdownMenuItem(
                value: i, child: Text(i)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      );

  Widget _multilineField({
    required TextEditingController controller,
    required String hint,
  }) =>
      TextField(
        controller: controller,
        maxLines: 5,
        style: _fieldStyle(),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.dmSans(
              fontSize: 14.sp, color: _C.grey),
          filled: true,
          fillColor: _C.bg,
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

  Widget _nextButton(VoidCallback onTap) => Container(
    color: _C.bg,
    padding: EdgeInsets.fromLTRB(
        20.w, 12.h, 20.w, 28.h),
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

  Widget _submitButton() => Container(
    color: _C.bg,
    padding: EdgeInsets.fromLTRB(
        20.w, 12.h, 20.w, 28.h),
    child: GestureDetector(
      onTap: () {
        Get.snackbar(
          'Success',
          'LAV Safety Observation submitted!',
          backgroundColor: _C.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        Get.back();
      },
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
            borderRadius: BorderRadius.circular(16.r)),
        title: Row(children: [
          Icon(Icons.info_outline_rounded,
              color: _C.primary, size: 22.sp),
          SizedBox(width: 8.w),
          Text('Instructions',
              style: GoogleFonts.dmSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conduct the LAV Audit as you observe the Drivers, don\'t wait till the end of the shift to submit.',
              style: GoogleFonts.dmSans(
                  fontSize: 13.sp,
                  color: _C.dark,
                  height: 1.5),
            ),
            SizedBox(height: 10.h),
            Text(
              'Please submit this with as much detail as possible 2 Observations per Shift',
              style: GoogleFonts.dmSans(
                  fontSize: 13.sp,
                  color: _C.dark,
                  height: 1.5),
            ),
            SizedBox(height: 10.h),
            Text(
              'Take pictures of the Driver following the proper procedures.',
              style: GoogleFonts.dmSans(
                  fontSize: 13.sp,
                  color: _C.primary,
                  height: 1.5,
                  decoration: TextDecoration.underline),
            ),
          ],
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