import 'package:get/get.dart';

import '../views/auth/FlightAnimation.dart';
import '../views/dashboard/dashboard_screen.dart';
import '../views/CabinAudit.dart';
import '../views/tasks/lav_safety_screen.dart';
import '../views/home/cabin_secuirity.dart';

class RouteHelper {
  static const String splash = '/';
  static const String dashboard = '/dashboard';
  static const String cabinAudit = '/cabin-audit';
  static const String lavSafety = '/lav-safety';
  static const String cabinSecurityTraining = '/cabin-security-training';

  static List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => FlightAnimation(),
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
      page: () => const LavSafetyScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: cabinSecurityTraining,
      page: () => CabinAuditScreenS(),
      transition: Transition.rightToLeft,
    ),
  ];
}