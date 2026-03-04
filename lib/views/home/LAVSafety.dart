import 'package:avislap/views/auth/comon_widets.dart'; // আপনার ফাইলের পাথ অনুযায়ী
import 'package:flutter/material.dart';

class LAVSafetyScreen extends StatefulWidget {
  @override
  State<LAVSafetyScreen> createState() => _LAVSafetyScreenState();
}

class _LAVSafetyScreenState extends State<LAVSafetyScreen> {
  // প্রতিটি আইটেমের স্টেট সেভ করার জন্য ম্যাপ
  final Map<String, String?> _selectedValues = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.blue),
        title: const Text(
            "LAV Safety Observation",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)
        ),
        actions: const [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 15),
        ],
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildInputLabel("Date and Time *"),
            buildFormTextField("dd/mm/yyyy", suffixIcon: Icons.calendar_today_outlined),
            const SizedBox(height: 20),

            buildInputLabel("Supervisor/Lead *"),
            buildFormTextField("Enter supervisor or lead name"),
            const SizedBox(height: 20),

            buildInputLabel("Driver *"),
            buildFormTextField("Enter Driver's Name"),
            const SizedBox(height: 20),

            buildInputLabel("Ship *"),
            buildFormTextField("Enter Ship Number"),
            const SizedBox(height: 20),

            buildInputLabel("Gate *"),
            _buildDropdownField("Please Select One"),
            const SizedBox(height: 30),

            // Checklist Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Inspection Checklist",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                Icon(Icons.keyboard_arrow_down, color: Colors.blue),
              ],
            ),
            const Divider(thickness: 1, color: Colors.blue),
            const SizedBox(height: 15),

            // Checklist Items
            _buildPassFailItem("Used Chocks *", "chocks"),
            _buildPassFailItem(
                "Safety Stop *",
                "safety_stop",
                subtitle: "Checking if breaks are functional before approaching to aircraft"
            ),
            _buildPassFailItem(
                "Used Guide Cone *",
                "guide_cone",
                subtitle: "Placing guide code near panel before reversing LAV truck near aircraft"
            ),
            _buildPassFailItem("Face Mask *", "mask", subtitle: "Was Face Mask used while servicing aircraft?"),

            const SizedBox(height: 20),
            buildInputLabel("Other Findings"),
            buildLargeTextField("Enter any additional findings or notes..."),

            const SizedBox(height: 20),
            buildInputLabel("Additional Notes"),
            buildLargeTextField("Enter any additional findings or notes..."),

            const SizedBox(height: 20),
            buildInputLabel("Pictures"),
            _buildUploadPlaceholder(),

            const SizedBox(height: 40),
            buildPrimaryButton("SEND AUDIT REPORT", () {}, icon: Icons.send),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Pass/Fail Item UI
  Widget _buildPassFailItem(String title, String key, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildInputLabel(title),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.4)),
          ),
        Row(
          children: [
            Expanded(
              child: _statusBtn("Pass", Colors.green, Icons.check, _selectedValues[key] == "Pass", () {
                setState(() => _selectedValues[key] = "Pass");
              }),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statusBtn("Fail", Colors.red, Icons.close, _selectedValues[key] == "Fail", () {
                setState(() => _selectedValues[key] = "Fail");
              }),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildUploadPlaceholder(),
        const SizedBox(height: 25),
      ],
    );
  }

  // Custom Status Button (UI matched)
  Widget _statusBtn(String label, Color color, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isSelected ? color : Colors.grey.shade400),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Upload Placeholder (UI matched)
  Widget _buildUploadPlaceholder() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.cloud_upload_outlined, color: Colors.grey, size: 22),
          SizedBox(width: 10),
          Text("Upload an image", style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  // Dropdown Field UI
  Widget _buildDropdownField(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          isExpanded: true,
          items: [], // আপনার গেট লিস্ট এখানে দিন
          onChanged: (val) {},
        ),
      ),
    );
  }
}