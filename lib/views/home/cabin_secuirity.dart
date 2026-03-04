import 'package:avislap/controllers/FlightAuditController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

import '../../utils/app_colors.dart';
import '../../utils/app_icons.dart';
import '../../utils/app_images.dart';
import '../../utils/app_text.dart';
class CabinAuditScreenS extends StatelessWidget {
  final controller = Get.put(CabinController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.mainAppColor,
        title: AppText("Cabin Security Search Training", color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: const [Icon(Icons.more_vert, color: Colors.white), SizedBox(width: 10)],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            _buildInstructionBox(),

            Image.asset(AppImages.cabin, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _buildLabel("Date and Time*"),
                  _buildTextField("10/16/2026 18:35"),

                  _buildLabel("Supervisor/Lead*"),
                  _buildTextField("Shara Brown"),

                  _buildLabel("Gate*"),
                  _buildDropdown(["Please Select One", "Gate A1", "Gate B2"]),

                  const SizedBox(height: 20),
                  const Divider(),
                  AppText("Inspection Checklist", fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.heading),
                  const SizedBox(height: 10),

                  _buildLabel("Type Of Aircraft"),
                  _buildTextFieldWithIcon("Boeing 757-300 (75Y)", Icons.search),

                  const SizedBox(height: 20),



                  _buildSeatMapSection(),

                  const SizedBox(height: 20),


                  _buildPassFailSection("Front Galley*"),
                  const SizedBox(height: 20),

                  _buildPassFailSection("Comfort*"),
                  const SizedBox(height: 20),


                  _buildPassFailSection("MID LAV*"),

                  const SizedBox(height: 20),
                  _buildLabel("Additional Notes"),
                  _buildLargeTextField("Enter overall findings..."),

                  _buildLabel("Signature*"),
                  _buildSignaturePlaceholder(),

                  const SizedBox(height: 30),
                  _buildSubmitButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSeatMapSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade50),
      ),
      child: Column(
        children: [
          _buildSectionHeader("First Class"),
          _generateSeats(1, 6, ["A", "B", "C", "D"], Colors.red.shade900),

          const Divider(height: 40, thickness: 1, indent: 20, endIndent: 20),
          _buildSectionHeader("Delta Comfort / Main"),
          _generateSeats(14, 20, ["A", "B", "C", "D", "E", "F"], Colors.blue.shade700),
          _generateSeats(21, 40, ["A", "B", "C", "D", "E", "F"], Colors.blue.shade800),

          const Divider(height: 40, thickness: 1, indent: 20, endIndent: 20),
          _buildSectionHeader("Rear Cabin"),
          _generateSeats(41, 49, ["A", "B", "C", "D", "E", "F"], Colors.blue.shade900),
        ],
      ),
    );
  }

  Widget _generateSeats(int start, int end, List<String> cols, Color color) {
    return Column(
      children: List.generate(end - start + 1, (index) {
        int row = start + index;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var s in cols.sublist(0, (cols.length / 2).floor())) _seatItem("$row$s", color),
            SizedBox(width: 30, child: Center(child: AppText("$row", fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold))),
            for (var s in cols.sublist((cols.length / 2).floor())) _seatItem("$row$s", color),
          ],
        );
      }),
    );
  }

  Widget _seatItem(String id, Color baseColor) {
    return Obx(() {
      bool isDone = controller.auditedSeats.containsKey(id);
      String status = isDone ? controller.auditedSeats[id]!['status'] : "";
      return GestureDetector(
        onTap: () => _openAuditForm(id),
        child: Container(
          width: 30, height: 34, margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isDone ? (status == "Pass" ? Colors.green : Colors.red) : baseColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(child: AppText(id, color: Colors.white, fontSize: 8)),
        ),
      );
    });
  }


  Widget _buildPassFailSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(title),
        Row(
          children: [
            Expanded(child: OutlinedButton.icon(onPressed: (){}, icon: Icon(Icons.check, size: 16), label: AppText("Pass"), style: OutlinedButton.styleFrom(foregroundColor: Colors.black))),
            const SizedBox(width: 10),
            Expanded(child: OutlinedButton.icon(onPressed: (){}, icon: Icon(Icons.close, size: 16), label: AppText("Fail"), style: OutlinedButton.styleFrom(foregroundColor: Colors.black))),
          ],
        ),
        const SizedBox(height: 8),
        _buildUploadPlaceholder(),
      ],
    );
  }


  void _openAuditForm(String seatId) {
    String status = "Pass";
    String? imgPath;
    final noteCtrl = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText("Audit Seat: $seatId", fontSize: 18, fontWeight: FontWeight.bold),
              const Divider(),
              const SizedBox(height: 10),
              StatefulBuilder(builder: (context, setState) {
                return GestureDetector(
                  onTap: () async {
                    imgPath = await controller.takePhoto();
                    setState(() {});
                  },
                  child: _buildUploadPlaceholder(imagePath: imgPath),
                );
              }),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _statusBtn("Pass", Colors.green, () => status = "Pass")),
                  const SizedBox(width: 10),
                  Expanded(child: _statusBtn("Fail", Colors.red, () => status = "Fail")),
                ],
              ),
              const SizedBox(height: 15),
              TextField(controller: noteCtrl, decoration: InputDecoration(hintText: "Findings for $seatId...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => controller.saveSeatAudit(seatId, status, imgPath, noteCtrl.text),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.mainAppColor, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: AppText("SAVE DATA", color: Colors.white),
              )
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }


  Widget _buildLabel(String t) => Padding(padding: const EdgeInsets.only(top: 15, bottom: 8), child: AppText(t, fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87));

  Widget _buildTextField(String hint) => TextField(decoration: InputDecoration(hintText: hint, contentPadding: EdgeInsets.symmetric(horizontal: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))));

  Widget _buildTextFieldWithIcon(String hint, IconData icon) => TextField(decoration: InputDecoration(hintText: hint, suffixIcon: Icon(icon), contentPadding: EdgeInsets.symmetric(horizontal: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))));

  Widget _buildUploadPlaceholder({String? imagePath}) => Container(
    height: 60, width: double.infinity,
    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid), borderRadius: BorderRadius.circular(10), color: Colors.grey.shade50),
    child: imagePath == null
        ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.cloud_upload_outlined, color: Colors.grey), SizedBox(width: 8), AppText("Upload an image", color: Colors.grey)])
        : ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(File(imagePath), fit: BoxFit.cover)),
  );

  Widget _buildSectionHeader(String title) => Padding(padding: const EdgeInsets.only(bottom: 10), child: AppText(title.toUpperCase(), fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey));

  Widget _buildInstructionBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFF0F7FF), // Light blue background
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),

                decoration: const BoxDecoration(
                  color: AppColors.mainAppColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.info_outline, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 10),
              AppText(
                "Instructions",
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black
              ),
            ],
          ),
          const SizedBox(height: 12),

          AppText(
            "Hide Test objects and take pictures of where you hide them and then have the team search. Go back and mark the one they did not find.",
            fontSize: 13, color: AppColors.grey,
          ),
          const SizedBox(height: 10),
          AppText(
            "The goal is to find common areas of failure so we can focus on those areas for a TSA Audit.",
            fontSize: 13, color: AppColors.grey,
          ),
          const SizedBox(height: 10),
          AppText("• Do not tell agents how many objects were hidden",
              fontSize: 13, color: AppColors.grey),
          AppText("• Only tell them where the object are after the team says they have completed the search fully",
              fontSize: 13, color: AppColors.grey),

          const SizedBox(height: 12),

          _buildBulletPoint("Conduct Audits Proactive and Submit them as you do them;"),
          _buildBulletPoint("Do not wait until the End of the Shift to complete them."),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: AppColors.mainAppColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AppText(
              text,
              fontSize: 13,
              color: AppColors.mainAppColor,
              fontWeight: FontWeight.w500
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildBulletPoint(String text) {
  //   return Padding(
  //     padding: const EdgeInsets.only(top: 6, left: 8),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Padding(
  //           padding: EdgeInsets.only(top: 6),
  //           child: Icon(Icons.circle, size: 6, color: Color(0xFF2E6FD1)),
  //         ),
  //         const SizedBox(width: 8),
  //         Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF2E6FD1), fontWeight: FontWeight.w500))),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildDropdown(List<String> items) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
    child: DropdownButtonHideUnderline(child: Obx(() => DropdownButton<String>(
      value: controller.selectedGate.value, isExpanded: true, items: items.map((e) => DropdownMenuItem(value: e, child: AppText(e))).toList(), onChanged: (v) => controller.selectedGate.value = v!,
    ))),
  );

  Widget _buildLargeTextField(String h) => TextField(maxLines: 3, decoration: InputDecoration(hintText: h, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))));

  Widget _buildSignaturePlaceholder() => Container(height: 60, width: double.infinity, decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.edit, size: 16, color: Colors.grey), SizedBox(width: 8), AppText("Click to sign here", color: Colors.grey)]));

  Widget _statusBtn(String l, Color c, VoidCallback o) => ElevatedButton(onPressed: o, style: ElevatedButton.styleFrom(backgroundColor: c, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: AppText(l, color: Colors.white));

  Widget _buildSubmitButton() => ElevatedButton.icon(
    onPressed: () {},
    icon: const Icon(Icons.send, color: Colors.white, size: 18),
    label: AppText("SEND AUDIT REPORT", color: Colors.white, fontWeight: FontWeight.bold),
    style: ElevatedButton.styleFrom(backgroundColor: AppColors.mainAppColor, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
  );
}