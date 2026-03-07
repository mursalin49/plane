import 'package:avislap/utils/app_colors.dart';
import 'package:avislap/utils/app_icons.dart';
import 'package:avislap/utils/app_text.dart';
import 'package:avislap/widgets/app_dropdown.dart';
import 'package:avislap/widgets/report_submit_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class LAVSafetyScreen extends StatefulWidget {
  @override
  State<LAVSafetyScreen> createState() => _LAVSafetyScreenState();
}

class _LAVSafetyScreenState extends State<LAVSafetyScreen> {
  final Map<String, String?> _selectedValues = {};
  bool _isChecklistExpanded = false;

  static const double _cardRadius = 16;
  static const double _inputRadius = 12;
  static const double _spacing = 20;

  String _selectedGate = 'Please Select One';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.mainAppColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: AppText(
          "LAV Safety Observation",
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
            onPressed: () => _showInstructions(context),
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
                children: [
                  _buildRequiredLabel("Date and Time"),
                  _buildReadOnlyDateField(),
                  _buildRequiredLabel("Supervisor/Lead"),
                  _buildTextField("Enter supervisor or lead name"),
                  _buildRequiredLabel("Driver"),
                  _buildTextField("Enter Driver's Name"),
                  _buildRequiredLabel("Ship"),
                  _buildTextField("Enter Ship Number"),
                  _buildRequiredLabel("Gate"),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AppDropdown(
                      hint: "Please Select One",
                      items: const ['Please Select One', 'Gate A1', 'Gate B2', 'Gate C1', 'Gate D2'],
                      value: _selectedGate
                    ),
                  )
                ]
              ),
              const SizedBox(height: _spacing),
              _buildSectionCard(
                title: "",
                children: [
                  _buildChecklistHeader(),
                  if (_isChecklistExpanded) ...[
                    const SizedBox(height: 16),
                    _buildAuditRow("Used Chocks", "chocks", showImageUpload: true),
                    _buildAuditRow("Safety Stop", "safety_stop",
                        subtitle: "Checking if breaks are functional before approaching to aircraft",
                        showImageUpload: true),
                    _buildAuditRow("Used Guide Cone", "guide_cone",
                        subtitle: "Placing guide code near panel before reversing LAV truck near aircraft"),
                    _buildAuditRow("Face Mask", "mask",
                        subtitle: "Was Face Mask used while servicing aircraft?"),
                    _buildAuditRow("Gloves", "gloves",
                        subtitle: "Was agent using gloves to service?"),
                    _buildAuditRow("Shoes", "shoes",
                        subtitle: "Was agent wearing proper shoes and clothing?"),
                    _buildAuditRow("Dump", "dump",
                        subtitle: "Was the aircraft Dumped?"),
                    _buildAuditRow("Flush", "flush",
                        subtitle: "Was the aircraft Flushed with required amount of blue juice?"),
                    _buildAuditRow("Fill", "fill",
                        subtitle: "Was the Aircraft filled with the required amount of Blue Juice?"),
                    _buildAuditRow("360 Walk Around", "walkaround",
                        subtitle: "LAV Driver Walks around LAV Truck to make sure the truck is clear to move..."),
                    _buildAuditRow("Chock Removal Process", "chock_removal",
                        subtitle: "LAV Driver Takes out forward check and drives up 10 feet before coming back..."),
                  ],
                ],
              ),
              const SizedBox(height: _spacing),
              _buildSectionCard(
                title: "",
                children: [
                   _buildNoteField("Other Findings", "Enter any additional findings or notes..."),
                   _buildNoteField("Additional Notes", "Enter any additional findings or notes..."),
                   const SizedBox(height: 4),
                   AppText(
                     "Pictures",
                     fontSize: 14,
                     fontWeight: FontWeight.w600,
                     color: AppColors.mainAppColor,
                   ),
                   const SizedBox(height: 8),
                   _buildUploadBox(),
                ],
              ),
              const SizedBox(height: 28),
              ReportSubmitButton(
                onConfirm: () {
                  Get.snackbar("Success", "LAV Safety Report Sent Successfully", 
                      snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.black87, colorText: Colors.white);
                  Get.back();
                },
                borderRadius: _inputRadius,
                enabled: false, // You can add validation logic here later
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Helper Methods ---

  Widget _buildChecklistHeader() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isChecklistExpanded = !_isChecklistExpanded;
        });
      },
      child: Container(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText("Inspection Checklist", fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.mainAppColor),
            Icon(_isChecklistExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: AppColors.mainAppColor, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditRow(String title, String key, {String? subtitle, bool showImageUpload = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRequiredLabel(title),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: AppText(subtitle, fontSize: 13, color: AppColors.grey),
            ),
          Row(
            children: [
              _auditChip(key, "Pass", AppIcons.correct, AppColors.green),
              const SizedBox(width: 10),
              _auditChip(key, "Fail", AppIcons.cancel, AppColors.red),
            ],
          ),
          if (showImageUpload) ...[
            const SizedBox(height: 10),
            _buildUploadBox(),
          ],
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _auditChip(String key, String value, String svgIcon, Color color) {
    bool isSelected = _selectedValues[key] == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedValues[key] = value),
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
              SvgPicture.asset(
                svgIcon,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  isSelected ? color : AppColors.grey,
                  BlendMode.srcIn,
                ),
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

  Widget _buildRequiredLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(text, fontWeight: FontWeight.w600, color: AppColors.mainAppColor, fontSize: 14),
          const Text(" *", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.red, fontSize: 16)),
        ],
      ),
    );
  }

  static String _formatCurrentDate() {
    final now = DateTime.now();
    return '${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}/${now.year}';
  }

  Widget _buildReadOnlyDateField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
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

  Widget _buildSectionCard({String? title, required List<Widget> children}) {
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
          if (title != null && title.isNotEmpty)
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

  Widget _buildTextField(String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
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
            color: AppColors.mainAppColor,
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

  Widget _buildUploadBox() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(_inputRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_upload_outlined, color: AppColors.from_heading, size: 22),
          const SizedBox(width: 8),
          Text("Upload image", style: TextStyle(color: AppColors.from_heading, fontSize: 14)),
        ],
      ),
    );
  }

  void _showInstructions(BuildContext context) {

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.info_outline_rounded,
                color: AppColors.mainAppColor, size: 26),
            SizedBox(width: 10),
            Text(
              "Instructions",
              style: TextStyle(
                color: AppColors.mainAppColor,
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min, // ✅ dialog size fit content
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please submit this with as much detail as possible. 1 quality audit per shift.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.dark,
                height: 1.5,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Conduct Audits Proactive and Submit them as you do them; Do not wait until the end of the shift report.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.dark,
                height: 1.5,
              ),
            ),
            SizedBox(height: 10),
            // ✅ Missing blue bold text
            Text(
              'Take picture of both passes and Fails.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.mainAppColor,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "OK",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.mainAppColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}