import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text.dart';

class ChatTab extends StatelessWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.from_heading),
            const SizedBox(height: 24),
            AppText(
              "Chat",
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
            ),
            const SizedBox(height: 12),
            AppText(
              "Group and 1v1 chat will be available here.",
              fontSize: 14,
              color: AppColors.from_heading,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
