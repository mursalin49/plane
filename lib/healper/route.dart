import 'package:avislap/views/auth/parallax_login.dart';
import 'package:avislap/views/home/LAVSafety.dart';
import 'package:get/get.dart';

import '../views/auth/FlightAnimation.dart';
import '../views/dashboard/dashboard_screen.dart';
import '../views/CabinAudit.dart';
import '../views/tasks/lav_safety_screen.dart';
import '../views/cabin_secuirity/cabin_secuirity.dart';

class RouteHelper {
  static const String splash = '/';
  static const String dashboard = '/dashboard';
  static const String cabinAudit = '/cabin-audit';
  // static const String lavSafety = '/lav-safety';
  static const String lavSafety = '/LAVSafety';
  static const String cabinSecurityTraining = '/cabin_secuirity';

  static List<GetPage> routes = [
    GetPage(
      name: splash,
      // page: () => FlightAnimation(),
      page: () => SplashScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: dashboard,
      page: () => const DashboardScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: cabinAudit,
      page: () => CabinAuditScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: lavSafety,
      page: () => LAVSafetyScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: cabinSecurityTraining,
      page: () => const CabinQualityAuditScreenN(),
      transition: Transition.rightToLeft,
    ),
  ];
}