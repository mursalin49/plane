import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// =====================
// COLORS
// =====================
class _DC {
  static const Color primary = Color(0xFF3D5AFE);
  static const Color bg = Color(0xFFEEF1FB);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF8891A4);
  static const Color activeText = Color(0xFF3D5AFE);
  static const Color subItem = Color(0xFF3D5AFE);
  static const Color bottomBar = Color(0xFF3D5AFE);
}

// =====================
// MODEL
// =====================
class DrawerMenuItem {
  final String title;
  final IconData icon;
  final List<DrawerSubItem>? subItems;
  final bool hasChildren;

  DrawerMenuItem({
    required this.title,
    required this.icon,
    this.subItems,
    this.hasChildren = false,
  });
}

class DrawerSubItem {
  final String title;
  final IconData icon;

  DrawerSubItem({required this.title, required this.icon});
}

// =====================
// CONTROLLER
// =====================
class AppDrawerController extends GetxController {
  final RxString expandedItem = ''.obs;

  final List<DrawerMenuItem> menuItems = [
    DrawerMenuItem(
      title: 'Dashboard',
      icon: Icons.pie_chart_outline,
    ),
    DrawerMenuItem(
      title: 'My Employees',
      icon: Icons.people_outline,
      hasChildren: true,
      subItems: [
        DrawerSubItem(
            title: 'Employees Detail', icon: Icons.person_outline),
        DrawerSubItem(
            title: 'Directory', icon: Icons.phone_outlined),
      ],
    ),
    DrawerMenuItem(
      title: 'Forms',
      icon: Icons.insert_drive_file_outlined,
      hasChildren: true,
      subItems: [
        DrawerSubItem(title: 'New Form', icon: Icons.add_outlined),
        DrawerSubItem(
            title: 'Form History', icon: Icons.history_outlined),
      ],
    ),
    DrawerMenuItem(
      title: 'Inventory',
      icon: Icons.bar_chart_outlined,
    ),
    DrawerMenuItem(
      title: 'Chat',
      icon: Icons.chat_bubble_outline,
    ),
    DrawerMenuItem(
      title: 'Time and Edits',
      icon: Icons.access_time_outlined,
      hasChildren: true,
      subItems: [
        DrawerSubItem(
            title: 'Time Sheet', icon: Icons.calendar_today_outlined),
        DrawerSubItem(
            title: 'Edit Requests', icon: Icons.edit_outlined),
      ],
    ),
    DrawerMenuItem(
      title: 'Feedback',
      icon: Icons.people_alt_outlined,
    ),
  ];

  void toggleExpand(String title) {
    if (expandedItem.value == title) {
      expandedItem.value = '';
    } else {
      expandedItem.value = title;
    }
  }

  bool isExpanded(String title) => expandedItem.value == title;
}

// =====================
// APP DRAWER WIDGET
// =====================
class AppDrawerWidget extends StatelessWidget {
  final String appName;
  final String userName;
  final String userRole;
  final String? userImage;
  final VoidCallback? onLogout;

  AppDrawerWidget({
    super.key,
    this.appName = 'Appname',
    this.userName = 'Shara Page',
    this.userRole = 'General Manager',
    this.userImage,
    this.onLogout,
  });

  final AppDrawerController _controller =
      Get.put(AppDrawerController());

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280.w,
      backgroundColor: _DC.bg,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildMenuList()),
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: _DC.primary,
      padding: EdgeInsets.only(
        top: 50.h,
        bottom: 16.h,
        left: 16.w,
        right: 16.w,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Icon(Icons.arrow_back,
                color: Colors.white, size: 22.sp),
          ),
          SizedBox(width: 16.w),
          Text(
            appName,
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ── Menu List ────────────────────────────────────────────
  Widget _buildMenuList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: _controller.menuItems.length,
      itemBuilder: (context, index) {
        final item = _controller.menuItems[index];
        return _buildMenuItem(item);
      },
    );
  }

  Widget _buildMenuItem(DrawerMenuItem item) {
    return Obx(() {
      final expanded = _controller.isExpanded(item.title);

      return Column(
        children: [
          // Main item
          InkWell(
            onTap: () {
              if (item.hasChildren) {
                _controller.toggleExpand(item.title);
              } else {
                Get.back();
                // Navigate to respective screen
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 20.w, vertical: 14.h),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    color: _DC.primary,
                    size: 22.sp,
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      item.title,
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: expanded
                            ? _DC.activeText
                            : _DC.textDark,
                      ),
                    ),
                  ),
                  if (item.hasChildren)
                    AnimatedRotation(
                      turns: expanded ? 0 : 0.5,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_up,
                        color: _DC.primary,
                        size: 20.sp,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Sub items
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: (item.subItems ?? []).map((sub) {
                return InkWell(
                  onTap: () {
                    Get.back();
                    // Navigate to sub screen
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 58.w,
                      right: 20.w,
                      top: 12.h,
                      bottom: 12.h,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          sub.icon,
                          color: _DC.subItem,
                          size: 18.sp,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          sub.title,
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            color: _DC.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      );
    });
  }

  // ── Bottom Bar ───────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      color: _DC.primary,
      padding: EdgeInsets.symmetric(
          horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22.r,
            backgroundImage: userImage != null
                ? AssetImage(userImage!)
                : null,
            backgroundColor: Colors.white24,
            child: userImage == null
                ? Icon(Icons.person,
                    color: Colors.white, size: 22.sp)
                : null,
          ),
          SizedBox(width: 12.w),

          // Name & role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  userRole,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Logout button
          GestureDetector(
            onTap: onLogout ?? () => Get.back(),
            child: Row(
              children: [
                Icon(Icons.logout,
                    color: Colors.white, size: 18.sp),
                SizedBox(width: 4.w),
                Text(
                  'Logout',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
