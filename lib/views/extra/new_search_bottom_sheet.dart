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
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF9E9E9E);
  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color labelColor = Color(0xFF3D5AFE);
  static const Color checkboxActive = Color(0xFF3D5AFE);
}

// =====================
// CONTROLLER
// =====================
class NewSearchController extends GetxController {
  final nameController = TextEditingController();
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();

  final RxBool delayChecked = true.obs;
  final RxString delayLeft = 'Y'.obs;
  final RxString delayRight = '11'.obs;
  final RxString delayType = 'Primary'.obs;
  final RxString overTimeHour = '2 Hou...'.obs;
  final RxString overTimeMin = '30 Mi...'.obs;

  final List<String> delayLeftOptions = ['Y', 'N'];
  final List<String> delayRightOptions =
  List.generate(24, (i) => '${i + 1}');
  final List<String> delayTypeOptions = ['Primary', 'Secondary'];
  final List<String> overTimeHourOptions =
  List.generate(12, (i) => '${i + 1} Hou...');
  final List<String> overTimeMinOptions = [
    '00 Mi...',
    '15 Mi...',
    '30 Mi...',
    '45 Mi...',
  ];

  void apply() {
    Get.back(result: {
      'name': nameController.text,
      'fromDate': fromDateController.text,
      'toDate': toDateController.text,
      'delay': delayChecked.value,
      'delayLeft': delayLeft.value,
      'delayRight': delayRight.value,
      'delayType': delayType.value,
      'overTimeHour': overTimeHour.value,
      'overTimeMin': overTimeMin.value,
    });
  }

  @override
  void onClose() {
    nameController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
    super.onClose();
  }
}

// =====================
// BOTTOM SHEET
// =====================
class NewSearchBottomSheet extends StatefulWidget {
  const NewSearchBottomSheet({super.key});

  static Future<dynamic> show() {
    return Get.bottomSheet(
      const NewSearchBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<NewSearchBottomSheet> createState() => _NewSearchBottomSheetState();
}

class _NewSearchBottomSheetState extends State<NewSearchBottomSheet> {
  late final NewSearchController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(NewSearchController());
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Material wrap — fixes TextField & DropdownButton "No Material widget" error
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: _Colors.background,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 20.h),
              _buildSearchByName(),
              SizedBox(height: 16.h),
              _buildSearchByDate(),
              SizedBox(height: 16.h),
              _buildDelaySection(),
              SizedBox(height: 16.h),
              _buildOverTimeSection(),
              SizedBox(height: 24.h),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      children: [
        SizedBox(height: 20,),
        Icon(Icons.manage_search, color: _Colors.primary, size: 26.sp),
        SizedBox(width: 10.w),
        Text(
          'New Search',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: _Colors.textDark,
          ),
        ),
      ],
    );
  }

  // ── Search by Name ───────────────────────────────────────
  Widget _buildSearchByName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Search by Name'),
        SizedBox(height: 6.h),
        _buildInputField(
          ctrl: controller.nameController,
          hintText: 'Enter Name',
          prefixIcon: Icons.search,
        ),
      ],
    );
  }

  // ── Search by Date ───────────────────────────────────────
  Widget _buildSearchByDate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Search by Date'),
        SizedBox(height: 8.h),
        _buildSubLabel('From'),
        SizedBox(height: 4.h),
        _buildInputField(
          ctrl: controller.fromDateController,
          hintText: 'mm/dd/yyyy',
          prefixIcon: Icons.calendar_month_outlined,
          onTap: () => _pickDate(controller.fromDateController),
        ),
        SizedBox(height: 10.h),
        _buildSubLabel('To'),
        SizedBox(height: 4.h),
        _buildInputField(
          ctrl: controller.toDateController,
          hintText: 'Search',
          prefixIcon: Icons.calendar_month_outlined,
          onTap: () => _pickDate(controller.toDateController),
        ),
      ],
    );
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme:
          const ColorScheme.light(primary: _Colors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ctrl.text =
      '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  // ── Delay Section ─────────────────────────────────────────
  Widget _buildDelaySection() {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Checkbox + label
        Row(
          children: [
            GestureDetector(
              onTap: () => controller.delayChecked.toggle(),
              child: Container(
                width: 20.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: controller.delayChecked.value
                      ? _Colors.checkboxActive
                      : Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(
                    color: controller.delayChecked.value
                        ? _Colors.checkboxActive
                        : _Colors.inputBorder,
                    width: 1.5,
                  ),
                ),
                child: controller.delayChecked.value
                    ? Icon(Icons.check,
                    color: Colors.white, size: 14.sp)
                    : null,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'Delay',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: _Colors.textDark,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),

        // Y/N + number dropdowns
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                value: controller.delayLeft.value,
                items: controller.delayLeftOptions,
                onChanged: (v) => controller.delayLeft.value = v!,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _buildDropdown(
                value: controller.delayRight.value,
                items: controller.delayRightOptions,
                onChanged: (v) => controller.delayRight.value = v!,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),

        // Primary / Secondary toggle
        Row(
          children: controller.delayTypeOptions.map((type) {
            final isSelected = controller.delayType.value == type;
            return GestureDetector(
              onTap: () => controller.delayType.value = type,
              child: Container(
                margin: EdgeInsets.only(right: 10.w),
                padding: EdgeInsets.symmetric(
                    horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: isSelected
                        ? _Colors.primary
                        : _Colors.inputBorder,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  type,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? _Colors.primary
                        : _Colors.textGrey,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ));
  }

  // ── Over Time Section ─────────────────────────────────────
  Widget _buildOverTimeSection() {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Over Time'),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                value: controller.overTimeHour.value,
                items: controller.overTimeHourOptions,
                onChanged: (v) =>
                controller.overTimeHour.value = v!,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _buildDropdown(
                value: controller.overTimeMin.value,
                items: controller.overTimeMinOptions,
                onChanged: (v) =>
                controller.overTimeMin.value = v!,
              ),
            ),
          ],
        ),
      ],
    ));
  }

  // ── Action Buttons ────────────────────────────────────────
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                    color: _Colors.inputBorder, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: _Colors.textDark,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: GestureDetector(
            onTap: controller.apply,
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: _Colors.primary,
                borderRadius: BorderRadius.circular(24.r),
              ),
              alignment: Alignment.center,
              child: Text(
                'Apply',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Reusable: Label ──────────────────────────────────────
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: _Colors.labelColor,
      ),
    );
  }

  // ── Reusable: Sub Label ──────────────────────────────────
  Widget _buildSubLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 12.sp,
        color: _Colors.textGrey,
      ),
    );
  }

  // ── Reusable: Input Field ────────────────────────────────
  Widget _buildInputField({
    required TextEditingController ctrl,
    required String hintText,
    required IconData prefixIcon,
    VoidCallback? onTap,
  }) {
    return Container(
      height: 46.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: _Colors.inputBorder),
      ),
      child: TextField(
        controller: ctrl,
        readOnly: onTap != null,
        onTap: onTap,
        style: GoogleFonts.poppins(
          fontSize: 13.sp,
          color: _Colors.textDark,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            fontSize: 13.sp,
            color: _Colors.textGrey,
          ),
          prefixIcon:
          Icon(prefixIcon, color: _Colors.textGrey, size: 18.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        ),
      ),
    );
  }

  // ── Reusable: Dropdown ───────────────────────────────────
  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      height: 44.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: _Colors.inputBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down,
              color: _Colors.textGrey, size: 20.sp),
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            color: _Colors.textDark,
          ),
          items: items
              .map((item) => DropdownMenuItem(
            value: item,
            child: Text(item),
          ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}