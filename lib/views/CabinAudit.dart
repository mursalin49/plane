import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'home/cabin_secuirity.dart';
import '../utils/app_colors.dart';
import '../utils/app_icons.dart';
import '../utils/app_images.dart';
import '../utils/app_text.dart';
class CabinAuditController extends GetxController {

  var auditResponses = <String, String>{}.obs;
  var pickedImages = <String, File?>{}.obs;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back, color: AppColors.mainAppColor), onPressed: () => Get.back()),
        title: AppText("Cabin Quality Audit", color: AppColors.mainAppColor, fontWeight: FontWeight.bold),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [IconButton(icon: Icon(Icons.info_outline, color: AppColors.mainAppColor), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField("Date and Time", "dd/mm/yyyy", Icons.calendar_today),
            _buildTextField("Supervisor/Lead", "Enter supervisor or lead name", null),
            _buildDropdown("Gate", "Please Select One",),
            _buildDropdown("Type of Clean", "Please Select One"),
            SizedBox(height: 20),


            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.mainAppColor, width: 1),
              ),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => Get.to(() => CabinAuditScreenS()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.mainAppColor,
                      side: BorderSide(color: AppColors.mainAppColor),
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: AppText("Inspection Checklist", color: AppColors.from_heading,),
                  ),
                  SizedBox(height: 20),
                  _buildAuditSection("First Class"),
                  _buildImageUpload("First Class"),
                  _buildAuditSection("Comfort"),
                  _buildImageUpload("Comfort"),
                  _buildAuditSection("Front Galley"),
                  _buildAuditSection("Back Galley"),
                  _buildAuditSection("Front LAVs"),
                  _buildAuditSection("MID LAVs"),

                  _buildNoteField("Other Findings"),
                  _buildNoteField("Additional Notes"),

                  SizedBox(height: 10),
                  _buildImageUpload("General"),
                  SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: () {
                      Get.snackbar("Success", "Audit Report Sent Successfully");
                      Get.to(() => CabinAuditScreenS());
                    },
                    icon: Icon(Icons.send),
                    label: AppText("SEND AUDIT REPORT", color: Colors.white,),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainAppColor,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAuditSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: AppText(title, fontWeight: FontWeight.bold, color: Colors.grey[700]),
        ),
        Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _auditButton(title, "Yes", AppIcons.correct, AppColors.green),
            _auditButton(title, "No", AppIcons.cancel, AppColors.red),
            _auditButton(title, "N/A", null, Colors.grey),
          ],
        )),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _auditButton(String category, String value, String? svgIcon, Color color) {
    bool isSelected = controller.auditResponses[category] == value;
    return GestureDetector(
      onTap: () => controller.setResponse(category, value),
      child: Container(
        width: Get.width * 0.25,
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            svgIcon != null
                ? SvgPicture.asset(svgIcon, width: 18, height: 18, colorFilter: ColorFilter.mode(color, BlendMode.srcIn))
                : Icon(Icons.highlight_off, size: 18, color: color),
            SizedBox(width: 4),
            AppText(value, color: isSelected ? color : Colors.grey),
          ],
        ),
      ),
    );
  }


  Widget _buildImageUpload(String category) {
    return Obx(() => Column(
      children: [
        OutlinedButton.icon(
          onPressed: () => controller.pickImage(category),
          icon: Icon(Icons.cloud_upload_outlined),
          label: AppText("Upload an image", color: AppColors.from_heading,),
          style: OutlinedButton.styleFrom(
            minimumSize: Size(double.infinity, 45),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
        if (controller.pickedImages[category] != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(controller.pickedImages[category]!, height: 100),
            ),
          ),
        SizedBox(height: 15),
      ],
    ));
  }


  Widget _buildTextField(String label, String hint, IconData? icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label + " *", fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.from_heading),
        SizedBox(height: 5),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: icon != null ? Icon(icon) : null,
            filled: true, fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
            contentPadding: EdgeInsets.symmetric(horizontal: 20),
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }

  Widget _buildDropdown(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label + " *", fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.from_heading),
        SizedBox(height: 5),
        DropdownButtonFormField(
          decoration: InputDecoration(
            filled: true, fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
            contentPadding: EdgeInsets.symmetric(horizontal: 20),
          ),
          hint: Text(
            hint,
            style: const TextStyle(
              color: AppColors.from_heading,
            ),
          ),
          items: [],
          onChanged: (val) {},
        ),
        SizedBox(height: 15),
      ],
    );
  }

  Widget _buildNoteField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(label, fontWeight: FontWeight.bold, color: Colors.grey[700]),
          SizedBox(height: 5),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Enter any additional findings or notes...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
        ],
      ),
    );
  }
}