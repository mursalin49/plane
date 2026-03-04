import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../utils/app_colors.dart';
import '../utils/app_icons.dart';
import '../utils/app_text.dart';
import '../widgets/app_dropdown.dart';
import '../widgets/report_submit_button.dart';

class CabinAuditController extends GetxController {
  var auditResponses = <String, String>{}.obs;
  var pickedImages = <String, File?>{}.obs;
  var selectedGate = 'Please Select One'.obs;
  var selectedTypeOfClean = 'Please Select One'.obs;
  var selectedSupervisor = 'Please Select One'.obs;

  void setResponse(String category, String value) {
    auditResponses[category] = value;
  }

  Future<void> pickImage(String category) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      pickedImages[category] = File(image.path);
    }
  }
}

class CabinAuditScreen extends StatelessWidget {
  final controller = Get.put(CabinAuditController());

  static const double _cardRadius = 16;
  static const double _inputRadius = 12;
  static const double _spacing = 20;

  static const List<String> _gateOptions = ['Please Select One', 'Gate A1', 'Gate B2', 'Gate C1', 'Gate D2'];
  static const List<String> _typeOfCleanOptions = ['Please Select One', 'Full Clean', 'Quick Turn', 'Overnight'];
  static const List<String> _supervisorOptions = ['Please Select One', 'Shara Brown', 'John Smith', 'Maria Garcia', 'David Lee'];
  static const List<String> _inspectionCategories = ['First Class', 'Comfort', 'Front Galley', 'Back Galley', 'Front LAVs', 'MID LAVs'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: AppColors.mainAppColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: AppText(
          "Cabin Quality Audit",
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
            onPressed: () => _showInstructionsDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard(
                title: "Job context",
                children: [
                  _buildLabel("Date*"),
                  _buildReadOnlyDateField(),
                  _buildLabel("Supervisor/Lead*"),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Obx(() => AppDropdown(
                      hint: "Please Select One",
                      items: _supervisorOptions,
                      value: controller.selectedSupervisor.value,
                      onChanged: (v) => controller.selectedSupervisor.value = v ?? 'Please Select One',
                    )),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText("Gate *", fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.from_heading),
                      const SizedBox(height: 6),
                      Obx(() => AppDropdown(
                        hint: "Please Select One",
                        items: _gateOptions,
                        value: controller.selectedGate.value,
                        onChanged: (v) => controller.selectedGate.value = v ?? 'Please Select One',
                      )),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText("Type of Clean *", fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.from_heading),
                      const SizedBox(height: 6),
                      Obx(() => AppDropdown(
                        hint: "Please Select One",
                        items: _typeOfCleanOptions,
                        value: controller.selectedTypeOfClean.value,
                        onChanged: (v) => controller.selectedTypeOfClean.value = v ?? 'Please Select One',
                      )),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: _spacing),
            _buildSectionCard(
              title: "Inspection checklist",
              children: [
                _buildAuditRow("First Class"),
                _buildImageUpload("First Class"),
                _buildAuditRow("Comfort"),
                _buildImageUpload("Comfort"),
                _buildAuditRow("Front Galley"),
                _buildAuditRow("Back Galley"),
                _buildAuditRow("Front LAVs"),
                _buildAuditRow("MID LAVs"),
                _buildImageUpload("General"),
              ],
            ),
            const SizedBox(height: _spacing),
            _buildSectionCard(
              title: "Notes",
              children: [
                _buildNoteField("Other findings", "Enter other findings…"),
                _buildNoteField("Additional notes", "Enter any additional notes…"),
              ],
            ),
            const SizedBox(height: 28),
            Obx(() => _buildSubmitButton(enabled: _isFormComplete())),
            const SizedBox(height: 24),
          ],
        ),
        ),
      ),
    );
  }

  static String _formatCurrentDate() {
    final now = DateTime.now();
    return '${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}/${now.year}';
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: AppText(
        text,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.from_heading,
      ),
    );
  }

  Widget _buildReadOnlyDateField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(_inputRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        _formatCurrentDate(),
        style: TextStyle(color: AppColors.dark, fontSize: 16),
      ),
    );
  }

  bool _isFormComplete() {
    if (controller.selectedSupervisor.value == 'Please Select One') return false;
    if (controller.selectedGate.value == 'Please Select One') return false;
    if (controller.selectedTypeOfClean.value == 'Please Select One') return false;
    for (final category in _inspectionCategories) {
      final value = controller.auditResponses[category];
      if (value == null || (value != 'Yes' && value != 'No' && value != 'N/A')) return false;
    }
    return true;
  }

  void _showInstructionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: AppColors.mainAppColor, size: 26),
            const SizedBox(width: 10),
            const Text("Cabin Quality Audit"),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Complete each section: Job context (date, supervisor, gate, type of clean), then the inspection checklist with Yes / No / N/A for each area. Add photos where requested. Use Notes for any extra findings.",
                style: TextStyle(fontSize: 14, color: AppColors.dark, height: 1.5),
              ),
              const SizedBox(height: 12),
              Text(
                "Remember",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.grey),
              ),
              const SizedBox(height: 6),
              _dialogBullet("Select a response for every checklist item before submitting."),
              _dialogBullet("Hold the submit button to send the report."),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("Got it", style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.mainAppColor)),
          ),
        ],
      ),
    );
  }

  Widget _dialogBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: AppColors.mainAppColor, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: AppColors.dark, height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AppText(
              title,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.dark,
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildAuditRow(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            title,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.grey,
          ),
          const SizedBox(height: 8),
          Obx(() => Row(
                children: [
                  _auditChip(title, "Yes", AppIcons.correct, AppColors.green),
                  const SizedBox(width: 10),
                  _auditChip(title, "No", AppIcons.cancel, AppColors.red),
                  const SizedBox(width: 10),
                  _auditChip(title, "N/A", null, AppColors.grey),
                ],
              )),
        ],
      ),
    );
  }

  Widget _auditChip(String category, String value, String? svgIcon, Color color) {
    bool isSelected = controller.auditResponses[category] == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setResponse(category, value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.12) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(_inputRadius),
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (svgIcon != null)
                SvgPicture.asset(
                  svgIcon,
                  width: 18,
                  height: 18,
                  colorFilter: ColorFilter.mode(
                    isSelected ? color : AppColors.grey,
                    BlendMode.srcIn,
                  ),
                )
              else
                Icon(
                  Icons.highlight_off,
                  size: 18,
                  color: isSelected ? color : AppColors.grey,
                ),
              const SizedBox(width: 6),
              AppText(
                value,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : AppColors.from_heading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUpload(String category) {
    return Obx(() {
      final hasImage = controller.pickedImages[category] != null;
      final content = Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(_inputRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: hasImage
            ? ClipRRect(
                borderRadius: BorderRadius.circular(_inputRadius),
                child: Image.file(
                  controller.pickedImages[category]!,
                  fit: BoxFit.cover,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 22, color: AppColors.from_heading),
                  const SizedBox(width: 8),
                  Text(
                    "Upload image",
                    style: TextStyle(fontSize: 14, color: AppColors.from_heading),
                  ),
                ],
              ),
      );
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => controller.pickImage(category),
            borderRadius: BorderRadius.circular(_inputRadius),
            child: content,
          ),
        ),
      );
    });
  }

  Widget _buildTextField(String label, String hint, IconData? icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            "$label *",
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.from_heading,
          ),
          const SizedBox(height: 6),
          TextField(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.from_heading.withValues(alpha: 0.8)),
              suffixIcon: icon != null ? Icon(icon, size: 20, color: AppColors.from_heading) : null,
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_inputRadius),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_inputRadius),
                borderSide: BorderSide(color: AppColors.border),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteField(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            label,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.grey,
          ),
          const SizedBox(height: 6),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.from_heading.withValues(alpha: 0.8)),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_inputRadius),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_inputRadius),
                borderSide: BorderSide(color: AppColors.border),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton({required bool enabled}) {
    return ReportSubmitButton(
      onConfirm: () {
        Get.snackbar("Success", "Audit Report Sent Successfully");
        Get.back();
      },
      borderRadius: _inputRadius,
      enabled: enabled,
    );
  }
}
