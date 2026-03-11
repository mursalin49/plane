import 'dart:io';
import 'dart:typed_data';

import 'package:avislap/controllers/FlightAuditController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';

import '../../data/seat_map_config.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_images.dart';
import '../../utils/app_text.dart';
import '../../widgets/app_dropdown.dart';
import '../../widgets/report_submit_button.dart';

class CabinAuditScreenS extends StatefulWidget {
  const CabinAuditScreenS({super.key});

  @override
  State<CabinAuditScreenS> createState() => _CabinAuditScreenSState();
}

class _CabinAuditScreenSState extends State<CabinAuditScreenS> {
  final controller = Get.put(CabinController());

  static const double _cardRadius = 14;
  static const double _inputRadius = 12;
  static const double _pad = 16;
  static const double _spaceSection = 20;

  String? _frontGalleyStatus;
  String? _comfortStatus;
  String? _midLavStatus;

  Uint8List? _signaturePngBytes;

  static const List<String> _gateOptions = ['Please Select One', 'Gate A1', 'Gate B2', 'Gate C1', 'Gate D2'];
  static const List<String> _supervisorOptions = ['Please Select One', 'Shara Brown', 'John Smith', 'Maria Garcia', 'David Lee'];
  static const List<String> _aircraftOptions = ['Please Select One', 'Boeing 757-300 (75Y)', 'Boeing 737-800', 'Airbus A320'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: AppColors.mainAppColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: AppText(
          "Cabin Security Search Training",
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
            onPressed: _showInstructionsDialog,
          )
        ],
      ),
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(AppImages.cabin, fit: BoxFit.cover),
              const SizedBox(height: _spaceSection),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _pad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionCard(
                      title: "Job details",
                      children: [
                        _buildLabel("Date*"),
                        _buildReadOnlyDateField(),
                        _buildLabel("Supervisor/Lead*"),
                        Obx(() => AppDropdown(
                          hint: "Please Select One",
                          items: _supervisorOptions,
                          value: controller.selectedSupervisor.value,
                          onChanged: (v) => controller.selectedSupervisor.value = v ?? 'Please Select One',
                        )),
                        _buildLabel("Gate*"),
                        Obx(() => AppDropdown(
                          hint: "Please Select One",
                          items: _gateOptions,
                          value: controller.selectedGate.value,
                          onChanged: (v) => controller.selectedGate.value = v ?? 'Please Select One',
                        )),
                      ],
                    ),
                    const SizedBox(height: _spaceSection),
                    _buildSectionCard(
                      title: "Inspection checklist",
                      children: [
                        _buildLabel("Type of aircraft"),
                        Obx(() => AppDropdown(
                          hint: "Please Select One",
                          items: _aircraftOptions,
                          value: controller.selectedAircraft.value,
                          onChanged: (v) => controller.selectedAircraft.value = v ?? 'Please Select One',
                          suffixIcon: Icons.search,
                        )),
                      ],
                    ),
                    const SizedBox(height: _spaceSection),
                    _buildSectionCard(
                      title: "Seat map",
                      children: [
                        _buildSeatMapLegend(),
                        const SizedBox(height: 12),
                        _buildSeatMapSection(),
                      ],
                    ),
                    const SizedBox(height: _spaceSection),
                    _buildSectionCard(
                      title: "Areas",
                      children: [
                        _buildPassFailRow("Front Galley*", _frontGalleyStatus, (v) => setState(() => _frontGalleyStatus = v), areaKey: "Front Galley"),
                        const SizedBox(height: 16),
                        _buildPassFailRow("Comfort*", _comfortStatus, (v) => setState(() => _comfortStatus = v), areaKey: "Comfort"),
                        const SizedBox(height: 16),
                        _buildPassFailRow("MID LAV*", _midLavStatus, (v) => setState(() => _midLavStatus = v), areaKey: "MID LAV"),
                      ],
                    ),
                    const SizedBox(height: _spaceSection),
                    _buildSectionCard(
                      title: "Notes and signature",
                      children: [
                        _buildLabel("Additional notes"),
                        _buildLargeTextField("Enter overall findings..."),
                        _buildLabel("Signature*"),
                        _buildSignaturePlaceholder(),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Obx(() => _buildSubmitButton(enabled: _isFormComplete())),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isFormComplete() {
    if (controller.selectedSupervisor.value == 'Please Select One') return false;
    if (controller.selectedGate.value == 'Please Select One') return false;
    if (_frontGalleyStatus != 'Pass' && _frontGalleyStatus != 'Fail') return false;
    if (_comfortStatus != 'Pass' && _comfortStatus != 'Fail') return false;
    if (_midLavStatus != 'Pass' && _midLavStatus != 'Fail') return false;
    if (_signaturePngBytes == null) return false;
    return true;
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
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(String t) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        t,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: AppColors.dark,
        ),
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

  Widget _buildTextField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.from_heading),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _buildTextFieldWithIcon(String hint, IconData icon) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.from_heading),
        suffixIcon: Icon(icon, size: 20, color: AppColors.from_heading),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _buildLargeTextField(String h) {
    return TextField(
      maxLines: 3,
      decoration: InputDecoration(
        hintText: h,
        hintStyle: TextStyle(color: AppColors.from_heading),
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
        contentPadding: const EdgeInsets.all(14),
      ),
    );
  }

  Widget _buildUploadPlaceholder({String? imagePath, VoidCallback? onTap}) {
    final content = Container(
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(_inputRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: imagePath == null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_upload_outlined, size: 22, color: AppColors.from_heading),
                const SizedBox(width: 8),
                Text("Upload image", style: TextStyle(fontSize: 14, color: AppColors.from_heading)),
              ],
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(_inputRadius),
              child: Image.file(File(imagePath), fit: BoxFit.cover),
            ),
    );
    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_inputRadius),
          child: content,
        ),
      );
    }
    return content;
  }

  Widget _buildSignaturePlaceholder() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showSignatureSheet,
        borderRadius: BorderRadius.circular(_inputRadius),
        child: Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(_inputRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: _signaturePngBytes == null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.draw_rounded, size: 24, color: AppColors.from_heading),
                    const SizedBox(width: 10),
                    Text(
                      "Tap to draw your signature",
                      style: TextStyle(fontSize: 14, color: AppColors.from_heading),
                    ),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(_inputRadius),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.memory(_signaturePngBytes!, fit: BoxFit.contain),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: TextButton.icon(
                          onPressed: _showSignatureSheet,
                          icon: Icon(Icons.edit, size: 18, color: AppColors.mainAppColor),
                          label: Text("Change", style: TextStyle(fontSize: 12, color: AppColors.mainAppColor)),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  void _showSignatureSheet() {
    final signatureController = SignatureController(
      penStrokeWidth: 2.5,
      penColor: AppColors.dark,
      exportBackgroundColor: Colors.white,
      exportPenColor: AppColors.dark,
    );

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Draw your signature",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(_inputRadius),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(_inputRadius),
                    child: Signature(
                      controller: signatureController,
                      backgroundColor: const Color(0xFFF9FAFB),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => signatureController.clear(),
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      label: const Text("Clear"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.grey,
                        side: BorderSide(color: AppColors.border),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          if (signatureController.isNotEmpty) {
                            final bytes = await signatureController.toPngBytes(
                              width: 400,
                              height: 180,
                            );
                            if (bytes != null && mounted) {
                              setState(() => _signaturePngBytes = bytes);
                            }
                          }
                          Get.back();
                        },
                        icon: const Icon(Icons.check_rounded, size: 20),
                        label: const Text("Done"),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.mainAppColor,
                          foregroundColor: Colors.white,
                        ),
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
    ).then((_) {
      signatureController.dispose();
    });
  }

  void _showInstructionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: AppColors.mainAppColor, size: 26),
            const SizedBox(width: 10),
            const Text("Instructions"),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hide test objects and take pictures of where you hide them. Have the team search, then mark the ones they did not find.",
                style: TextStyle(fontSize: 14, color: AppColors.dark, height: 1.5),
              ),
              const SizedBox(height: 8),
              Text(
                "Goal: find common areas of failure to focus on for a TSA audit.",
                style: TextStyle(fontSize: 14, color: AppColors.grey, height: 1.5),
              ),
              const SizedBox(height: 16),
              Text(
                "Remember",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.from_heading,
                ),
              ),
              const SizedBox(height: 8),
              _dialogBullet("Do not tell agents how many objects were hidden."),
              _dialogBullet("Only reveal locations after the team says they have completed the search."),
              _dialogBullet("Conduct audits proactively and submit as you go."),
              _dialogBullet("Do not wait until end of shift to complete them."),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
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

  Widget _buildSeatMapLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem("Not done", AppColors.mainAppColor),
        const SizedBox(width: 16),
        _legendItem("Pass", AppColors.green),
        const SizedBox(width: 16),
        _legendItem("Fail", AppColors.red),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildSeatMapSection() {
    return Obx(() {
      final aircraft = controller.selectedAircraft.value;
      final config = (aircraft.isEmpty || aircraft == 'Please Select One')
          ? null
          : seatMapByAircraft[aircraft];

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.border.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(_inputRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: config == null
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    "Select type of aircraft above",
                    style: TextStyle(fontSize: 14, color: AppColors.grey),
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < config.sections.length; i++) ...[
                    if (i > 0) const SizedBox(height: 20),
                    _buildSeatMapHeader(config.sections[i].title),
                    for (final block in config.sections[i].blocks)
                      _generateSeats(
                        block.startRow,
                        block.endRow,
                        block.columns,
                        AppColors.mainAppColor,
                      ),
                  ],
                ],
              ),
      );
    });
  }

  Widget _buildSeatMapHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _generateSeats(int start, int end, List<String> cols, Color notDoneColor) {
    const double cellW = 36;
    const double cellH = 40;
    return Column(
      children: List.generate(end - start + 1, (index) {
        int row = start + index;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var s in cols.sublist(0, (cols.length / 2).floor())) _seatItem("$row$s", notDoneColor, cellW, cellH),
            SizedBox(
              width: 28,
              child: Center(
                child: Text("$row", style: TextStyle(fontSize: 10, color: AppColors.grey, fontWeight: FontWeight.w600)),
              ),
            ),
            for (var s in cols.sublist((cols.length / 2).floor())) _seatItem("$row$s", notDoneColor, cellW, cellH),
          ],
        );
      }),
    );
  }

  Widget _seatItem(String id, Color baseColor, double w, double h) {
    return Obx(() {
      bool isDone = controller.auditedSeats.containsKey(id);
      String status = isDone ? controller.auditedSeats[id]!['status'] as String : "";
      Color color = isDone ? (status == "Pass" ? AppColors.green : AppColors.red) : baseColor;
      return GestureDetector(
        onTap: () => _openAuditForm(id),
        child: Container(
          width: w,
          height: h,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(id, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
          ),
        ),
      );
    });
  }

  Widget _buildPassFailRow(String title, String? selectedValue, ValueChanged<String> onSelect, {String? areaKey}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(title),
        Row(
          children: [
            Expanded(
              child: _passFailChip("Pass", selectedValue == "Pass", AppColors.green, () => onSelect("Pass")),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _passFailChip("Fail", selectedValue == "Fail", AppColors.red, () => onSelect("Fail")),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (areaKey != null)
          Obx(() => _buildUploadPlaceholder(
                imagePath: controller.areaImages[areaKey],
                onTap: () => controller.pickImageForArea(areaKey),
              ))
        else
          _buildUploadPlaceholder(),
      ],
    );
  }

  Widget _passFailChip(String label, bool selected, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_inputRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.15) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(_inputRadius),
            border: Border.all(
              color: selected ? color : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                label == "Pass" ? Icons.check_circle : Icons.cancel,
                size: 20,
                color: selected ? color : AppColors.from_heading,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? color : AppColors.from_heading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAuditForm(String seatId) {
    String status = "Pass";
    String? imgPath;
    final noteCtrl = TextEditingController();

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: SingleChildScrollView(
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Audit Seat: $seatId",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.dark),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () async {
                              imgPath = await controller.takePhoto();
                              setState(() {});
                            },
                            child: _buildUploadPlaceholder(imagePath: imgPath),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _passFailChip(
                                  "Pass",
                                  status == "Pass",
                                  AppColors.green,
                                  () => setState(() => status = "Pass"),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _passFailChip(
                                  "Fail",
                                  status == "Fail",
                                  AppColors.red,
                                  () => setState(() => status = "Fail"),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: noteCtrl,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: "Findings for $seatId...",
                              hintStyle: TextStyle(color: AppColors.from_heading),
                              filled: true,
                              fillColor: const Color(0xFFF9FAFB),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(_inputRadius),
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                              contentPadding: const EdgeInsets.all(14),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () => controller.saveSeatAudit(seatId, status, imgPath, noteCtrl.text),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.mainAppColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_inputRadius)),
                              ),
                              child: const Text("Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildSubmitButton({required bool enabled}) {
    return ReportSubmitButton(
      onConfirm: () {
        // TODO: submit Cabin Security report
      },
      borderRadius: _inputRadius,
      enabled: enabled,
    );
  }
}
