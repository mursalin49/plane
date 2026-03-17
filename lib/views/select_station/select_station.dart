import 'package:avislap/controllers/login_controller.dart';
import 'package:avislap/models/station_model.dart';
import 'package:avislap/services/api_client.dart';
import 'package:avislap/views/dashboard/dashboard_screen.dart';
import 'package:avislap/widgets/parallax_hero_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class _C {
  static const Color blue = Color(0xFF3D5AFE);
  static const Color ink = Color(0xFF0E0E10);
  static const Color border = Color(0xFFEAECF2);
  static const Color placeholder = Color(0xFFC8CDD9);
  static const Color muted = Color(0xFF8891A4);
}

class StationSelectionScreen extends StatefulWidget {
  const StationSelectionScreen({super.key});

  @override
  State<StationSelectionScreen> createState() => _StationSelectionScreenState();
}

class _StationSelectionScreenState extends State<StationSelectionScreen> {
  final AuthController _authController = AuthController.ensureRegistered();

  String? _selectedStationId;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    try {
      await _authController.ensureStationContextLoaded();
      StationSummary? defaultStation = _authController.activeStation.value;
      if (defaultStation == null) {
        for (final station in _authController.stations) {
          if (station.isDefault) {
            defaultStation = station;
            break;
          }
        }
      }
      defaultStation ??= _authController.stations.isNotEmpty
          ? _authController.stations.first
          : null;
      _selectedStationId = defaultStation?.stationId;
    } catch (_) {
      // The next submit action will surface the error.
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleContinue() async {
    final stationId = _selectedStationId;
    if (stationId == null || stationId.isEmpty) {
      _showMessage('Please select a station first.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _authController.selectStation(stationId);
      if (!mounted) {
        return;
      }
      Get.offAll(() => const DashboardScreen());
    } on ApiException catch (error) {
      _showMessage(error.message, isError: true);
    } catch (_) {
      _showMessage('Unable to select the station.', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showStationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _buildStationSheet(),
    );
  }

  void _showMessage(String message, {required bool isError}) {
    Get.snackbar(
      isError ? 'Station Selection' : 'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? const Color(0xFFD92D20) : _C.blue,
      colorText: Colors.white,
      margin: EdgeInsets.all(16.w),
    );
  }

  StationSummary? get _selectedStation {
    for (final station in _authController.stations) {
      if (station.stationId == _selectedStationId) {
        return station;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final userName = _authController.currentUserName;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [
          ParallaxHeroWidget(
            bottomPadding: 220,
            trailingAction: GestureDetector(
              onTap: () => _authController.logout(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.30),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Logout',
                      style: GoogleFonts.dmSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            child: Text(
              'Welcome, $userName!',
              style: GoogleFonts.dmSans(
                fontSize: 30.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.8,
                height: 1.15,
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -90),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 30.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Select your station to begin',
                    style: GoogleFonts.dmSans(
                      fontSize: 13.sp,
                      color: Colors.grey.shade500,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  GestureDetector(
                    onTap: _isLoading ? null : _showStationPicker,
                    child: Container(
                      height: 52.h,
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30.r),
                        border: Border.all(color: _C.border, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _isLoading
                                ? Text(
                                    'Loading stations...',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14.sp,
                                      color: _C.placeholder,
                                    ),
                                  )
                                : Text(
                                    _selectedStation?.displayName ??
                                        'Select your station',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14.sp,
                                      color: _selectedStation == null
                                          ? _C.placeholder
                                          : _C.ink,
                                    ),
                                  ),
                          ),
                          Icon(Icons.search, color: _C.muted, size: 20.sp),
                        ],
                      ),
                    ),
                  ),
                  if (_selectedStation != null) ...[
                    SizedBox(height: 12.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FC),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        '${_selectedStation!.roleName} • ${_selectedStation!.timezone}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 13.sp,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 16.h),
                  GestureDetector(
                    onTap: (_isSubmitting || _isLoading)
                        ? null
                        : _handleContinue,
                    child: Container(
                      height: 54.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _C.blue,
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      alignment: Alignment.center,
                      child: _isSubmitting
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'CONTINUE',
                              style: GoogleFonts.dmSans(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          _buildHomeIndicator(),
        ],
      ),
    );
  }

  Widget _buildStationSheet() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
      child: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Select Station',
              style: GoogleFonts.dmSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: _C.ink,
              ),
            ),
            SizedBox(height: 12.h),
            ..._authController.stations.map((station) {
              final isSelected = _selectedStationId == station.stationId;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedStationId = station.stationId);
                  Get.back();
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: 14.h,
                    horizontal: 16.w,
                  ),
                  margin: EdgeInsets.only(bottom: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _C.blue.withValues(alpha: 0.08)
                        : const Color(0xFFF7F8FC),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected
                          ? _C.blue.withValues(alpha: 0.4)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station.displayName,
                        style: GoogleFonts.dmSans(
                          fontSize: 14.sp,
                          color: isSelected ? _C.blue : _C.ink,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${station.roleName} • ${station.timezone}',
                        style: GoogleFonts.dmSans(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeIndicator() {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Center(
        child: Container(
          width: 134.w,
          height: 5.h,
          decoration: BoxDecoration(
            color: _C.ink.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(3.r),
          ),
        ),
      ),
    );
  }
}
