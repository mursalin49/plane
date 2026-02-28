import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'home/cabin_secuirity.dart';

class CabinAuditController extends GetxController {
  // বাটনগুলোর স্টেট সংরক্ষণের জন্য ম্যাপ
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
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.blue), onPressed: () => Get.back()),
        title: Text("Cabin Quality Audit", style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [IconButton(icon: Icon(Icons.info_outline, color: Colors.blue), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField("Date and Time", "dd/mm/yyyy", Icons.calendar_today),
            _buildTextField("Supervisor/Lead", "Enter supervisor or lead name", null),
            _buildDropdown("Gate", "Please Select One"),
            _buildDropdown("Type of Clean", "Please Select One"),
            SizedBox(height: 20),

            // অডিট লিস্ট কন্টেইনার
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.shade900, width: 1),
              ),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => Get.to(() => CabinAuditScreenS()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue[900],
                      side: BorderSide(color: Colors.blue.shade900),
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text("Inspection Checklist"),
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
                    label: Text("SEND AUDIT REPORT"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
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

  // অডিট বাটন সেকশন (Yes, No, N/A)
  Widget _buildAuditSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
        ),
        Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _auditButton(title, "Yes", Icons.check_circle_outline, Colors.green),
            _auditButton(title, "No", Icons.cancel_outlined, Colors.red),
            _auditButton(title, "N/A", Icons.highlight_off, Colors.grey),
          ],
        )),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _auditButton(String category, String value, IconData icon, Color color) {
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
            Icon(icon, size: 18, color: color),
            SizedBox(width: 4),
            Text(value, style: TextStyle(color: isSelected ? color : Colors.grey)),
          ],
        ),
      ),
    );
  }

  // ইমেজ আপলোড বাটন
  Widget _buildImageUpload(String category) {
    return Obx(() => Column(
      children: [
        OutlinedButton.icon(
          onPressed: () => controller.pickImage(category),
          icon: Icon(Icons.cloud_upload_outlined),
          label: Text("Upload an image"),
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

  // ইনপুট ফিল্ডস (Text & Dropdown)
  Widget _buildTextField(String label, String hint, IconData? icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label + " *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue[900])),
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
        Text(label + " *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue[900])),
        SizedBox(height: 5),
        DropdownButtonFormField(
          decoration: InputDecoration(
            filled: true, fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
            contentPadding: EdgeInsets.symmetric(horizontal: 20),
          ),
          hint: Text(hint),
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
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
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