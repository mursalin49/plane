import 'package:get/get.dart';

import '../views/auth/FlightAnimation.dart';


class RouteHelper {
  static const String splash = '/';

  static List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => FlightAnimation(),

      transition: Transition.fadeIn,
    ),
  ];
}